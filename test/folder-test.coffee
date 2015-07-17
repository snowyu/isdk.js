chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

Folder            = require '../src/file/folder/'
path              = require 'path.js'
setImmediate      = setImmediate || process.nextTick

fileBehaviorTest = require './abstract-file'
loadContentTest = fileBehaviorTest.loadFolderContent

describe 'ISDKFolder Class', ->
  beforeEach ->
    @File = Folder
    @canLoadStatAsync = true
    @contentPath = 'fixtures/folder/'
    @loadContentTest = loadContentTest
    @content = [ 
      'fixtures/folder/.ignore'
      'fixtures/folder/index.md'
      'fixtures/folder/my.cofffee'
      'fixtures/folder/subfolder1'
      'fixtures/folder/subfolder2'
    ]

  fileBehaviorTest()

  it 'should create a folder object via constructor function directly', ->
    dir = Folder(path.join __dirname, 'fixtures', 'folder')
    cfg = read:true
    #dir.load(cfg)
    #console.log JSON.stringify(dir,null,1)
