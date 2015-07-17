---
name: AbstractFile
type: script/coffee
author: riceball
license: MIT
---

Summray
=======

the abstract file information class inherits from
[Virtual File](https://github.com/wearefractal/vinyl).

* path: the file path.
* contents *(Buffer|Stream)*
* history *(array)*: record path change
* dirname: Gets and sets path.dirname for the file path.
* basename
* extname
* isBuffer(): whether contents is buffer
* isStream(): whether contents is stream
* isNull(): whether contents is null
* isDirectory(): whether it is directory.
* clone(): return a new clone File instance include contents.
* pipe(stream)
* inspect(): Returns a pretty String interpretation of the File. Useful
  for console.log.
* should be move to vinyl-fs?
  * cwd
  * base
  * stat
  * relative: Returns path.relative for the file base and file path.

These above are the attributes and methods of VirtualFile.

* skipSize *(number)*: the skipped length from beginning of contents.
  this could get the contents quickly later.

These above are the attributes of ISDKFile extends.

* _loadStatSync: load file stat from fs.
* _loadContentSync
* _loadStatAsync (optional)
* _loadContentAsync (optional)

your should implement these methods above.

* load():
  * loadSync()
  * loadAsync()
* loadContent()
  * loadContentSync()
  * loadContentAsync()

---------

    inherits      = require 'inherits-ex/lib/inherits'
    inheritsObject= require 'inherits-ex/lib/inheritsObject'
    isUndefined   = require 'util-ex/lib/is/type/undefined'
    isObject      = require 'util-ex/lib/is/type/object'
    isString      = require 'util-ex/lib/is/type/string'
    isFunction    = require 'util-ex/lib/is/type/function'
    isBoolean     = require 'util-ex/lib/is/type/boolean'
    extend        = require 'util-ex/lib/extend'
    defineProperty= require 'util-ex/lib/defineProperty'
    path          = require 'path.js'
    VFile         = require 'vinyl'
    setImmediate  = global.setImmediate or process.nextTick

    module.exports = class AbstractFile
      inherits AbstractFile, VFile

      constructor: (aOptions)->
        if isString aOptions
          aOptions = path: aOptions
        else if not aOptions?
          aOptions = {}
        #aOptions.cwd?= process.cwd()
        cwd = aOptions.cwd = path.resolve aOptions.cwd
        if vPath = aOptions.path
          vPath = path.resolve cwd, vPath
          aOptions.path = vPath #path.relative cwd, vPath
        super
        @skipSize = aOptions.skipSize if aOptions and aOptions.skipSize
        throw new TypeError('path must be exist') unless @path?
      fullPath: (aOptions)->
        aOptions = @ unless aOptions
        vPath = aOptions.path
        if not vPath and aOptions.history and aOptions.history.length
          vPath = aOptions.history[aOptions.history.length-1]
        vPath = '' unless vPath
        cwd = aOptions.cwd
        cwd?= ''
        if aOptions.base and aOptions.base != cwd
          aOptions.cwd = cwd = path.resolve cwd, aOptions.base
        path.resolve cwd, vPath

      defaults: (aOptions)->
        aOptions = {} unless isObject aOptions
        extend aOptions, @, (k,v)->
          !aOptions.hasOwnProperty(k) or (k in ['cwd', 'base', 'history'])
        aOptions.path = @path
        aOptions.fullPath = @fullPath aOptions
        #if not (aOptions instanceof VFile)
        #  inheritsObject aOptions, @constructor
        aOptions

load file information from file system. check the file.stat whether exists.

      #_loadStatSync: (aOptions)->
      #_loadContentSync: (aOptions)->
      loadContentSync: (aOptions)->
        if isFunction(@_loadContentSync)
          aOptions = @defaults aOptions
          @_contents = @_loadContentSync aOptions
        else
          throw new TypeError 'loadContentSync not implemented'
      loadSync: (aOptions) ->
        if isFunction(@_loadStatSync)
          aOptions = @defaults(aOptions)
          @stat = @_loadStatSync(aOptions) unless @stat?
          @validate()
          if aOptions.read and @stat? and !@contents?
            @loadContentSync(aOptions)
          else
            @contents
        else
          throw new TypeError 'loadSync not implemented'
      _loadStatAsync: (aOptions, done)->
        if @_loadSync
          setImmediate =>
            try
              @_loadSync(aOptions)
              done()
            catch e
              done(e)
            return
        else
          done(new TypeError '_loadStatAsync not implemented')
        @
      _loadContentAsync: (aOptions, done)->
        if @_loadContentSync
          setImmediate =>
            try
              result = @_loadContentSync(aOptions)
              done(null, result)
            catch e
              done(e)
            return
        else
          done(new TypeError '_loadContentAsync not implemented')
        @
      loadContentAsync: (aOptions, done)->
        if isFunction aOptions
          done = aOptions
          aOptions = null
        aOptions = @defaults(aOptions)
        @_loadContentAsync aOptions, (err, result)=>
          @_contents = result unless err
          done(err, result)
          return
      loadAsync: (aOptions, done) ->
        if isFunction aOptions
          done = aOptions
          aOptions = null
        aOptions = @defaults(aOptions)
        unless @stat?
          @_loadStatAsync aOptions, (err, result)=>
            @stat = result
            if !err
              try @validate() catch err
            return done(err) if err
            if aOptions.read and result? and !@contents?
              @loadContentAsync(aOptions, done)
            else
              done(null, @contents)
            return
        else if aOptions.read and !@contents?
          @loadContentAsync(aOptions, done)
        else
          done(null, @contents)
        @
      load: (aOptions, done) ->
        if isFunction aOptions
          done = aOptions
          aOptions = null
        if isFunction done
          @loadAsync(aOptions, done)
        else
          @loadSync(aOptions)
      loadContent: (aOptions, done)->
        if isFunction aOptions
          done = aOptions
          aOptions = null
        if isFunction done
          @loadContentAsync(aOptions, done)
        else if isFunction @loadContentSync
          @loadContentSync(aOptions)
      _validate: (aOptions)->
        aOptions.stat?
      validate: (aOptions, raiseError)->
        if isBoolean aOptions
          raiseError = aOptions
          aOptions = null
        aOptions = @defaults(aOptions)
        result = @_validate aOptions
        if raiseError and not result
          throw new TypeError @name+': invalid path '+aOptions.path
        result
      isValid: (aOptions)->
        @Validate(aOptions, false)
