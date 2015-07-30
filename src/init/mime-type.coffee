mimeTypes = require 'mime-types'

#mimes = mimeTypes.mimes

mimeTypes.define 'script/coffee',
  extensions: ['coffee', 'litcoffee', 'coffee.md'], mimeTypes.dupAppend
