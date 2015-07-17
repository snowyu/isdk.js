chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

File            = require '../src/file/'
isFunction      = require 'util-ex/lib/is/type/function'
path            = require 'path.js'
Stream          = require 'stream'

setImmediate    = setImmediate || process.nextTick

fileBehaviorTest = require './abstract-file'
loadContentTest = fileBehaviorTest.loadFileContent

describe 'ISDKFile Class', ->
  beforeEach ->
    @File = File
    @canLoadStatAsync = true
    @contentPath = 'fixtures/folder/index.md'
    @loadContentTest = loadContentTest
    @content = '''
    ---
    title: 'testTitle'
    ---
    hi, it's a test

    '''

  fileBehaviorTest()
