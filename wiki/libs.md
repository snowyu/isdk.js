## Used Libraries

* [mime-types](https://github.com/jshttp/mime-types)
  * 目前暂时用我的分支，已经发了PR。
  * 已经更名为 mime-type 在我自己的仓库里。
  + add the MimeTypes Class to load a custom mime-db.
  + define function: to add a custom mime/extension mapping
  * merge: APIs-guru/node-mime:master
    + glob function to Return all MIME types which matching a pattern
      * For example "*/*", "video/*", "audio/*", ..
      * [spec](http://tools.ietf.org/html/rfc2616#section-14.1)

```coffee
mime = require('mime-types')
mime.default_type = 'UNKNOWN'
mime.lookup('json')             # 'application/json'
mime.lookup('.md')              # 'text/x-markdown'
mime.lookup('file.html')        # 'text/html'
mime.lookup('folder/file.js')   # 'application/javascript'
mime.lookup('folder/.htaccess') # 'UNKNOWN'

mime.extension('application/octet-stream') # 'bin'
mime.mimes['text/x-markdown'].extensions  # [ 'markdown', 'md', 'mkd' ]
```

* [mmmagic](https://github.com/mscdex/mmmagic)
  * An async libmagic binding for node.js for detecting content types by data inspection.

```coffee
Magic = require('mmmagic').Magic
magic = new Magic()
  magic.detectFile 'magic.node', (err, result)->
    throw err if err
    console.log(result)
    # output on Windows with 32-bit node:
    #    PE32 executable (DLL) (GUI) Intel 80386, for MS Windows

#Get mime type for a file:
magic = new Magic(mmm.MAGIC_MIME_TYPE)
magic.detectFile 'magic.node', (err, result)->
  throw err if err
  console.log(result)
  # output on Windows with 32-bit node:
  #    application/x-dosexec

#Get mime type and mime encoding for a file:
magic = new Magic(mmm.MAGIC_MIME_TYPE | mmm.MAGIC_MIME_ENCODING)
magic.detectFile 'magic.node', (err, result)->
  throw err if err
  console.log(result)
  # output on Windows with 32-bit node:
  #    application/x-dosexec; charset=binary

```

### Gulp 4

现在对Gulp的流用法有点感觉了:
首先是汇集文件(Object)的流,参阅 vinyl-fs的src,逐个通过管道传
给下级的流处理。

基本等效于: FileList.forEach (file)-> process(file)

我可以利用src只取第一级的文件列表，不读入文件数据
    `src('*', cwd: process.cwd, read: false)`
尽管有[readdirp](https://github.com/thlorenz/readdirp)可用，但是用gulp自带比较方便些。

* [File Class](https://github.com/wearefractal/vinyl)

Gulp 4 直接派生自 [Undertaker](https://github.com/phated/undertaker).

客户端的编写可以参考 [gulp-cli](https://github.com/gulpjs/gulp/tree/4.0)

Undertaker 是一个简单的异步任务工厂模型，这些任务允许通过串行或者并行的方式执行。

#### 定义一个任务:

```coffee
gulp.task 'init', (done)->
  console.log 'init done', done
  done() if done
```
注意: 所有任务都是无参数的，你可以自己绑定shareData，它的主页上有[说明](https://github.com/phated/undertaker)
or 看这里: src/task/registry
看了它的series执行方式，发现没法子改带参数的任务。它搞了个"now-and-later"包，做了个迭代器(mapSeries)。
然后调用了`async-done`package的asyncDone, 里面做了domainBoundFn(done),如果要加参数就在这里了！！而且
得一层层的加回去。

现在没有参数，只能前期绑定！那就只能这样的形式:
{
  src: 'aPath'
  dest: 'aDestPath'
  root: Resource
  current: Resource
}
每次调用前设置current。这样的结果是没法并行执行了。暂时这样吧，以后想法增加一个参数就好。
或者先用custom-factory 做一个简单的taskMan(task-factory).
好了，搞定了 task-registry.自组织的任务注册管理器。不需要taskman.
还没来得及写 task-registry-series and task-registry-parallel.

#### 执行一个任务

单独执行某个任务可以通过直接获取该函数的方式进行:

```coffee
initTask = gulp.task('init')
initTask (err, result)->
```
注意: 因为是异步的缘故，你必须传递一个回调函数取得结果。

另外还有串行执行(series)，和并行执行多个的方法(parallel)。
```coffee
gulp.series('init') (err, results)->
gulp.series(['init']) (err, results)->
```

### task-registry

[task-registry](https://github.com/snowyu/task-registry.js)

    npm i task-registry --save

```coffee
Task              = require 'task-registry'
register          = Task.register
aliases           = Task.aliases
defineProperties  = Task.defineProperties

class RootTask
  register RootTask

  # (required)the task execution synchronously.
  # the aOptions argument is optional.
  _executeSync: (aOptions)->aOptions.one+1
  # (optional)the task execution asynchronously.
  # the default is used `executeSync` to execute asynchronously.
  #_execute: (aOptions, done)->

class ATask
  register ATask, RootTask # or RootTask.register ATask

class BTask
  register BTask, RootTask # or RootTask.register BTask

aTask = Task '/Root/A' # or
aTask = RootTask 'A'

aTask.execute one:2 # or
RootTask.execute one:2, 'A' # execute the ATask
```

### Front-matter

[gray-matter](https://github.com/jonschlinkert/gray-matter)

    npm i gray-matter --save


### [Layouts](https://github.com/doowb/layouts)

Wrap templates with layouts. Layouts can be nested and optionally use other layouts.

    npm i layouts --save


```coffee
    obj = {abc: {content: 'blah above\n{% body %}\nblah below'}}
    layouts('This is content', 'abc', obj).result.should.eql '''
      blah above
      This is content
      blah below
    '''
    stack =
      'default':
        content: 'default above\n{% body %}\ndefault below'
        data: {scripts: ['main.js']}
        locals: {title: 'Quux'}
      aaa:
        content: 'aaa above\n{% body %}\naaa below'
        data: {scripts: ['aaa.js']}
        locals: {title: 'Foo'}
        layout: 'default'
    layouts('This is content', 'aaa', stack).result.should.eql '''
      default above
      aaa above
      This is content
      aaa below
      default below
    '''
    stack2 =
      'default':
        content: 'default above\n{% foo %}\ndefault below'
        locals: {title: 'Quux'}
      aaa:
        content: 'aaa above\n{% foo %}\naaa below'
        locals: {title: 'Foo'}
        layout: 'default'
    # custom tag:
    layouts('This is content', 'aaa', stack, tag: 'foo').result.should.eql '''
      default above
      aaa above
      This is content
      aaa below
      default below
    '''
    # custom delimiters:
    stack3 =
      'default':
        content: 'default above\n{{ body }}\ndefault below'
        locals: {title: 'Quux'}
      aaa:
        content: 'aaa above\n{{ body }}\naaa below'
        locals: {title: 'Foo'}
        layout: 'default'
    layouts('This is content', 'aaa', stack, layoutDelims: ['{{', '}}']).result.should.eql '''
      default above
      aaa above
      This is content
      aaa below
      default below
    '''
```

## Referenced Libraries

* (mock-fs)[https://github.com/tschaub/mock-fs]
* [gulp4](https://github.com/gulpjs/gulp/blob/4.0/index.js): 版本4任务简单清晰。
  它的插件其实就是针对单个文件的流处理。
  * [gulp-memory-cache](https://github.com/troch/gulp-memory-cache) for Gulp4
  * (https://github.com/phated/undertaker): gulp4派生自这个简单任务管理类
  * src: 直接用的https://github.com/wearefractal/vinyl-fs
  * [lazypipe](https://github.com/OverZealous/lazypipe):
    create a pipeline out of reusable components. Useful for gulp.
  * [gulp-track-filenames](https://github.com/bholloway/gulp-track-filenames)
  * [vinyl File](https://github.com/wearefractal/vinyl): used in gulpjs
  * [gulp-data](https://github.com/colynb/gulp-data)
    * 在文件对象上添加属性data,你可以定制data对象的内容，比直接用gulp-front-matter好
  * [gulp-front-matter](https://github.com/lmtm/gulp-front-matter)
  * [gulp-exec](https://github.com/robrich/gulp-exec)
  * https://github.com/gulpjs/gulp/blob/master/docs/writing-a-plugin/dealing-with-streams.md
    介绍了如何使用File.stream: https://github.com/nfroidure/gulp-svgicons2svgfont/blob/master/src/index.js
    https://github.com/phated/gulp-jade: 是用的File.buffer
    * https://github.com/sindresorhus/gulp-filter: 里面可以过滤，或者恢复一组文件，可以参考。
    * forking stream: https://github.com/gulpjs/gulp/issues/905
      * gulp-mirror, gulp-clone
* [require-dir](https://github.com/aseemk/requireDir)
  require all files in a dir.
* [js-interpret](https://github.com/tkellen/js-interpret)
* [slug](https://github.com/lovell/limax)
  * Currently supports, but not limited to, the following scripts:
  * Latin: e.g. English, français, Deutsch, español, português
  * Cyrillic: e.g. Русский язык, български език, українська мова
  * Chinese: e.g. 官话, 吴语 (converts to Latin script using Pinyin with optional tone number)
  * Japanese: e.g. ひらがな, カタカナ (converts to Romaji using Hepburn)

#### [Template](https://github.com/jonschlinkert/template/blob/master/docs/api.md)

#### [Commander](https://github.com/tj/commander.js)

### Hexo

* Source: inherits From Box and @processors = ctx.extend.processor.list()
  * Box: a container used to processing files in a specified folder.
    * init的时候，会创建一个File类并为它添加一些方法。比如render().
      * 这个render方法会首先读入文件，然后调用 hexo/render.js 去render.
        而hexo/render.js则是去调用extend/render.js这个工厂的方法。
    * There're two boxes in Hexo: `hexo.source` and `hexo.theme`.
  * Load Files:
    * process() : process all files
    * watch() : process all files and watch file changes continuously.
      * call unwatch to stop.
  * Path Matching: Box provides many ways for path matching.
    You can use a regular expression, a function or a pattern
    string like Express.

        ``` plain
        posts/:id => posts/89
        posts/*path => posts/2015/title
        ```
  * addProcessor:

* Processor: A processor is used to process files in `source` folder.
* Collection: 是存放在数据库中的 Model(./models/文件夹).
  * Page, Post
* Render: 将文件内容转换。应该称为compile.
* folders: lib/
  * extend/: 存放各种factory 类.
  * models/: 各种数据库models: Post, Page, Asset...
  * box/: Box Class
  * hexo/: 主程序类
  * plugins/:
  * theme/: class Theme extends Box 和它的processor.

#### generate 的流程

* generate(plugins/console/generate.js)
  * hexo.load() -> firstGenerate -> generateFiles -> route.list()
* hexo.load: 在这里加载 route
  * loadDatabase:
    * hexo/loadDatabase.js: 真的就是加载数据库。然后就接着执行：
    * source.process():  hexo/source.js : see Box/index.js
      * `_loadFiles`: 装入文件名(包括路径)列表
        * 与缓存的文件做比较，分成 create, update(没有看到区分update), deleted 类型
        * `_handleUpdatedFile`: 在这里做了sha散列比较，区分是否update.如果是一样标记类型为skip.
      * `_dispatch`:调用processor 处理文件。
        * 通过检查 processor.pattern 看是否能处理该文件。
        * 如果能处理则给出一个文件对象，调用processor进行处理。
          在processor中如果文件是可以renderable的那么就会执行渲染。当然这个要分具体的processor不同而不同。
          * data: render 为 object.
          * asset:
            * 先判断是否能render
              * 能: processPage
                * 取 fornt-matter 配置, 缓存 content to data.raw
              * 否: processAsset: 设置path，modified并添加到数据库的 Asset.
          * post:
    * theme.process(): theme/index.js
  * `_generate`:
    * execFilter
    * generator.call()
      * factory: extend/generator.js
      * 实际的Item: plugins/generator
* router(hexo/router.js)
  * set()
  * list():
