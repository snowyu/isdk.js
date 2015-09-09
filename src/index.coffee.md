---
name: ISdk
type: script/coffee
author: riceball
license: MIT
---

Summray
=======

ISDK is a genernal building system.

It basic goals:

* Literal Document
* Convention over configuration
* Simple and self-consistent
* Write in markdown
* Powerful [task-registry][task-registry] mechanism

Main Code:

    program   = require 'commander'
    #Task      = require 'task-registry'
    ISDKTask  = require 'task-registry-isdk' #register the isdk task

    isdkTask = ISDKTask()

    parseList = (val)->val.split(',')

    program.version(require('../package').version)
    program
    .command('build [path]', 'build the current working path(default).', isDefault: true)
    .option('-d, --dest <path>', 'Destination: the directory where ISDK will write files')
    .option('-s, --src <items>', 'the file pattern to match, separate via comma', parseList)
    .action (path, options)->
      path ?= process.cwd()
      options.cwd = path
      isdkTask.executeSync options
    program.parse(process.argv)

[task-registry]: https://github.com/snowyu/task-registry.js
[task-registry-series]: https://github.com/snowyu/task-registry-series.js
[resource-file]: https://github.com/snowyu/resource-file.js
