fs = require('graceful-fs')
stripBom = require('strip-bom-stream')

streamFile = (file, cb) ->
  result = fs.createReadStream(file.fullPath, file).pipe(stripBom())
  cb null, result
  return

module.exports = streamFile
