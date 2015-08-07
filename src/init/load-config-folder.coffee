
extend          = require 'util-ex/lib/_extend'
FileConfig      = require './load-config-file'
module.exports  = Config  = require 'load-config-folder'
frontMatterMarkdown = require 'front-matter-markdown'

markdownExts = [
  '.md', '.mdown', '.markdown', '.mkd','.mkdn'
  '.mdwn', '.mdtext','.mdtxt'
  '.text'
]

Config.addConfig ['_config', 'INDEX', 'README', 'SUMMARY', 'index', 'readme']
Config::configurators = extend {}, FileConfig::configurators
Config.register markdownExts, frontMatterMarkdown
# Config.setFileSystem fs
# Config.register ['.yml', '.yaml'], parsers.yaml
# Config.register '.cson', parsers.cson if cson
# Config.register ['.ini', 'toml'], parsers.toml if toml
# Config.register '.json', parsers.json

###
从markdown文件中的指定的head下的列表获取目录，取代原生目录
# Summary/TOC/Table of content

###
