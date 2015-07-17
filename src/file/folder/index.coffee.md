---
name: Folder
type: script/coffee
author: riceball
license: MIT
---

Summray
=======

the Folder information class inherits from File.

    File            = require '../'
    inherits        = require 'inherits-ex'
    fs              = require 'graceful-fs'
    createObject    = require 'inherits-ex/lib/createObject'
    bufferDirSync   = require '../contents/buffer-dir-sync'
    bufferDir       = require '../contents/buffer-dir'
    ReadDirStream   = require 'read-dir-stream'
    Promise         = require 'bluebird'

    fsstat      = Promise.promisify fs.stat, fs
    fsreaddir   = Promise.promisify fs.readdir, fs

    ReadDirStream::_stat = fs.stat
    ReadDirStream::_readdir = fs.readdir

    class Folder
      inherits Folder, File

      constructor: (aOptions)->
        return new Folder(aOptions) if not (@ instanceof Folder)
        super
      createFileObj: (options)->
        stat = options.stat
        options.cwd = @cwd
        vClass = if stat and stat.isDirectory() then Folder else File
        createObject vClass, options
      _validate: (file)->
        file.stat? and file.stat.isDirectory()
      _getStreamSync: (aFile)->
        ReadDirStream aFile.fullPath, makeObjFn: =>@createFileObj.apply(@, arguments)
      _getBufferSync: (aFile)-> # return the array of files
        bufferDirSync aFile, fs.readdirSync, fs.statSync, @createFileObj.bind(@)
      _getStreamAsync: (aFile, cb)->
        result = ReadDirStream aFile.fullPath, makeObjFn: =>
          @createFileObj.apply(@, arguments)
        cb(null, result)
      _getBufferAsync: (aFile, cb)-> # return the array of files
        makeObj = =>@createFileObj.apply(@, arguments)
        bufferDir aFile, fsreaddir, fsstat, makeObj, cb


    module.exports = Folder
