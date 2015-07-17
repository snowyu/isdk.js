fs = require('graceful-fs')
stripBom = require('strip-bom')

# get contents of a file via buffer.
bufferFileSync = (file) ->
  data = fs.readFileSync file.fullPath, file
  data = stripBom(data)
  #data = data.slice(file.skipSize) if isNumber file.skipSize

module.exports = bufferFileSync
