# 为什么会有ISDK

简单的说，[ISDK][isdk] 是一个build系统，类似于[Grunt][grunt], [Gulp][gulp].
ISDK的主要灵感来自于[Gulp4][gulp4]。[Gulp4][gulp4]由一个简单的任务管理系统和
流式文件处理系统（管道处理）构成。它极好的阐述了KISS(Keep It Simple and Stupid)原则。

我简单谈下我自己对KISS的理解。对KISS原则的两个S的理解:

* `Simple` : 简单
  * 看上去很`简单` ，让功能简单到让人一目了然，看着例子就能上手，甚至看上去有点傻
  * 使用上很`简单` ，考虑了各种情况，让人使用起来不至于抓狂。
  * 代码上很`简单` ，这个简单还表现在函数的代码行数不能过多，每一个模块，每一个函数功能尽量职责单一
* `Stupid` : 傻
  * 这个`傻` 绝不是说，写的函数代码对功能职责思虑不周，而导致在某些情况下无法使用
  * 这个`傻` 是指使用者，哪怕 `傻子` 也明白是怎么回事。这里的 `傻` 并不是贬义词。
  * 记得以前最早智能相机出现的时候，被人们亲切的称为“傻瓜相机”是一个道理。
  * 傻即简单
    * 使用简单
    * 阅读简单
    * 理解简单
  * 我自己更愿意用 `Smart` 来代替 `Stupid`


[Gulp4][gulp4]的主体代码几乎没有，都是引用的模块的功能，但是模块的命名那个叫抽象得，不进去
看README文件了解，你完全没头脑。

下面是我用Coffee-script重写的Gulp4主体代码,其中的变量命名我也改成更易于理解的名字:

```coffee
TaskManager = require('undertaker')
virtualFileSystem = require('vinyl-fs')

class Gulp
  inherits Gulp, TaskManager # Gulp类继承自TaskManager

  src: virtualFileSystem.src # 源文件过滤函数，返回Readable/Duplex Stream.
  dest: virtualFileSystem.dest # 指定目标目录，返回Readable/Writable stream.
  symlink: virtualFileSystem.symlink
  watch: (glob, options, task)->
    #...做了一些调用参数检查
    return virtualFileSystem.watch(glob, options, task)
  Gulp: Gulp

module.exports = new Gulp()
```

非常漂亮的代码，虽然看上去它什么也没有干，是不是有点**傻**的感觉。

现在，再来说说[Gulp4][gulp4]的不足（主要从开发者的角度）:

* 无法看到里面的目录结构，你能看到的只是文件。只能通过`src()`函数设定不同的文件过滤器。
* vinyl-fs的抽象程度不够，仅满足于src的文件。不支持文件夹(目录)。
  * 我提了个PR, coffee写的，尽管他说他们内部也在用coffee。但public上他们只用js.
  * 我就干脆自己彻底重写了: [abstract-file][abstract-file]
* undertaker任务管理器的任务是无参数的，无法传递参数进去。设定任务间分享数据的方式也不很讨喜。
  * 无法复用，提了个Issue无果：觉得需要参数的任务是天方夜谭。
  * 这也只得自己写了: [task-registry][task-registry] 支持参数对象以及同步和异步执行。
* 仅支持异步处理，有的任务（不涉及IO的）用同步处理方式反而更快，当不在乎性能的时候，同步代码开发更便捷。
* 仅支持流式管道处理方式，对于不熟悉stream的开发者会感觉测试跟踪无处着手。
* 从开发者的角度来看，Gulp4主代码非常干净，一目了然。但是从使用者的角度来看，要使用它
  还是有较高的门槛。尤其是对非开发人员使用更为艰难。

# 什么是ISDK

从开发者的角度来说，我希望ISDK能解决上述的痛点。这个毋庸多说。

下面主要从用户（非开发人员）角度来谈谈ISDK。它的核心亮点是：用文档表示配置，用目录树表示继承树。

它的以下特点，得以区别于其它buiding系统。

* 用Markdown([front-matter][front-matter])文档的方式来写任务及管理
  * 文档即配置，配置即程序
  * 无缝building继承(只需要将其它building文档复制或者链接到其子目录下)
* 简单完整自洽系统
* 层级(树形)任务插件管理机制
  * 支持同步或者异步执行
* 抽象文件资源管理机制
  * 支持虚拟目录
  * 支持虚拟内容(未实现)
* 文档约定配置
* 目录树继承配置

ISDK的作用在于遍历源文件夹，根据不同的文件执行不同的处理任务。最后输出到指定的目标目录。
它的工作就是围绕一个文件夹进行展开处理。这个文件夹称之为 `cwd` (current working directory-当前工作目录)。

简而言之，ISDK用我们对文件夹及文件的默认[markdown][markdown]文档约定来描述配置，而不是什么特别的配置文件。

不知道大家是否还记得在github的项目中根目录下的 `README.md`, 这个文件用来描述该项目的名称，功能简介，以及注意事项。
所以将目录下的 `README.md` 视为该目录的配置文件就理所当然了。通过[front-matter][front-matter]我很简单的
把配置放进了[markdown][markdown]文件。而这些配置项可以被下属的文件(目录)继承或者改变。

ISDK的配置文件分为两类：目录(文件夹)配置和普通文件配置，

* 文件夹配置将影响该目录下的所有文件以及子目录。
  * 子目录也可以有自己的配置文件，影响子目录下的所有文件，里面的配置项可以继承或者覆盖父目录的配置项。
  * 支持虚拟目录，具体详见[front-matter-markdown][front-matter-markdown]里的TOC描述。
* 普通文件配置只影响本文件，里面的配置项可以继承或者覆盖父目录的配置项。

它的配置主要指导思想是:

* `文档约定` 配置
* `目录继承` 配置

还是先举一个简单的例子来说明。简单假设我们只支持yaml配置格式(扩展名为:".yml")。
文件夹的配置文件名称为"README.md"，内容如下。

其中文件头为[yaml][yaml]配置:

```yaml
---
dest: ./output
src: # 源文件只包括*.md文件，目录以及.a目录, 并且不包括".b"目录
  - "**/*.md"
  - "**/" #允许子目录，目前是对下属目录和文件都用src进行匹配，所以 "**/*.md"会拒绝目录。
  - "!**/node_modules" #ignore node_modules
  - "!**/.*" #ignore .*
  - "!./output" #ignore the output dir.
tasks:
  - mkdir
  - echo
  - template
  - copy:
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

接着是Markdown文本对本项目的描述。

```
# Summary

该文件主要描述本文件夹的内容和配置。

## 配置项说明

* dest *(String)*: 指定目标目录，本文档目标目录设置在当前工作目录下的output目录。
  如果不指明，默认为"./public"目录（可选）。
* cwd *(String)*: 重新指定当前工作目录（可选），注意：该参数只能用于项目的根配置中。
* src *(String|Array String)*: 源文件过滤器
  * 首字母为“!”表示不匹配。注：顺序很重要，如果第一个就是不匹配，那么后面的匹配项全部失效。
  * `"**"` 表示匹配任意子目录
* tasks: 执行的任务列表，任务按照列表中的出现顺序，依次执行，任务只针对文件(非目录)进行。
  * force *(Boolean)*: 当执行任务的过程中出现错误是否强制继续执行下去。
    默认为false.
  * raiseError *(Boolean)*: 是否抛出错误异常，显示错误出现的代码行数。供开发调试用。
    默认为false.
* logger: 日志输出的参数
  * level *(String|Number)*: 输出的级别有:
    * SILENT(-1): 安静
    * EMERGENCY(0): system is unusable
    * ALERT(1): action must be taken immediately
    * CRITICAL(2): the system is in critical condition
    * ERROR(3): error condition
    * WARNING(4): warning condition
    * NOTICE(5): a normal but significant condition
    * INFO(6): a purely informational message
    * DEBUG(7): messages to debug an application  
    * TRACE(8): messages to trace an application
  * enabled *(Boolean)*: 是否开启日志输出。默认为true.

## 任务说明

* [mkdir][mkdir] 任务: 创建目录任务，类似 `mkdir -p`.
  * dest *(String)*: 待创建的目录.
* [echo][echo] 任务: 示例额任务，把输入参数直接返回。源代码在: src/tasks/echo.coffee
  * 你可以在这里测试任务参数。
* [template][template] 任务: 如果没有指定engine，则使用默认的模板引擎(第一个注册的引擎)处理文件。
  * engine *(String)*: 指定模板引擎名称(可选).
  * `...`: 其它特定的引擎参数(可选).
* [copy][copy] 复制: 文件复制任务，将文件复制到指定的目录中。
  * dest *(String)*: 设定目标文件夹或者文件名.
  * overwrite *(Boolean)*: 是否覆盖已存在的目标文件.默认为false。

**注意:**: 如果没有指定任务的参数，那么默认传递给任务的参数就是该文件对象。
```

该文件的完整演示在：[isdk-demo][isdk-demo]。

*问题*:

1. 对于只希望在本文件中执行一次,不希望后代执行的任务如何处理为佳？
   更进一步抽象为不希望后代继承的属性如何表现？
   * 可以考虑给属性加个前缀区分，那么到底哪一个是默认(个人倾向于供本文件使用的默认):
     1. 增加前缀"!"表示该属性仅供本文件使用
     2. 增加前缀">"表示该属性仅供后代使用
     3. 如何表示供本文件以及后代使用？(或者这个是默认)
2. 在[resource-file][resource-file]中，我过滤了文件夹和文件的配置文件，文件的配置
   文件过滤是没有问题的，但是对于文件夹的配置文件当需要被输出的时候(比如website的index.html)，
   该如何处理？
   * 只能将content（来自于[front-matter][front-matter]）作为处理对象，执行仅供本文件使用的任务。
     * 需要在[resource-file][resource-file]中将content(非枚举)属性导入。
3. 现在文件模板任务默认处理整个文件了(除非设置skipHeader为真)。但是如果文首的[front-matter][front-matter]
   配置被模板更新后，如何刷新该文件的配置?
   * add setContents method to [abstract-file][abstract-file].
   * override the setContents on the [resource-file][resource-file].
     * TODO: update virual folders too...
   * 注意，我将配置项直接合并在文件对象中，好处是可以动态修改文件的配置，但是记住它无法动态感知配置项的删除。

## 主代码

最核心的部分被视为一个ISDK任务执行，ISDK任务只支持yaml配置，而其它配置格式的支持，需要用户自行注册。
ISDK任务上没有任何其它任务注册，它的作用是加载配置，遍历文件以执行任务。

```coffee
ISDKTask = require 'task-registry-isdk' #register the isdk task
isdkTask = ISDKTask()
isdkTask.executeSync cwd: '.', src:['**/*.md', '**/']
```

----
sorry, 这个[isdk][isdk]还没有写，不过可以参考 [isdk-demo][isdk-demo]的src目录下的代码。
这个可以认为是isdk的原型简化版本。在lib目录下是Coffee-script编译后的js代码。如果已经安装了
Coffee-script,可以执行 npm run coffee-build 进行编译。

运行方式, 在项目根目录下:

1. 不必编译，直接执行`coffee src/` 运行,如果已经安装了Coffee-script。
2. 还可以运行 `node lib/index.js`，执行编译后的js版本。
3. 执行 `npm run build`， 其实它调用的就是 `node lib/index.js`, 封装在npm中。


具体可以参见: [isdk][isdk]

安装:

    npm install isdk -g
----

## 目前进度

完成了一半，主体架构大致完成。底层的一些类库完成，最小可执行原型基本完成。现在就告一段落了，再写就离我原本的
智脑项目偏题太远，这些东西在智脑项目中有的会被用上(除了标识为isdk的包，都是通用项目)。

* 辅助函数与类
  * [load-config-file][load-config-file]:完工
  * [load-config-folder][load-config-folder]:完工
  * [front-matter-markdown][front-matter-markdown]: 基本完工
  * [abstract-logger][abstract-logger]: 基本完工，支持loglevel(v0.2).
    * [terminal-logger][terminal-logger]: 基本可用: 在终端显示彩色状态logger，以及单行更新支持。

* 资源文件类
  * [abstract-file][abstract-file]: 完工
    * [custom-file][custom-file]: 完工
      * [resource-file][resource-file]: 同步执行完工，异步写了一半，流没写
        * [isdk-resource][isdk-resource]: 同步执行基本可用

* 任务管理器和任务
  * [task-registry][task-registry]: 基本完工，任务管理器抽象
    * [task-registry-series][task-registry-series]: 基本完工，顺序执行任务列表中的任务
      * [task-registry-isdk-tasks][task-registry-isdk-tasks]: 基本可用
    * [task-registry-isdk][task-registry-isdk-tasks]: 主入口，还在写，勉强可用
    * [task-registry-resource][task-registry-resource]: 抽象任务，服务于Resource-file.
    * [task-registry-file-copy][task-registry-file-copy]: 单个文件复制任务,基本完工
    * [task-registry-file-template][task-registry-file-template]: 文件模板任务,基本完工
    * [task-registry-template-engine][task-registry-template-engine]: 抽象模板引擎类及管理,基本完工
      * [task-registry-template-engine-lodash][task-registry-template-engine-lodash]: lodash模板引擎,基本完工

一点都没做的：

* 事件管理我希望作为一个插件加入，并能支持 ReactiveX.io.
* 终端日志处理任务:我希望作为一种插件能力加入，而不是写死在task-registry中。
  * 目前暂时写在task-registry-series上。
* 封装函数作为task-registry任务
* 封装Gulp和grunt的插件作为task-registry的任务


## `文档约定`配置


所谓`文档约定`，1是指配置文档名称的约定，2是指文档配置一体化的 [front-matter][front-matter] 格式.

* 文件夹配置文件名称
  * INDEX.md  类似Web站点的目录索引文件名称
  * README.md 文件夹的读我文件
* 文件配置文件名称是将文件名去掉扩展名的名称 + 配置格式文件名称的扩展名后缀
  比如，文件："test.exe",它的配置文件可以是 "test.yml"

注意: 支持的配置文件的格式可以根据需要添加到当前项目中。默认支持"yaml"格式。
ISDK会自动搜索支持的配置文件格式，将第一个找到的文件作为该文件的配置。

文档配置一体化的 [front-matter][front-matter]似乎是来自于github的jekyllrb静态站点生成器。
它使得我们可以在markdown文本文件中直接指定配置项。这是一个简单但是很酷的创新。

注意: 如果一个markdown文件同时有[front-matter][front-matter]配置和文件配置，那么[front-matter][front-matter]配置
优先覆盖文件配置（目前没有继承，直接覆盖配置项）。

## `文档继承`配置

`文档继承`配置有二：

1. 文档配置项继承
2. 任务参数继承

### 文档配置项继承

如果配置项的值是一个对象或者数组，那么该值可以继承自父目录的配置值的基础上，增加新内容。

举例来说，

此为父目录的配置:

```yaml
obj:
  a: 1
  b: 2
arr:
  - 'a'
  - 'b'
```

此为目录下的一文件的配置:

```yaml
obj:
  <: # 标识继承父亲的值
    b: 3
    c: 4
arr:
  <: # 标识继承父亲的值
    - 'c'
    - 'd'
```
那么这个文件的实际配置项内容是：

```json
{
  obj: {
    "a": 1,
    "b": 3,
    "c": 4
  },
  arr: ['c', 'd', 'a','b']
}

```

### 任务参数继承

每一个任务都可以有自己的参数对象被传递进任务，如果没有指明，那么该文件的配置对象被传进任务。
在参数中使用继承标志 "<", 可以让这个参数对象继承自文件对象。

```yaml
title: '来自文件配置的标题'
tasks:
  - copy: #复制txt文件到dest目录。
    <: #参数继承模式，该文件的配置参数被继承
      src: #修改src参数为:
        - "**/*.txt"
```

-----

开发趣事:

当我设置了PropertyManager中对对象属性初始值的默认处理凡是为clone方式(避免相互影响)，
而如果用户设置了不能clone的对象作为初始值的时候，就会报错(如console)，错误会很莫名其妙，
我现在的解决方法，在原错误信息上，添加一个错误提示,让他知道如何设置关闭clone方式。
但是对于某些用户自以为属性初始值统统默认是直接赋值，不看文档，那么也会出现错误。
默认设置只能应对一部分情况，所以必须有开关调整，如果开发者单细胞考虑问题，写的代码出问题的
机率就会变得更大。这算是个Stupid的实例。

[grunt]: http://gruntjs.com/
[gulp]: http://gulpjs.com/
[gulp4]: https://github.com/gulpjs/gulp/tree/4.0
[front-matter]: http://jekyllrb.com/docs/frontmatter/
[markdown]: https://en.wikipedia.org/wiki/Markdown
[yaml]: http://yaml.org/
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
