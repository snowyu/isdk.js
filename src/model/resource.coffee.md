---
name: Resource
type: script/coffee
author: riceball
---

Summray
=======

The Abstract File Resource Class inherited from
[AdvanceFile](https://github.com/snowyu/custom-file.js/blob/master/src/advance.coffee)

The default value of `text` option is true for Resource if possible.

Each resource could have many custom attributes. These attributes could be a
[front-matter](http://jekyllrb.com/docs/frontmatter/) block in the same file,
or as a separate configuration file exists.

The priority is the front-matter > configuration file if they are both exist.

The Resource uses the [Front-matter](https://github.com/jonschlinkert/gray-matter)
to read the file attributes.

The separate configuration file name should be the same basename of the resource.
The following configuration format(extname) supported:

* YAML: .yml
* CSON: .cson
* TOML: .toml, .ini
* JSON: .json


It only supports the separate configuration file if the resource if a folder.
The folder's configuration file name could be:

* _config.(yml|cson|ini|json)
* (index|readme).md

到底处理matter该放在这里，还是放在处理器中，犹豫了很久。
两边似乎都可以，就算放在处理器中，也可以为这个文件对象添加属性。从处理的角度来讲，的确matter是一种处理
文件内容的方式，从文件的角度来讲，它又是对文件操作的扩展，

废弃在资源中使用skipSize，本来的目的是不需要缓存整个内容，只需要记住skipSize,
但是发现如果在配置中已经替换掉了contents那么，这个skipSize反而会导致错误。
还是简单点，后面缓存整个内容。

todo:

+ process in a stream.

-----


    CustomFile    = require 'custom-file'
    File          = require 'custom-file/lib/advance'
    inherits      = require 'inherits-ex/lib/inherits'
    matter        = require 'gray-matter'
    loadCfgFile   = require '../init/load-config-file'
    loadCfgFolder = require '../init/load-config-folder'
    extend        = require 'util-ex/lib/_extend'
    isObject      = require 'util-ex/lib/is/type/object'
    setImmediate  = setImmediate || process.nextTick


    module.exports = class Resource
      inherits Resource, File
      @setFileSystem: CustomFile.setFileSystem

      constructor: (aPath, aOptions, done)->
        return new Resource(aPath, aOptions, done) unless @ instanceof Resource
        super

      _assign: (aOptions, aExclude)->
        vAttrs = @getProperties()
        for k,v of aOptions
          continue if vAttrs[k]? or k in aExclude
          @[k] = v # assign the user's customized attributes

      _updateFS: (aFS)->
        super aFS
        fs = @fs unless fs
        path = fs.path if fs and !path
        return

      # return {data:{title:1}, skipSize: 17, content}
      frontMatter: (aText, aOptions)->
        # return {org:'---\ntitle: 1\n---\nbody', data:{title:1}, content:'body'}
        result = matter(aText, aOptions)
        result.skipSize = aText.length - result.content.length
        result
      loadConfig: (aOptions, aContents, done)->
        if !aOptions.stat.isDirectory()
          vFrontConf = @frontMatter(aContents.toString(), aOptions)
          loadCfgFile aOptions.path, aOptions, (err, result)->
            return done(err) if err
            if vFrontConf and vFrontConf.skipSize
              result = extend result, vFrontConf.data
              #aOptions.skipSize = vFrontConf.skipSize
              result.contents = vFrontConf.content unless result.contents
            done(err, result)
        else
          loadCfgFolder aOptions.path, aOptions, done
      loadConfigSync: (aOptions, aContents)->
        if !aOptions.stat.isDirectory()
          vFrontConf = @frontMatter(aContents.toString(), aOptions)
          result = loadCfgFile aOptions.path, aOptions
          result = {} unless isObject result
          if vFrontConf and vFrontConf.skipSize
            result = extend result, vFrontConf.data
            #aOptions.skipSize = vFrontConf.skipSize
            result.contents = vFrontConf.content unless result.contents
        else
          result = loadCfgFolder aOptions.path, aOptions
        result
      _getBufferSync: (aFile)->
        result = super(aFile)
        conf = @loadConfigSync aFile, result
        extend @, conf
        result = conf.contents unless conf.contents
        result
      _getBuffer: (aFile, done)->
        that = @
        super aFile, (err, result)->
          return done(err) if err
          @loadConfig aFile, result, (err, conf)->
            return done(err) if err
            conf = {} unless isObject conf
            extend that, conf
            result = conf.contents unless conf.contents
            done(err, result)
