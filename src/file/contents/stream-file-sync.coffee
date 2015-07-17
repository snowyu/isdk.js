fs = require('graceful-fs')
stripBom = require('strip-bom-stream')

streamFileSync = (file) ->
  result = fs.createReadStream(file.fullPath, file).pipe(stripBom())

module.exports = streamFileSync
