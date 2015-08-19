module.exports = mimeType = require 'mime-type/with-db'

mimeType.define 'script/coffee',
  extensions: ['coffee', 'litcoffee', 'coffee.md'], mimeType.dupAppend


markdownExts = [
  'md', 'mdown', 'markdown', 'mkd','mkdn'
  'mdwn', 'mdtext','mdtxt'
  'text'
]
mimeType.define 'text/x-markdown',
  extensions: markdownExts, mimeType.dupAppend
