#! /usr/bin/env node

import { readFile } from 'node:fs/promises'
import { sep } from 'node:path'
import { Command } from 'commander'
import jsdom from 'jsdom'

function getSectionTitle (root) {
  return root.closest('section')?.querySelector('h1, h2, h3, h4, h5, h6')?.textContent.trim() ?? '(unknown section)'
}

function hasTitle (example) {
  return example.hasAttribute('title') && example.getAttribute('title').trim() !== ''
}

async function main (path, { spec }) {
  try {
    const content = await readFile(path, { encoding: 'utf8' })
    const dom = new jsdom.JSDOM(content)
    const snippets = [...dom.window.document.querySelectorAll('.example')]
    let hasMissingTitles = false

    for (let index = 0; index < snippets.length; index++) {
      const snippet = snippets[index]
      const section = getSectionTitle(snippet)
      const snippetId = `${spec}/${index}`

      if (!hasTitle(snippet)) {
        console.log(`${snippetId}: example missing title attribute in section "${section}". Add a title like <aside class="example" title="...">.`)
        hasMissingTitles = true
      }
    }

    if (hasMissingTitles) {
      process.exitCode = 1
    }else{
      console.log('All examples have a title attribute.')
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
