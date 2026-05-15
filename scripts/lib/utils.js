import rdf from 'rdf-ext'

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
    console.error("Error parsing Turtle:\n", turtle)
    console.error(err)
    return null
  }
}

export {
  parseJsonld,
  parseTurtle
}
