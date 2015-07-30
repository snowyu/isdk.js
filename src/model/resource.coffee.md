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


    File          = require 'custom-file/lib/advance'
    inherits      = require 'inherits-ex/lib/inherits'
    matter        = require 'gray-matter'
    loadConfig    = require '../init/load-config-file'
    extend        = require 'util-ex/lib/_extend'
    isObject      = require 'util-ex/lib/is/type/object'
    setImmediate  = setImmediate || process.nextTick


    module.exports = class Resource
      inherits Resource, File
      fs = null
      path = null

      constructor: (aPath, aOptions, done)->
        return new Resource(aPath, aOptions, done) unless @ instanceof Resource
        super

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
      loadFileConfig: (aOptions, done)->loadConfig(aOptions.path, aOptions, done)
      loadFileConfigSync: (aOptions)->loadConfig(aOptions.path, aOptions)
      #loadFolderConfig: -> FolderResource = CollectionResource?
      _getBufferSync: (aFile)->
        result = super(aFile)
        if !aFile.stat.isDirectory()
          frontConf = @frontMatter(result.toString(), aFile)
        conf = @loadFileConfigSync aFile
        conf = {} unless isObject conf
        if frontConf and frontConf.skipSize
          conf = extend conf, frontConf.data
          aFile.skipSize = frontConf.skipSize
        extend @, conf
        result
      _getBuffer: (aFile, done)->
        that = @
        super aFile, (err, result)->
          return done(err) if err
          if !aFile.stat.isDirectory()
            frontConf = @frontMatter(result.toString(), aFile)
          @loadFileConfig aFile, (err, conf)->
            return done(err) if err
            conf = {} unless isObject conf
            if frontConf and frontConf.skipSize
              conf = extend conf, frontConf.data
              aFile.skipSize = frontConf.skipSize
            extend that, conf
            done(err, result)
