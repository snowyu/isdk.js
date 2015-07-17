isNumber    = require('util-ex/lib/is/type/number')
fs          = require('graceful-fs')
stripBom    = require('strip-bom')

# get contents of a file via buffer.
bufferFile = (file, cb) ->
  fs.readFile file.fullPath, file, (err, data) ->
    unless err
      data = stripBom(data)
      #data = data.slice(file.skipSize) if isNumber file.skipSize
    cb err, data
  return

module.exports = bufferFile
