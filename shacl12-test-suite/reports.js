'use strict'

const MF = 'http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#'
const SHT = 'http://www.w3.org/ns/shacl-test#'
const RDF = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
const RDFS = 'http://www.w3.org/2000/01/rdf-schema#'
const EARL = 'http://www.w3.org/ns/earl#'
const DOAP = 'http://usefulinc.com/ns/doap#'
const DC = ['http://purl.org/dc/terms/', 'http://purl.org/dc/elements/1.1/']

const TESTS_BASE = new URL('tests/', location.href).href
const REPORTS_BASE = new URL('reports/', location.href).href
const ROOT_MANIFEST = new URL('manifest.ttl', TESTS_BASE).href

// The conformance criteria of the README, in the order in which they are displayed
const CRITERIA = [
	['Core', 'SHACL Core processors'],
	['InferenceRules', 'SHACL rules engines'],
	['NodeExpr', 'SHACL Node Expressions processors'],
	['SPARQLValidation', 'SHACL-SPARQL validation processors'],
	['SPARQLNodeExpr', 'SPARQL node expression processors'],
	['SPARQLCustomFunctions', 'SPARQL custom function processors'],
	['SRLEvaluation', 'SPARQL-RL Rule Set evaluation'],
	['SRLSyntax', 'SPARQL-RL syntax'],
]
const CRITERIA_DESCRIPTIONS = new Map(CRITERIA)

// Default conformance criteria for tests without mf:requires, by top-level folder (see README)
const DEFAULT_CRITERIA = {
	'core': 'Core',
	'inference-rules': 'InferenceRules',
	'node-expr': 'NodeExpr',
}


// Creates a DOM element; children may be strings (added as text, never as HTML) or nodes
function el(tag, attrs = {}, ...children) {
	const e = document.createElement(tag)
	for (const [name, value] of Object.entries(attrs)) {
		if (value != null) {
			e.setAttribute(name, value)
		}
	}
	for (const child of children.flat()) {
		if (child != null) {
			e.append(child)
		}
	}
	return e
}

function localName(iri) {
	return iri.replace(/^.*[#/]/, '')
}

function safeHref(iri) {
	return /^https?:\/\//.test(iri) ? iri : null
}

function showMessage(text, isError) {
	document.getElementById('messages').append(el('p', { class: isError ? 'error' : 'muted' }, text))
}


// Limits the number of concurrent requests, as simple web servers drop connections when hundreds of
// test files are requested at once
const MAX_CONCURRENT_FETCHES = 8
let activeFetches = 0
const waitingFetches = []

async function limitedFetch(url) {
	if (activeFetches >= MAX_CONCURRENT_FETCHES) {
		await new Promise(resolve => waitingFetches.push(resolve))
	}
	activeFetches++
	try {
		return await fetch(url)
	}
	finally {
		activeFetches--
		waitingFetches.shift()?.()
	}
}

async function loadTurtle(url) {
	const response = await limitedFetch(url)
	if (!response.ok) {
		throw new Error(`${url}: HTTP ${response.status}`)
	}
	const text = await response.text()
	return new N3.Store(new N3.Parser({ baseIRI: url }).parse(text))
}

function objects(store, subject, predicate) {
	return store.getObjects(subject, N3.DataFactory.namedNode(predicate), null)
}

function object(store, subject, predicate) {
	return objects(store, subject, predicate)[0]
}

function firstLiteral(store, subject, predicates) {
	for (const p of predicates) {
		const o = object(store, subject, p)
		if (o) {
			return o.value
		}
	}
	return null
}

function listItems(store, list) {
	const items = []
	while (list && list.value !== RDF + 'nil') {
		const first = object(store, list, RDF + 'first')
		if (first) {
			items.push(first)
		}
		list = object(store, list, RDF + 'rest')
	}
	return items
}


// Maps the IRI of a test case, either in the urn:x-shacl-test: form or as a URL of the tests folder,
// to its path relative to the tests folder, e.g. "core/complex/personexample"
function testKey(iri) {
	if (iri.startsWith('urn:x-shacl-test:')) {
		return iri.substring('urn:x-shacl-test:'.length).replace(/^\/+/, '')
	}
	if (iri.startsWith(TESTS_BASE)) {
		return iri.substring(TESTS_BASE.length)
	}
	const index = iri.lastIndexOf('/tests/')
	return index >= 0 ? iri.substring(index + '/tests/'.length) : iri
}


// Collects the test cases from the given manifest and (recursively) its mf:includes
async function collectTests(manifestURL, tests, visited) {
	if (visited.has(manifestURL)) {
		return
	}
	visited.add(manifestURL)
	const store = await loadTurtle(manifestURL)
	const includes = []
	for (const manifest of store.getSubjects(N3.DataFactory.namedNode(RDF + 'type'), N3.DataFactory.namedNode(MF + 'Manifest'), null)) {
		for (const include of objects(store, manifest, MF + 'include')) {
			includes.push(include.value)
		}
		for (const entries of objects(store, manifest, MF + 'entries')) {
			for (const entry of listItems(store, entries)) {
				const key = testKey(entry.value)
				const type = object(store, entry, RDF + 'type')
				let requires = objects(store, entry, MF + 'requires').map(r => localName(r.value))
				if (requires.length === 0) {
					const folder = key.split('/')[0]
					requires = [DEFAULT_CRITERIA[folder] || 'Unspecified']
				}
				tests.set(key, {
					key,
					file: manifestURL,
					type: type ? localName(type.value) : '',
					requires,
				})
			}
		}
	}
	await Promise.all(includes.map(url => collectTests(url, tests, visited)))
}


// Returns the .ttl files linked from the web server's HTML listing of the reports folder (as produced for
// example by "python3 -m http.server"), or null if the server does not produce such a listing
async function listReportFilesFromDirectoryListing() {
	try {
		const response = await fetch(REPORTS_BASE)
		if (!response.ok || !(response.headers.get('content-type') || '').includes('html')) {
			return null
		}
		const doc = new DOMParser().parseFromString(await response.text(), 'text/html')
		const urls = [...doc.querySelectorAll('a[href]')]
			.map(a => new URL(a.getAttribute('href'), REPORTS_BASE))
			.filter(url => url.pathname.endsWith('.ttl') && url.href.startsWith(REPORTS_BASE) && !url.href.substring(REPORTS_BASE.length).includes('/'))
			.map(url => url.href)
		return urls.length > 0 ? [...new Set(urls)] : null
	}
	catch (ex) {
		return null
	}
}


// Derives the GitHub repository location of the reports folder from the page URL, for GitHub Pages
// (https://owner.github.io/repo/path/reports.html, from the Pages branch) and raw.githack.com
// (https://raw.githack.com/owner/repo/branch/path/reports.html), or returns null for other hosts
function githubLocationOfPage() {
	const segments = location.pathname.split('/').filter(s => s)
	if (!location.pathname.endsWith('/')) {
		segments.pop() // reports.html
	}
	if (location.hostname.endsWith('.github.io') && segments.length >= 1) {
		const [repo, ...path] = segments
		return { owner: location.hostname.split('.')[0], repo, ref: null, path: [...path, 'reports'].join('/') }
	}
	if (/^(raw|rawcdn)\.githack\.com$/.test(location.hostname) && segments.length >= 3) {
		const [owner, repo, ref, ...path] = segments
		return { owner, repo, ref, path: [...path, 'reports'].join('/') }
	}
	return null
}


// Lists the .ttl files of the reports folder: from the ?reports= parameter, from the web server's listing of
// the folder (e.g. when served locally), or else from the GitHub contents API, as GitHub Pages and
// raw.githack.com have no listings. On these hosts, the repository, branch and folder are derived from the
// page URL, otherwise the folder of the W3C repository is listed, and the files of that name are loaded
// from the local folder.
async function listReportFiles() {
	const param = new URLSearchParams(location.search).get('reports')
	if (param) {
		return param.split(',').map(s => s.trim()).filter(s => s).map(s => new URL(s, REPORTS_BASE).href)
	}

	const github = githubLocationOfPage()
	if (!github) {
		const listed = await listReportFilesFromDirectoryListing()
		if (listed) {
			return listed
		}
	}

	const { owner, repo, ref, path } = github || { owner: 'w3c', repo: 'data-shapes', ref: null, path: 'shacl12-test-suite/reports' }
	const query = ref ? `?ref=${encodeURIComponent(ref)}` : ''
	const response = await fetch(`https://api.github.com/repos/${owner}/${repo}/contents/${path}${query}`)
	if (!response.ok) {
		throw new Error(`GitHub API: HTTP ${response.status} for ${owner}/${repo}/${path}${ref ? ` (branch ${ref})` : ''} - use ?reports=a.ttl,b.ttl instead`)
	}
	const files = await response.json()
	return files
		.filter(f => f.type === 'file' && f.name.endsWith('.ttl'))
		.map(f => new URL(f.name, REPORTS_BASE).href)
}


// Loads the implementations (earl:TestSubjects) of an EARL report, with their outcomes by test key
async function loadReport(url) {
	const store = await loadTurtle(url)
	const implementations = new Map()
	const getImplementation = (subject) => {
		if (!implementations.has(subject.value)) {
			implementations.set(subject.value, {
				file: url,
				name: firstLiteral(store, subject, [DOAP + 'name', RDFS + 'label']) || localName(subject.value) || url,
				homepage: firstLiteral(store, subject, [DOAP + 'homepage']) || (subject.termType === 'NamedNode' ? subject.value : null),
				description: firstLiteral(store, subject, [DOAP + 'description', ...DC.map(ns => ns + 'description')]),
				outcomes: new Map(),
				dates: [],
			})
		}
		return implementations.get(subject.value)
	}
	for (const assertion of store.getSubjects(N3.DataFactory.namedNode(EARL + 'test'), null, null)) {
		const test = object(store, assertion, EARL + 'test')
		const subject = object(store, assertion, EARL + 'subject')
		const result = object(store, assertion, EARL + 'result')
		if (!test || !subject) {
			continue
		}
		const implementation = getImplementation(subject)
		const outcome = result ? object(store, result, EARL + 'outcome') : null
		implementation.outcomes.set(testKey(test.value), outcome ? localName(outcome.value) : 'untested')
		const date = result ? firstLiteral(store, result, DC.map(ns => ns + 'date')) : null
		if (date) {
			implementation.dates.push(date)
		}
	}
	return [...implementations.values()]
}


function outcomeCell(outcome) {
	if (!outcome) {
		return el('td', { class: 'outcome nodata' }, 'no data')
	}
	const cls = outcome === 'passed' ? 'passed' : outcome === 'failed' ? 'failed' : 'other'
	return el('td', { class: `outcome ${cls}` }, outcome)
}

function summaryCell(implementation, tests) {
	const reported = tests.filter(t => implementation.outcomes.has(t.key)).length
	if (reported === 0) {
		return el('td', { class: 'percent nodata' }, 'no data')
	}
	const passed = tests.filter(t => implementation.outcomes.get(t.key) === 'passed').length
	const percent = Math.floor(100 * passed / tests.length)
	return el('td', { class: 'percent' }, `${passed} / ${tests.length} (${percent}%)`)
}

function implementationHeader(implementation, index) {
	return el('th', {}, el('a', { href: `#impl-${index}` }, implementation.name))
}

function sortedGroups(tests) {
	const groups = new Map()
	for (const test of tests.values()) {
		for (const criterion of test.requires) {
			if (!groups.has(criterion)) {
				groups.set(criterion, [])
			}
			groups.get(criterion).push(test)
		}
	}
	const order = CRITERIA.map(([id]) => id)
	const rank = id => order.includes(id) ? order.indexOf(id) : order.length
	return [...groups.entries()]
		.sort(([a], [b]) => rank(a) - rank(b) || a.localeCompare(b))
		.map(([id, groupTests]) => [id, groupTests.sort((a, b) => a.key.localeCompare(b.key))])
}


function render(tests, implementations) {
	const content = document.getElementById('content')
	content.replaceChildren()

	const groups = sortedGroups(tests)

	// Implementations
	content.append(el('h2', {}, 'Implementations'))
	if (implementations.length === 0) {
		content.append(el('p', {}, 'No implementation reports were found.'))
	}
	implementations.forEach((implementation, index) => {
		const unknown = [...implementation.outcomes.keys()].filter(key => !tests.has(key)).length
		const rows = [
			['Homepage:', implementation.homepage && safeHref(implementation.homepage)
				? el('a', { href: implementation.homepage }, implementation.homepage) : implementation.homepage],
			['Report:', el('a', { href: implementation.file }, decodeURIComponent(implementation.file.replace(/^.*\//, '')))],
			['Tests Updated:', implementation.dates.length ? implementation.dates.sort().at(-1).substring(0, 10) : null],
			['Description:', implementation.description],
			['Unknown tests:', unknown ? `${unknown} results refer to tests that are not in the test suite` : null],
		].filter(([, value]) => value)
		content.append(el('section', { id: `impl-${index}` },
			el('h3', {}, implementation.name),
			el('table', { class: 'impls' }, rows.map(([label, value]) => el('tr', {}, el('td', {}, label), el('td', {}, value))))))
	})

	// Summary by conformance criterion
	content.append(el('h2', {}, 'Summary'))
	content.append(el('div', { class: 'scroll' }, el('table', {},
		el('tr', {}, el('th', {}, 'Conformance Criterion'), el('th', {}, 'Tests'), implementations.map(implementationHeader)),
		groups.map(([id, groupTests]) => el('tr', {},
			el('td', {}, el('a', { href: `#group-${id}` }, id), CRITERIA_DESCRIPTIONS.has(id) ? el('span', { class: 'muted' }, ` (${CRITERIA_DESCRIPTIONS.get(id)})`) : null),
			el('td', { class: 'percent' }, String(groupTests.length)),
			implementations.map(implementation => summaryCell(implementation, groupTests)))))))

	// Controls
	const hidePassed = el('input', { type: 'checkbox', id: 'hide-passed' })
	content.append(el('div', { class: 'controls' }, hidePassed, ' ', el('label', { for: 'hide-passed' }, 'Hide tests that all implementations have passed')))

	// One table per conformance criterion
	const allPassedRows = []
	for (const [id, groupTests] of groups) {
		content.append(el('h2', { id: `group-${id}` }, id, CRITERIA_DESCRIPTIONS.has(id) ? el('span', { class: 'muted' }, ` – ${CRITERIA_DESCRIPTIONS.get(id)}`) : null))
		const rows = groupTests.map(test => {
			const row = el('tr', {},
				el('td', { class: 'file' }, el('a', { href: test.file }, test.key)),
				el('td', { class: 'type' }, test.type),
				implementations.map(implementation => outcomeCell(implementation.outcomes.get(test.key))))
			if (implementations.length > 0 && implementations.every(i => i.outcomes.get(test.key) === 'passed')) {
				allPassedRows.push(row)
			}
			return row
		})
		content.append(el('div', { class: 'scroll' }, el('table', {},
			el('tr', {}, el('th', {}, 'File'), el('th', {}, 'Type'), implementations.map(implementationHeader)),
			el('tr', {}, el('td', { colspan: 2 }, `${groupTests.length} tests`), implementations.map(implementation => summaryCell(implementation, groupTests))),
			rows)))
	}

	hidePassed.addEventListener('change', () => {
		allPassedRows.forEach(row => row.hidden = hidePassed.checked)
	})
}


async function main() {
	const tests = new Map()
	try {
		await collectTests(ROOT_MANIFEST, tests, new Set())
	}
	catch (ex) {
		const hint = location.protocol === 'file:' ? '\nThis page must be served over HTTP, e.g. with "python3 -m http.server" in the test suite folder.' : ''
		showMessage(`Could not load the test suite: ${ex.message}${hint}`, true)
		document.getElementById('content').replaceChildren()
		return
	}

	const files = await listReportFiles().catch(ex => {
		showMessage(`Could not list the report files: ${ex.message}`, true)
		return []
	})
	const results = await Promise.allSettled(files.map(loadReport))
	const implementations = []
	results.forEach((result, index) => {
		if (result.status === 'fulfilled') {
			implementations.push(...result.value)
		}
		else {
			showMessage(`Could not load ${files[index]}: ${result.reason.message}`, true)
		}
	})
	implementations.sort((a, b) => a.name.localeCompare(b.name))

	render(tests, implementations)
}

main()
