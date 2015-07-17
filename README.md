ISDK
======

The scaffolding tool to generate nothing. base on [gulp4](https://github.com/gulpjs/gulp/tree/4.0).

## Concerts

* Data : It's a content or a collection(array).
* Front-matter: a block of YAML, CSON or JSON at the beginning of the file.
* Content/Resource = File
  * Attributes: on a fronter-matter configuration
    * File Name:
    * File Type: determine via file extenstion or a front-matter configuration
* Collection = Folder
  * Attributes: on a front-matter configuration of the index.md file in the folder.
  * Page Collection
    * Post
    * Media(Photo/Video/MP3) Gallery
    * Comment/Discuss/Review
    * Forum
  * View/Presentation Collection
    * Layout
    * Partial(Includes)
    * Javascript
    * Stylesheet
    * media
    * Theme
* Render:
* Router: A router builds routes based on processed files
  * hexo-generator.
* Commander: to manage all console commands.

## Modes

* Development
  Used to run server locally on your computer. This mode allows you to preview your changes in realtime. Note, development mode is not simply the compiled version, it's not an optimized, heavily cached development environment.
* Production
  Used to "compile" and optimize your website in order to publish it on a static-asset web-server.
* Command-line
  Used to pragmatically manage your website and its files, for example quickly creating new pages or layouts.


## Cascade

There are three possible cascade levels of your website that will traverse in search of files.

The obvious one is the root of your website: my-website. Here is the list, in order:

1. System.
   This level is contained in itself. It is how all the default settings and resources are loaded.
2. Theme.
   The installed theme, which is covered in more detail below.
3. my-website.
   This is your base directory.

The cascade searches in these directories in order. This means a file in the theme folder will overload the same file in my-website which in turn will overload the same file in system.


## Themes

A theme is a special collection that acts as an encapsulation namespace.

A theme is a collection so it is defined by a sub-folder. However this sub-folder is dynamically named whatever you want (the name of the theme). Let's say you add the folder twitter-bootstrap and configure it to be your theme folder. Now sub-folders within twitter-bootstrap are discoverable based on the special collection names.

For example:

* twitter-bootstrap/layouts
* twitter-bootstrap/javascripts
* twitter-bootstrap/partials

are all valid places to load and manage these respective collection files.

### Why?

Themes enable a 'plug-and-play' modular architecture. Users are able to create and publish themes which others can freely install without conflicting with existing files.

### Cool Impress Theme

Use left and right, up and down key to navigate throughout site.


## Template

uses the Mustache/Jade templating language to connect your collection data to the template files.

Within the templates and pages, every collection is available globally via their name:

        <ul>
         {{# pages.all }}
           <li><a href="{{url}}">{{title}}</a></li>
         {{/ pages.all }}
        </ul>

        <ul>
         {{# posts/sths.all }}
           <li><a href="{{url}}">{{title}}</a></li>
         {{/ posts/sths.all }}
        </ul>


### Custom Programming

Mustache is used to maintain an extreme separation between programming logic and presentation logic.

Custom programming logic can be added easily via the plugin architecture. You'd simply create module methods and include your module into the appropriate collection.

## Directory Structure

* index.md
* public/       : the default compiled output folder
* documents/    : treated as standalone pages on the site
  * index.md    : the frontpage on the site
* layouts/      : the addtional layout path if any.
* assets/       : the addtional assert path if any.
