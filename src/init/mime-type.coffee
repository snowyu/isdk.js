module.exports = mimeType = require 'mime-type/with-db'

mimeType.define 'script/coffee',
  extensions: ['coffee', 'litcoffee', 'coffee.md'], mimeType.dupAppend