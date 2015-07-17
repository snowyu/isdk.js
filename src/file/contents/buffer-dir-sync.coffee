#fs          = require('graceful-fs')
path        = require('path.js')
isFunction  = require 'util-ex/lib/is/type/function'

# get contents of a Dir via buffer.
bufferDirSync = (aFile, readdirSync, statSync, makeObjFn) ->
  vPath = aFile.fullPath
  unless isFunction makeObjFn
    makeObjFn = (options)->options
  dirs = readdirSync vPath

  cwd = aFile.cwd
  dirs = dirs.map (file)->
    v = 
    stat = statSync path.join vPath, file
    makeObjFn path:path.join(vPath, file), stat:stat, cwd:cwd

module.exports = bufferDirSync
