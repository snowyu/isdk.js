module.exports  = parsers = require 'gray-matter/lib/parsers'
try cson        = require 'cson'
if cson
  #((cson)->cson.parseCSONString.apply cson, arguments)(cson)
  parsers.cson    = cson.parseCSONString.bind(cson)
  parsers.coffee  = cson.parseCSString.bind(cson)
