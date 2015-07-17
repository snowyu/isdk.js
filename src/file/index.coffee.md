---
name: File
type: script/coffee
author: riceball
license: MIT
---

Summray
=======

the file and folder information class inherits from AbstractFile.

* skipSize *(number)*: the skipped length from beginning of contents.
  this could get the contents quickly later.

These above are the attributes of File extends.

    fs              = require 'graceful-fs'
    inherits        = require 'inherits-ex'
    createObject    = require 'inherits-ex/lib/createObject'
    path            = require 'path.js'
    isUndefined     = require 'util-ex/lib/is/type/undefined'
    isObject        = require 'util-ex/lib/is/type/object'
    isString        = require 'util-ex/lib/is/type/string'
    isFunction      = require 'util-ex/lib/is/type/function'
    extend          = require 'util-ex/lib/extend'
    AbstractFile    = require './abstract-file'
    bufferFileSync  = require './contents/buffer-file-sync'
    streamFileSync  = require './contents/stream-file-sync'
    bufferFile      = require './contents/buffer-file'
    streamFile      = require './contents/stream-file'
    setImmediate    = global.setImmediate or process.nextTick
    isBuffer        = Buffer.isBuffer

    class File
      inherits File, AbstractFile

load file information from file system. check the file.stat whether exists.

      constructor: (aOptions)->
        return new File(aOptions) if not (@ instanceof File)
        super
      _validate: (file)->
        file.stat? and not file.stat.isDirectory()
      _loadStatSync: (aOptions)->
        fs.statSync(@fullPath(aOptions))
      _getStreamSync: (file)->
        streamFileSync file
      _getBufferSync: (file)->
        bufferFileSync file
      _getStreamAsync: (file, cb)->
        streamFile file, cb
      _getBufferAsync: (file, cb)->
        bufferFile file, cb
      _loadContentSync: (aOptions)->
        if aOptions.buffer != false
          @_getBufferSync(aOptions)
        else
          @_getStreamSync(aOptions)
      _loadStatAsync: (aOptions, done)->
        fs.stat aOptions.fullPath, (err, result)=>
          @stat = result unless err
          done(err, result)
          return
      _loadContentAsync: (aOptions, cb)->
        if aOptions.buffer != false
          @_getBufferAsync(aOptions, cb)
        else
          @_getStreamAsync(aOptions, cb)
      getContents: (aOptions, done)->
        if isFunction aOptions
          done = aOptions
          aOptions = read: true
        @defaults aOptions
        cb = (err, result)->
          if aOptions.skipSize and isBuffer result
            result = result.slice(aOptions.skipSize)
          done(err, result)
        result = @load(aOptions, cb)
        if isBuffer(result) and aOptions.skipSize
          result = result.slice(aOptions.skipSize)
        result

    module.exports = File
