import rdf from 'rdf-ext'
import { parse } from 'shaclc-parse'

async function parseJsonld (jsonld, context = {}) {
  try {
    rdf._data.blankNodeCounter = 0

    return await rdf.io.dataset.fromText('application/ld+json', JSON.stringify({
      ...context,
      ...JSON.parse(jsonld)
    }))
  } catch (err) {
    return null
  }
}

async function parseTurtle (turtle, prefixes = '') {
  try {
    rdf._data.blankNodeCounter = 0

    return await rdf.io.dataset.fromText('text/turtle', `${prefixes}\n${turtle}`)
  } catch (err) {
    return null
  }
}

async function parseShaclc (shaclc, prefixes = '') {
  try {
    return rdf.dataset(parse(`${prefixes}\n${shaclc}`))
  } catch (err) {
    return null
  }
}

export {
  parseJsonld,
  parseTurtle,
  parseShaclc
}
