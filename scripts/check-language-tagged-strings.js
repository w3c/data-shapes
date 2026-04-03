#! /usr/bin/env node

import { readFile } from 'node:fs/promises'
import { join, sep } from 'node:path'
import { Command } from 'commander'
import jsdom from 'jsdom'
import { parseTurtle } from './lib/utils.js'

const ignore = new Set([
   // 'shacl12-core/1', // can be used to ignore specific snippets by their id (spec/index)
])

const predicatesToCheck = [
    "http://www.w3.org/2000/01/rdf-schema#label",
    "http://www.w3.org/2000/01/rdf-schema#comment",
    "http://www.w3.org/ns/shacl#name",
    "http://www.w3.org/ns/shacl#description",
    "http://www.w3.org/ns/shacl#resultMessage",
    "http://www.w3.org/ns/shacl#message",
    "http://www.w3.org/ns/shacl#intent",
    "http://www.w3.org/ns/shacl#agentInstruction",
    "http://www.w3.org/ns/shacl#unit",
];

const turtlePrefixes = `
@prefix owl: <http://www.w3.org/2002/07/owl#>.
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
@prefix sh: <http://www.w3.org/ns/shacl#>.
@prefix xsd: <http://www.w3.org/2001/XMLSchema#>.
@prefix ex: <http://example.com/ns#>.
@prefix eg: <http://example.com/ns#>.
@prefix dct: <http://purl.org/dc/terms/>.
@prefix shui: <http://www.w3.org/ns/shacl-ui#>.
@prefix skos: <http://www.w3.org/2004/02/skos/core#>.
@prefix schema: <http://schema.org/>.
@prefix foaf: <http://xmlns.com/foaf/0.1/>.
@prefix shnex: <http://www.w3.org/ns/shacl-node-expr#>.
@prefix sparql: <http://www.w3.org/ns/sparql#>.
@prefix qb: <https://www.w3.org/TR/vocab-data-cube/>.
@prefix sdmx-dimension: <http://purl.org/linked-data/sdmx/2009/dimension#>.
@prefix eg-measure: <http://example.com/measure#>.
`

function escape (str) {
  return str
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
}

async function isUntaggedString(term) {
  if (term.termType !== 'Literal') {
    return false;
  }
  
  return term.language === '';
}

async function predicateToCheck(predicate) {
  return predicatesToCheck.includes(predicate.value);
}
 

async function checkLanguageTaggedStrings (snippet) {
  for (const quad of snippet.turtleRdf) {
    if ( await isUntaggedString(quad.object) && await predicateToCheck(quad.predicate)) {
      console.log(`Found untagged string in snippet ${snippet.id}: "${quad.object.value}" (Subject: ${quad.subject.value}) Predicate: ${quad.predicate.value})`);
    }
  }
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

      this.turtleRdf = await parseTurtle(this.turtleContent, turtlePrefixes)

    } catch (err) {
      this.error = err.message
    }
  }

  toString () {
    return `${this.indexStr} ${this.section}`
  }

  static async from (root, options) {
    const snippet = new Snippet(root, options)

    await snippet.init()

    return snippet
  }
}

async function main (path, { spec }) {
  try {
    const content = await readFile(path, { encoding: 'utf8' })
    const dom = new jsdom.JSDOM(content)
    const snippets = [...dom.window.document.querySelectorAll('.shapes-graph, .data-graph, .results-graph')]

    for (let index = 0; index < snippets.length; index++) {
      const snippet = await Snippet.from(snippets[index], { index, spec })

      if (snippet.ignore) {
        continue
      }

      if (snippet.error) {
        console.error(`${snippet.id}: Snippet can't be processed: ${snippet.error}`)
        continue
      }

      if (snippet.turtleRdf) {
        await checkLanguageTaggedStrings(snippet)
      }
    }

  } catch (err) {
    console.error(err)
  }
}

const program = new Command()

program
  .argument('[path]', 'path to the HTML file of the specification')
  .option('-s, --spec <id>', 'id of the specification')
  .action(async (path, { ...options }) => {
    if (!options.spec) {
      options.spec = path.split(sep).slice(-2)[0]
    }

    await main(path, options)
  })
  .parse(process.argv)
