
parsers         = require './gray-matter'
module.exports  = Config  = require 'load-config-file'
try cson        = require 'cson'
try toml        = require 'toml'

Config.register ['.yml', '.yaml'], parsers.yaml
Config.register '.cson', parsers.cson if cson
Config.register ['.ini', 'toml'], parsers.toml if toml
Config.register '.json', parsers.json
