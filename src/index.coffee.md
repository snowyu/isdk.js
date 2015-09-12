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

    ISDKTask  = require 'task-registry-isdk' #register the isdk task
    module.exports = isdkTask = ISDKTask()

[task-registry]: https://github.com/snowyu/task-registry.js
[task-registry-series]: https://github.com/snowyu/task-registry-series.js
[resource-file]: https://github.com/snowyu/resource-file.js
