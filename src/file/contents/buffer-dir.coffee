#fs          = require('graceful-fs')
path        = require('path.js')
isFunction  = require 'util-ex/lib/is/type/function'

# get contents of a Dir via buffer.
bufferDir = (aFile, readdirFn, statFn, makeObjFn, cb) ->
  vPath = aFile.fullPath
  if arguments.length == 4
    cb = makeObjFn
    makeObjFn = null
  unless isFunction makeObjFn
    makeObjFn = (options)->options

  cwd = aFile.cwd
  readdirFn vPath
  .map (file)->
    statFn path.join(vPath, file)
    .then (stat)->
      makeObjFn
        path:path.join(vPath, file)
        stat:stat
        cwd:cwd
  , concurrency: 10
  .nodeify(cb)
  # readdirFn vPath, (err, dirs)->
  #   if !err
  #     result = []
  #     Promise.map dirs, (file)->
  #       statFn path.join(vPath, file), (err, stat)->
  #         if !err
  #           result.push makeObjFn
  #             path:path.join(vPath, file)
  #             stat:stat
  #             cwd:cwd
  #         else
  #           cb(err)
  #         cb(err, result)

module.exports = bufferDir
