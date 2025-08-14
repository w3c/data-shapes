/*
Language: JSON-LD
Description: JSON for Linking Data (JSON-LD) syntax highlighting
Author: Assistant
Website: https://json-ld.org/
Category: data
*/

function jsonld_hljs(hljs) {
  // JSON-LD property keywords
  const JSONLD_PROPERTIES = [
    '@context', '@id', '@type', '@value', '@language', '@index', '@reverse',
    '@nest', '@container', '@set', '@list', '@graph', '@vocab', '@base',
    '@version', '@import', '@included', '@json', '@none', '@prefix',
    '@propagate', '@protected'
  ];

  // Highlight JSON-LD keywords as property attributes
  const JSONLD_ATTRIBUTE = {
    className: 'meta',
    begin: new RegExp(`"(${JSONLD_PROPERTIES.map(k => k.replace('@', '\\@')).join('|')})"(?=\\s*:)`),
    relevance: 10
  };

  // Generic attribute for non-keyword property names
  const ATTRIBUTE = {
    className: 'attr',
    begin: /("(\\.|[^\\"\r\n])*")(?=\s*:)/,
    relevance: 1.01
  };

  const PUNCTUATION = {
    match: /[{}[\],:]/,
    className: "punctuation",
    relevance: 0
  };

  const LITERALS = [
    "true",
    "false",
    "null"
  ];

  const LITERALS_MODE = {
    scope: "literal",
    beginKeywords: LITERALS.join(" "),
  };

  return {
    name: 'JSON-LD',
    aliases: ['jsonld', 'json-ld'],
    contains: [
      hljs.C_LINE_COMMENT_MODE,
      hljs.C_BLOCK_COMMENT_MODE,
      JSONLD_ATTRIBUTE,
      ATTRIBUTE,
      PUNCTUATION,
      hljs.APOS_STRING_MODE,
      hljs.QUOTE_STRING_MODE,
      LITERALS_MODE,
      hljs.NUMBER_MODE
    ],
    illegal: '\\S'
  };
}

// Standard highlight.js language registration
module.exports = function(hljs) {
  hljs.registerLanguage("jsonld", jsonld_hljs);
};

module.exports.definer = jsonld_hljs;