ISDK
======

[ISDK][isdk] is a task execution system base on configuration.
It can be used like [cmake][cmake], [RAKE][ruby-rake], [Grunt][grunt]
and [Gulp][gulp] occasions. It can also be used like [Yeoman] [yeoman]
etc scaffolding generation tools. And more.

The markdown text document is used to represent the task configuration,
and the directory (folder) tree represents the task inheritance.

Its highlights are:

* The markdown readme file in a folder is the configuration of directory.
  * no extra configuration file used.
* The directory tree is the task configuration inheritance tree.

ISDK will traverse the current working directory(`cwd`), perform different tasks
(specfied via the configuration) on each file. Finally, it outputs the results to
a specified destination(`dest`) directory.

Briefly, ISDK uses the default [markdown][markdown] document conventions to describe
the configuration, rather than any special configuration file.

## Features

* It could use the Markdown([front-matter][front-matter]) document to write
  the processing tasks and management.
  * text document is the configuration of tasks.
  * Seamless task inheritance (only need to copy the other task list or link to its subdirectories)
  * Simple and complete self-consistent system
  * Hierarchy (tree) Task plug-in management mechanism
    * Supports synchronous or asynchronous execution
  * Abstract file resource managment mechanism
    * Virtual directory supported
    * Virtual content supported(todo)
  * Document Conventions for The tasks configuration
  * Directory inheritance for the task configuration inheritance


Do you remember the `README.md` file on the directory of each github project.
The file is used to describe the introduction of the folder. And now it's used
to describe the configuration of tasks through [front-matter][front-matter].
These configuration could be inherited or changed via sub-directories(files).

ISDK task configuration file is divided into two categories: the folder(directory)
configuration and the file(non-folder) configuration.

* The folder configuration will affect all the files and subdirectories under that directory.
  * Subdirectories can also have its own configuration file,
    the configuration items are inherited the parent directory, and could be changed here.
  * Virtual directories supported. See the TOC topic in [front-matter-markdown][front-matter-markdown].
* Normal file configuration affects this file itself.
  * the configuration items are inherited the parent directory, and could be changed here.

Let's see an [example][isdk-demo], Suppose we only support the yaml configuration format(extension: ".yml").
The folder's configuration file name is "README.md". The file header is [yaml][yaml] task configuration:


```yaml
---
cwd: ./wiki     # change the current working directory to process.
dest: ./output/ # change the dest directory to output.
src: # the soruce files only include '*.md', directories and '.a' directory, and exclude the ".b" directory.
  - "**/*.md"
  - "**/" # only allow sub-directories.
  - "!**/node_modules" #ignore node_modules
  - "!**/.*" #ignore .*
  - "!./output" #ignore the output dir.
tasks: # execute the tasks one by one order.
  - mkdir # make the dest directory.
  - echo  # just echo input
  - template # apply the cofiguration to the file.
  - copy: # copy the file to the dest folder.
      <: #inherited params
        overwrite: false
  - echo:
      hi: 'this a echo string'
logger:
  level: debug
overwrite: true
force: false
raiseError: false
```

the following is the markdown text to describe the project.

```markdown
## ISDK Demo

This file shows the isdk building concept and how to process the folder.
It's just a beginning.

The distinguishing features of the ISDK building are:

* Each file are an object. The folder(directory) is a special file object too.
* Each file could have configuration. These configuration items are the additional
  attributes to the file object.
* The index file(`README.md`) of a Folder is the folder's configuration.
* The folder(directory) tree is the inheritance tree of the file object.
  * The configuration of the file or subdirectory inherits from the parent directory.

This demo will process the mardown files("*.md") in the `wiki` folder,
and the text files("*.txt") int the `wiki/text` folder,
use the default template engine - [lodash](https://lodash.com/docs#template).
And copy these files to the `output` folder.
```

### Configuration items

* `dest` *(String)*: The destination directory to output(optional).
  defaults to "./public".
* `cwd` *(String)*: The current working directory to process(optional).
  defaults to '.', this option only for the root folder of project.
* `src` *(String|Array String)*: The source file filter.
  * The first letter "!" indicates a mismatch.
    * Note: The order is important, if the first one is not match, then the latter match all are failed.
  * `"**"` Indicates match any subdirectory
* `tasks`: the task list to execute，task list according to the order they appear, one by one. Only for the files(not directories).
  * `force` *(Boolean)*: whether force to continue even though some error occur.
    default to false.
  * `raiseError` *(Boolean)*: whether throw error exception.
    default to false.
* `logger`: the configuraion options of the logger
  * level: the logging level, defaults to 'error'
* `overwrite` *(Boolean)*: whether overwrite the already exist files. used via [copy][copy] task.
  default to false.

### tasks

* [mkdir][mkdir] task: Create a new directory and any necessary subdirectories at dest path.
  * dest *(String)*: the new directory to create.
* [echo][echo] task: just echo the input options object argument to the result output.
  * you can test the arguments of a task here.
* [template][template] task: Process the contents of a file via the default template
  engine(the first registered template engine).
  * engine *(String)*: the template engine name(optional).
  * `...`: the specified engine options(optional).
* [copy][copy] task: copy the file to the dest.
  * dest *(String)*: the dest folder or file name.
  * overwrite *(Boolean)*: whether overwrite the dest file if it's exist.
    default to false.


**Note:** The default argument(object) passed to the task is this file object if no
specifed the parameter of the task.

A complete demonstration project of this file: [isdk-demo][isdk-demo].

## Main Code

The core part is considered a ISDK task, The ISDK task only supports yaml configuration format.
To support other configurations format, requiring users to register via themself.
The ISDK task is used to load the configuration, traversal file to perform tasks. You should register
the tasks first.

```coffee
ISDKTask = require 'task-registry-isdk' #register the isdk task
isdkTask = ISDKTask()
isdkTask.executeSync cwd: '.', src:['**/*.md', '**/']
```

See [isdk-demo][isdk-demo] for the complete example. you can treat it as a
simplified prototype version of [ISDK][isdk].


### Current progress

* The main structure has been substantially completed.
* The low level libraries has been completed.
* The minimum executable prototype completed.

* helper functions and classes
  * [load-config-file][load-config-file]
  * [load-config-folder][load-config-folder]
  * [front-matter-markdown][front-matter-markdown]
  * [abstract-logger][abstract-logger]
    * [terminal-logger][terminal-logger]

* Resource File classes
  * [abstract-file][abstract-file]
    * [custom-file][custom-file]
      * [resource-file][resource-file] (todo: async and stream)
        * [isdk-resource][isdk-resource]

* Task management and tasks
  * [task-registry][task-registry]: the task manager and abstract task class.
    * [task-registry-series][task-registry-series]
      * [task-registry-isdk-tasks][task-registry-isdk-tasks]
    * [task-registry-isdk][task-registry-isdk-tasks]
    * [task-registry-resource][task-registry-resource]
    * [task-registry-file-copy][task-registry-file-copy]
    * [task-registry-file-template][task-registry-file-template]
    * [task-registry-template-engine][task-registry-template-engine]
      * [task-registry-template-engine-lodash][task-registry-template-engine-lodash]

## TODO

* todos:
  * Event management
  * Terminal Logger Task
    * temporary on the task-registry-series
  * Wrap functions to [task][task-registry]
  * Wrap Gulp and grunt plugins to [task][task-registry]
* *Problems*:
  1. howto represent the non-inheritance attributes?
     1. add the prefix "!" to represent the non-inheritance attribute
     2. add the prefix ">" to represent the attribute is inheritance only(not apply to this file).
     3. howto represent to apply this file and inheritance?(or this is the default?)
  2. The folder's configuration file can not be output to dest directory.


[ruby-rake]: https://github.com/ruby/rake
[cmake]: http://cmake.org/
[grunt]: http://gruntjs.com/
[gulp]: http://gulpjs.com/
[gulp4]: https://github.com/gulpjs/gulp/tree/4.0
[front-matter]: http://jekyllrb.com/docs/frontmatter/
[markdown]: https://en.wikipedia.org/wiki/Markdown
[yaml]: http://yaml.org/
[yeoman]:http://yeoman.io/
[isdk-demo]:https://github.com/snowyu/isdk-demo.js
[isdk]: https://github.com/snowyu/isdk.js
[front-matter-markdown]: https://github.com/snowyu/front-matter-markdown.js
[load-config-file]: https://github.com/snowyu/load-config-file.js
[load-config-folder]: https://github.com/snowyu/load-config-folder.js
[abstract-logger]:https://github.com/snowyu/abstract-logger.js
[terminal-logger]:https://github.com/snowyu/terminal-logger.js
[abstract-file]: https://github.com/snowyu/abstract-file.js
[custom-file]: https://github.com/snowyu/custom-file.js
[resource-file]: https://github.com/snowyu/resource-file.js
[isdk-resource]: https://github.com/snowyu/isdk-resource.js
[task-registry]: https://github.com/snowyu/task-registry.js
[task-registry-series]: https://github.com/snowyu/task-registry-series.js
[task-registry-isdk]: https://github.com/snowyu/task-registry-isdk.js
[task-registry-isdk-tasks]: https://github.com/snowyu/task-registry-isdk-tasks.js
[task-registry-resource]: https://github.com/snowyu/task-registry-resource.js
[task-registry-file-copy]: https://github.com/snowyu/task-registry-file-copy.js
[task-registry-file-template]: https://github.com/snowyu/task-registry-file-template.js
[task-registry-template-engine]: https://github.com/snowyu/task-registry-template-engine.js
[task-registry-template-engine-lodash]: https://github.com/snowyu/task-registry-template-engine-lodash.js
[mkdir]: https://github.com/snowyu/task-registry-file-mkdir.js
[echo]: ./src/tasks/echo.coffee
[template]: https://github.com/snowyu/task-registry-file-template.js
[copy]: https://github.com/snowyu/task-registry-file-copy.js

