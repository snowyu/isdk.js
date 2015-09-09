isdk Processor 生成系统
=====================

isdk 是文档/代码内容产生系统，它设想的目标如下：

目标
----

* 约定大于配置
* 简单易用
* 自洽系统(jsBlog 应用本身就是用这套系统产生的)
* Markdown文档格式
* 模板/皮肤支持
* 生成响应式文档站点
* 生成HTML5应用
* 多语言支持

模式
----

* 开发模式: 本地服务器，及时预示。
* 生产模式："编译"、优化发布静态博客web站点
* 脚手架: 新建博客站点, 新建页面...

子系统
------

* 内容转换/编译系统 see /src
* Markdown 文档格式转换系统(扩展支持响应式指令)
* 响应式指令库: https://github.com/snowyu/angular-reactable

处理流程
-------

处理流程分为三个阶段:

1. 配置阶段 Configurator(FrontMatterConfigurator): 遍历文件，读入参数
2. 编译阶段 Compiler: 允许多遍编译
3. 链接阶段 Linker

这样，我们需要三个工厂: 配置器工厂, 编译器工厂，链接器工厂
或者是一个工厂: 处理器工厂，然后是三个子工厂。

内部工作流程

1. 初始化
  1. 默认设置
     * 注入 File 类增加方法。
  1. load 默认内置插件
  1. load 根目录下的配置文件(根配置)
  1. load external 插件:
    * 加载在package.json(npm)中isdk-plugin-xxxx包。
    * 或者加载配置文件中的(index/reamde.md)
    * loadModules(see also)
1. 配置阶段
  1. 遍历文件和文件夹:
    存放方式: wFiles[File.relative]=File
    File.relative是相对路径。
    如果是目录那么 relative path(File.relative) 最后一个字符强制加上‘/’.


内置插件
------

* Processor 根处理者工厂
  * process the file or the folder.
  * determine the file or folder whether can be processed via it.
    * howto determine which files the processor can processed?
    * pattern: the file pattern?
    * type: the file type?
    * configuration:
      * path
      * name|identifier|slug
      * title|subject
      * type: the file type is the mime-type.
      * tags
      * language
  * manage sub-processors
    * ISDKProcessor 启动者。
    * Configurator 工厂
    * Compiler 工厂
    * Linker 工厂
* FrontMatterConfigurator

现在已经不存在 Processor 工厂了，只有task-registry.
所有的处理装置都放在task-registry.

任务划分
-------

* init
* config
* compile
* link

可以分为初始化阶段，配置阶段，编译阶段，和链接阶段。
在初始化阶段，完成一些内部的组件配置工作，和处理cwd目录无关的前置任务。
在配置阶段，对cwd(当前工作目录)的各种配置加载到内存。
目前根目录的配置已经可以加载，但是还要处理旗下子目录的配置。
各个阶段，是否事件化，还没有想明白。目前初始化阶段也只是个提法。
只要引用在init目录中的库包，相应的初始化工作就已经完成。

配置阶段倒是可以有具体事项可以处理，就是把根目录资源加载后，处理子目录配置
的过程就称为配置阶段。由于资源加载的同时即可加载配置，所以废弃掉 Configurator
工厂的形式，只保留注册新的配置文件格式。或者在这里没有任何的格式，所有配置文件格式的
注册在 `isdk-cli` 中。

配置项的划分:

* 系统配置: 存在于命令行参数和全局配置文件中。影响处理项目的方式，必须在处理项目前载入的
  配置项，可以影响项目根配置文件的加载。
  * 注册新的配置格式
  * 注册新的文件夹配置文件名
* 项目配置: 存在于命令行参数,全局配置文件以及项目配置文件中。无法影响项目根配置文件的加载。

不需要作为processor(factory)来处理这些?先搞一个简单的能run的。
这里面传入的初始参数参数就是系统配置:
* src: 待处理的目录，如果不存在，默认为当前工作目录。
* dest: 最后输出的目标目录。如果不存在，默认为当前目录的public目录。

然后选定所需的编译器和链接器进行处理。先把流程跑通吧。准备将Resource移到新坑(`resource-file`)成为一包。
Ok, `resource-file` 基本可以工作了。

* load(): 加载内容以及配置。通过递归得到所有的目录和文件列表。
  * recursive: load all sub-folders recursively.
  * setPrototypeOf to the parent folder.
  - remove the config file object from the parent's contents(the files list) if exists.
  * convert the config's contents of a folder to the file objects.


在 Resource 中我们得到了所有的目录和文件列表。这时，目录的配置也被加载，
文件的内容和配置没有被加载。下面需要根据目录的类型来决定不同的处理方式。
这里可能会有的问题是，因为文件没有加载，所以无法知道某个文件到底是文件还是
只是文件的配置。

假设没有影响，进入下一阶段：处理阶段。定义处理方式。处理总是针对文件来的。
处理的时候可以针对dest,也可以不。一个文件可以有多个处理方式。
如果是目录，那么可以按照指定的文件名称匹配汇集进行处理。（这种操作叫链接吧）
编译阶段，仅仅是对单个文件处理成目标文件。

编译阶段的:

* 模板替换: 只是对内容做模板替换。可以设置模板引擎。(task/template)
* 合并内容: 将另外一个文件的内容合并在一起。
* 删除: 删除指定的文件(在内存中的)。

无论是更名还是改扩展名，如果数据没有加载那么就是个问题。除非是搞个待做事宜队列排着。
还是将这些操作作为链接阶段吧。

链接阶段的:

* 复制: 复制到指定的文件夹，如果没有指定文件夹则是dest文件夹。
* 追加: 追加到指定的文件。如果没有指定目标文件夹则是dest文件夹。
* 更名：只是更改文件名
* 更扩展名：只是更改文件扩展名

这些处理方式，不就是一个个的任务么？放到任务模块去，然后还可以组合，定义新任务。
任务管理器(task-registry)完成.
好了，编译阶段就实现个模板替换，链接阶段就实现复制。就可以测试了。
编译阶段的任务列表，可以作为配置项放在文件里面。那么链接阶段呢？
放在文件夹里?或者不区分，编译，链接阶段，都是处理阶段。文件夹中多一个过滤器参数(glob?)。
完成了任务顺序执行器: task-registry-series。

处理阶段到底是该内部处理在内存中，还是开始写入到目标目录上？或者说产生的中间文件
该放在哪里？

然后需要一个东西贯穿始终(session?)
初步设想的是传递 ISDKProcessor.

### ISDKProcessor

* args: 命令行参数(应该和config合并，命令行参数优先)
* config: 配置参数

命令行参数通过 constructor 传进来。


系统目录结构
----------

* src/       源代码
* test/      测试
* lib/       编译后的源代码
* themes/    自带的模板
  * default/ 默认模板

Meta 数据
--------

现在资源文件已经可以装入配置文件，并将配置覆盖到自身了。
资源文件的配置信息存在于front-matter或者独立的配置文件中。
如果两者都存在，那么front-matter的优先级最高。

Collection资源(文件夹)配置信息存放于指定的markdown文件中。
目前默认为: "index/readme.md". 为了兼容jekyll,可以考虑
`_config.yml`. 配置信息存放于makedown文件的front-matter
中，正文作为该资源的摘要。如果正文中存在如下的heading信息列表
，那么该列表作为目录替代真实的目录:

```markdown
# Summary/TOC/Table of Content

* [Directory](./dir1)
  * [Directory2](/dir2)
* [Directory3](#inline): 表示该目录就是在摘要内的。

# this is a title {#inline}

```

如何搞这个虚拟目录? 文件夹的内容为文件的列表，如今这个是虚拟文件的列表.
关键是对于内嵌的如何处理？ 另外是否需要移除已经处理的TOC项在摘要中。
需要root了。或者cwd就是root. base是父亲。

```coffee
Folder.Contents = [
  File:
    path: './dir1'
    name: 'Directory'
  File:
    path: '/dir2'
    name: 'Directory2'
  File:
    path: '#inline'
    name: 'Directory3'
]

```


* AbstractResource: 资源分为普通资源、Collection和模板资源，资源的公有属性有:
    * 名称标识: identifier/slug: must be English.
    * 标题: title/subject
    * tags:
    * language:
    * 摘要: summary
    * 内容: content/body
* Resource/Collection
    * 模板: theme/layout/template:
      * [default@]aTemplate
* Template

如果把数据和动作分开那么就可以这样:
是否需要区分模板和content?

* Resource:
    * 名称标识: identifier/slug: must be English.
    * type: unknown, content, category, template, asset
    * 标题: title/subject
    * tags:
    * language:
    * 模板: theme/layout:
      * [default@]aTemplate
    * 摘要: summary
    * 内容: content/body

我现在把资源分为: 内容,参数(fornt-matter),动作(处理方式).


内容和参数存放在缓存中: 只有Content和Category会在缓存中。Asset直接输出。
只有目录才有可能配置为Asset.

* cache.content: 就是文件内容
* cache.config
  * parent: the parent dir
  * filename: 文件名
  * isDir: 物理上它是一个目录或者不是
  * id: 如果没有设置就是文件名
  * name: 如果没有设置就是文件名
  * slug: 如果没有设置就是文件名
  * title: 也是如此，没有设置从文件名取。
  * 如果是category，那么会有:
    * categories: 子目录列表
    * files: 子文件列表
    * assets: 子资产列表,有可能是目录，也有可能是文件

在目录处理的时候必须要知道是内容还是资产.需要一个配置参数?
或者定义如果没有指定的，默认就是内容？如果没有指定，那么
所有处理者均不能处理的内容就被认为是资产。


现在得多一个概念：模板?

模板的用途是为了替换内容中的变量。模板引擎的不同是表示变量的方式不同。
如果没有指定模板引擎，那么就是用系统模板引擎，我用啥作为系统模板引擎？
也可以在内容中控制是否Enable模板引擎.
consolidate 支持各种模板引擎: hogan, mustache, handlebars, ractive 支持
partials：

    res.render('index', {
      partials: {
        part  : 'path/to/part'
      }
    });

另外，对文件格式的处理问题：Markdown, ReStructuredText(ReST), Jade,...

文件格式和模板是混合处理呢？还是单独处理？

1. 方式1:  xxx.md.handlebars
  * 好处是可以串行处理，多次模板处理，但是有必要么？
2. 方式2:
  * 一个文件只能有一种模板引擎, 可以在配置中修改或禁止。
  * 一个文件只有一种处理方式(内容类型)，根据注册的处理器匹配。或者配置。

为了支持partials, 需要首先读入所有的文件和文件夹，然后处理，
如果支持事件回调就好了。没有这样的处理！终于明白了为啥大部分的generator
都要单独搞一个partials目录。为了简化开发，我也得这样了。


如果配置参数有模板，那么就从模板上找。
如果没有模板参数就替换。

补充两个概念: 用户目录和系统目录

动作(处理器)
-----------

内容处理者，对Content进行处理。

是否需要多个处理器对同一文件处理？

### TemplateProcessor


* Template 数据
  * template: 模板引擎，没有指定则根据扩展名而定
  * extname: 处理后扩展名(如果没有指定则根据第二扩展名而定，例如: .html.handlebars), 否则默认 html
  * mime?: text/html 用extname还是mime?




工作流程
-------

1. 从用户根目录获取配置信息.
1. 配置默认模板
   1. 从用户根目录下找模板
   1. 从系统目录下找模板
1. 开始转换
   1. 读入文档目录(首页)
   1. 读入对应的模板文档目录(首页)
   1. 渲染模板，保存到输出目录




用户目录文件结构
---------------

用户目录文件结构如下：

* index.md: 主应用入口，全局配置和站点描述
* documents/: 默认文档目录
  * index.md: 文档首页
  * 子目录:默认定义是文档的子类别，但是你也可以通过配置，来改变默认定义。
    * index.md: 该子目录的配置文件，在这里可以改变它的属性.
* assets/: 默认附加资产文件目录，里面的文件和目录会直接复制到输出目录
* layout/: 默认附加布局文件目录
* public/: 默认输出目录


递归自洽结构
----------

### 目录

* index.md(readme.md)
  * 目录配置文件,配置该目录的类型
  * 作为目录首页

注：子目录配置可以覆盖某些全局配置。


文档类型
-------

* Category: 类别类型
  * 列举出
* Content:  内容类型
  * 程序
  * 文章
* Layout:   模板类型
* Asset:    资产类型，直接输出。


输出的文件
---------

* authors.json
* langs.json
* index.html
* [lang]/index.json: the subdirs and pages info in the current directory.
  * dirs:
    * name/slug:
    * title
    * summary:
    * date
    * count: integer
    * tags:
  * pages:
    * name/slug:
    * title
    * authors
    * date
    * summary:
    * tags:
* [lang]/xxx.html
  * the article content
