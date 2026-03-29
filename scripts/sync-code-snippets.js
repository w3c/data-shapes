#! /usr/bin/env node

import { readFile, writeFile } from 'node:fs/promises'
import { join, sep } from 'node:path'
import { fileURLToPath } from 'node:url'
import pretty from '@rdfjs/formats/pretty.js'
import { Command } from 'commander'
import jsdom from 'jsdom'
import { mkdirp } from 'mkdirp'
import rdf from 'rdf-ext'
import { write as shaclcWrite } from 'shaclc-write'
import prettyJsonld from './lib/prettyJsonld.js'
import { parseJsonld, parseTurtle, parseShaclc } from './lib/utils.js'

rdf.formats.import(pretty)

const ignore = new Set([
  'shacl12-core/5', // can be removed when https://github.com/rubensworks/jsonld-streaming-parser.js/issues/130 is fixed
  'shacl12-core/74', // can be removed when RDF/JS parser and serializer support RDF 1.2
  'shacl12-sparql/3', // can be removed when https://github.com/rubensworks/jsonld-streaming-parser.js/issues/130 is fixed
  'shacl12-sparql/6', // can be removed when https://github.com/rubensworks/jsonld-streaming-parser.js/issues/130 is fixed
])

const jsonldContext = {
  '@context': {
    owl: 'http://www.w3.org/2002/07/owl#',
    rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
    sh: 'http://www.w3.org/ns/shacl#',
    xsd: 'http://www.w3.org/2001/XMLSchema#',
    ex: 'http://example.com/ns#'
  }
}

const turtlePrefixes = `
@prefix owl: <http://www.w3.org/2002/07/owl#>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
@prefix sh: <http://www.w3.org/ns/shacl#>.
@prefix xsd: <http://www.w3.org/2001/XMLSchema#>.
@prefix ex: <http://example.com/ns#>.
`

const shaclcPrefixes = 
  'BASE <http://example.com/>' +
  turtlePrefixes.replaceAll('@prefix', 'PREFIX').replaceAll('.', '')

function escape (str) {
  return str
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
}

// Convert Turtle shapes to SHACL Compact Syntax using shaclc-write
async function convertTurtleToShaclc (dataset) {
  // Convert to SHACL-C using shaclc-write
  const result = await shaclcWrite(dataset, { prefixes: jsonldContext['@context'], requireBase: false })
  const shaclcContent = result.text
  
  // Clean up the output (remove base and unwanted prefixes)
  let cleanedShaclc = shaclcContent
    .replace(/^BASE\s+<[^>]+>\s*\n/i, '')
    .replace(/^PREFIX\s+\w*:\s*<[^>]+>\s*\n/gmi, '')
    .trim()

  return cleanedShaclc
}

class Snippet {
  constructor (root, { index, spec }) {
    this.root = root
    this.index = index
    this.spec = spec

    this.indexStr = this.index.toString().padStart(3, '0')
  }

  get id () {
    return `${this.spec}/${this.index}`
  }

  get ignore () {
    return ignore.has(this.id)
  }

  async init () {
    try {
      this.section = this.root.closest('section').querySelector('h1, h2, h3, h4, h5, h6').textContent.trim()

      this.turtleContent = this.root.querySelector('.turtle')?.textContent
      this.jsonldContent = this.root.querySelector('.jsonld pre.jsonld')?.textContent
      this.shaclcContent = this.root.querySelector('.shaclc pre.shaclc')?.textContent

      this.jsonldRdf = await parseJsonld(this.jsonldContent, jsonldContext)
      this.turtleRdf = await parseTurtle(this.turtleContent, turtlePrefixes)
      this.shaclcRdf = this.shaclcContent ? await parseShaclc(this.shaclcContent, shaclcPrefixes) : null;

      if (this.turtleRdf) {
        const jsonldStr = await rdf.io.dataset.toText('application/ld+json', this.turtleRdf, { context: jsonldContext })
        let jsonldFull = JSON.parse(jsonldStr)
        delete jsonldFull['@context']

        jsonldFull = prettyJsonld(jsonldFull)

        this.jsonldExpected = JSON.stringify(jsonldFull, null, '\t')
        this.isJsonExpected = this.jsonldExpected === this.jsonldContent

        if (this.root.classList.contains('shapes-graph')) {
          try {
            this.shaclcExpected = await convertTurtleToShaclc(this.turtleRdf)
          } catch (err) {
            console.error(`Error converting Turtle to SHACL-C for ${this.id}:`)
            this.shaclcExpected = null
          }
          if (this.shaclcExpected) {
            this.isShaclcExpected = this.shaclcExpected === this.shaclcContent
          } else {
            this.isShaclcExpected = true
          }
        }
      }

      if (this.jsonldRdf && this.turtleRdf) {
        this.isJsonldEqual = this.jsonldRdf.equals(this.turtleRdf)
      }
      if (this.shaclcRdf && this.turtleRdf) {
        this.isShaclcEqual = this.shaclcRdf.equals(this.turtleRdf)
      }
    } catch (err) {
      this.error = err.message
    }
  }

  toString () {
    return `${this.indexStr} ${this.section}`
  }

  async write (base) {
    if (this.turtleContent) {
      await writeFile(join(base, `${this.indexStr}-turtle-content.ttl`), this.turtleContent)
    }

    if (this.turtleRdf) {
      await writeFile(join(base, `${this.indexStr}-turtle-rdf.ttl`), this.turtleRdf.toCanonical())
    }

    if (this.jsonldContent) {
      await writeFile(join(base, `${this.indexStr}-jsonld-content.json`), this.jsonldContent)
    }

    if (this.jsonldRdf) {
      await writeFile(join(base, `${this.indexStr}-jsonld-rdf.ttl`), this.jsonldRdf.toCanonical())
    }

    if (this.jsonldExpected) {
      await writeFile(join(base, `${this.indexStr}-jsonld-expected.json`), escape(this.jsonldExpected))
    }
    if (this.shaclcContent) {
      await writeFile(join(base, `${this.indexStr}-shaclc-content.shce`), this.shaclcContent)
    }
    if (this.shaclcRdf) {
      await writeFile(join(base, `${this.indexStr}-shaclc-rdf.ttl`), this.shaclcRdf.toCanonical())
    }
    if (this.shaclcExpected) {
      await writeFile(join(base, `${this.indexStr}-shaclc-expected.shce`), escape(this.shaclcExpected))
    }
  }

  static async from (root, options) {
    const snippet = new Snippet(root, options)

    await snippet.init()

    return snippet
  }
}

async function main (path, { output, spec, writeEqual, writeShaclc, writeJsonld }) {
  try {
    const content = await readFile(path, { encoding: 'utf8' })
    const dom = new jsdom.JSDOM(content)
    const snippets = [...dom.window.document.querySelectorAll('.shapes-graph, .data-graph, .results-graph')]
    let documentModified = false

    await mkdirp(output)

    for (let index = 0; index < snippets.length; index++) {
      const snippet = await Snippet.from(snippets[index], { index, spec })

      if (snippet.ignore) {
        continue
      }

      if (snippet.error) {
        console.error(`${snippet.id}: Snippet can't be processed: ${snippet.error}`)

        continue
      }

      if (!snippet.jsonldContent) {
        console.log(`${snippet.id}: JSON-LD content missing`)

        // Write back to spec if enabled
        if (writeJsonld && snippet.jsonldExpected) {
          const jsonldElement = snippet.root.querySelector('.jsonld pre.jsonld')
          if (jsonldElement) {
            jsonldElement.textContent = snippet.jsonldExpected
            documentModified = true
            console.log(`${snippet.id}: Updated JSON-LD content in spec`)
          }
        }

        await snippet.write(output)
      } else if (!snippet.isJsonldEqual) {
        console.log(`${snippet.id}: JSON-LD triples are different from turtle`)

        await snippet.write(output)
      } else if (!snippet.isJsonExpected) {
        console.log(`${snippet.id}: JSON-LD content doesn't look as expected`)

        await snippet.write(output)
      } else {
        if (writeEqual) {
          await snippet.write(output)
        }
      }

      if (snippet.root.classList.contains('shapes-graph')) {
        if (!snippet.shaclcContent) {
          console.log(`${snippet.id}: SHACL-C content missing`)

          // Write back to spec if enabled
          if (writeShaclc && snippet.shaclcExpected) {
            console.log(`${snippet.id}: Writing SHACL-C content to spec`)
            let shaclcElement = snippet.root.querySelector('.shaclc pre.shaclc')

            // If the element does not exist, create it
            if (!shaclcElement) {
              const divElement = dom.window.document.createElement('div')
              divElement.className = 'shaclc'
              const preElement = dom.window.document.createElement('pre')
              preElement.className = 'shaclc'
              preElement.textContent = snippet.shaclcExpected
              divElement.appendChild(preElement)
              snippet.root.appendChild(divElement)
            } else {
              shaclcElement.textContent = snippet.shaclcExpected
            }

            documentModified = true
            console.log(`${snippet.id}: Updated SHACL-C content in spec`)
          }

          await snippet.write(output)
        } else if (!snippet.isShaclcEqual) {
          console.log(`${snippet.id}: SHACL-C triples are different from turtle`)

          await snippet.write(output)
        } else if (!snippet.isShaclcExpected) {
          console.log(`${snippet.id}: SHACL-C content doesn't look as expected`)

          await snippet.write(output)
        } else {
          if (writeEqual) {
            await snippet.write(output)
          }
        }
      }
    }
    if (documentModified) {
      const updatedContent = dom.serialize() + '\n'
      await writeFile(path, updatedContent, { encoding: 'utf8' })
      console.log(`Updated specification file: ${path}`)
    } else {
      console.log('No changes made to the specification file.')
    }
  } catch (err) {
    console.error(err)
  }
}

const program = new Command()

program
  .argument('[path]', 'path to the HTML file of the specification')
  .option('-o, --output <path>', 'output folder')
  .option('-s, --spec <id>', 'id of the specification')
  .option('--write-equal', 'write snippets that are equal')
  .option('--write-shaclc', 'write shaclc to the specification file')
  .option('--write-jsonld', 'write jsonld to the specification file')
  .action(async (path, { ...options }) => {
    if (!options.spec) {
      options.spec = path.split(sep).slice(-2)[0]
    }

    if (!options.output) {
      const root = fileURLToPath(new URL('..', import.meta.url))

      options.output = join(root, 'out', options.spec)
    }

    await main(path, options)
  })
  .parse(process.argv)
