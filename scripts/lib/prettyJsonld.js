function countBlankNode (json, id) {
  if (typeof json !== 'object') {
    return 0
  }

  let count = 0

  if (json['@id'] === id) {
    count++
  }

  for (const child of Object.values(json)) {
    count += countBlankNode(child, id)
  }

  return count
}

function findRef (json, id) {
  if (typeof json !== 'object') {
    return null
  }

  if (json['@id'] === id && Object.keys(json).length === 1) {
    return json
  }

  for (const child of Object.values(json)) {
    const ref = findRef(child, id)

    if (ref) {
      return ref
    }
  }

  return null
}

function rebuildBlankNodeIds (json, blankNodeMap) {
  if (typeof json !== 'object') {
    return
  }

  if (json['@id'] && json['@id'].startsWith('_:')) {
    const id = json['@id']

    if (!blankNodeMap.has(id)) {
      blankNodeMap.set(id, `_:b${blankNodeMap.size + 1}`)
    }

    json['@id'] = blankNodeMap.get(id)
  }

  for (const child of Object.values(json)) {
    rebuildBlankNodeIds(child, blankNodeMap)
  }
}

function prettyJsonld (json) {
  if (!json['@graph']) {
    return json
  }

  const toClean = new Set()
  const toLink = new Set()

  for (const child of json['@graph']) {
    const id = child['@id']

    if (id.startsWith('_:')) {
      const count = countBlankNode(json, id)

      if (count === 1) {
        toClean.add(id)
      }

      if (count === 2) {
        toLink.add(id)
      }
    }
  }

  json['@graph'] = json['@graph'].sort((a, b) => a['@id'].localeCompare(b['@id']))

  for (const id of toClean) {
    const node = json['@graph'].find(n => n['@id'] === id)

    delete node['@id']
  }

  for (const id of toLink) {
    const nodeIndex = json['@graph'].findIndex(n => n['@id'] === id)
    const node = json['@graph'][nodeIndex]
    const ref = findRef(json, id)

    delete node['@id']
    delete ref['@id']

    for (const [key, values] of Object.entries(node)) {
      ref[key] = values
    }

    json['@graph'].splice(nodeIndex, 1)
  }

  const blankNodeMap = new Map()

  for (const node of json['@graph']) {
    rebuildBlankNodeIds(node, blankNodeMap)
  }

  if (json['@graph'].length === 1) {
    return json['@graph'][0]
  }

  return json
}

export default prettyJsonld
