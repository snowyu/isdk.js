chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

fs                = require('graceful-fs')
path              = require 'path.js'
isObject          = require 'util-ex/lib/is/type/object'
isFunction        = require 'util-ex/lib/is/type/function'
Stream            = require 'stream'
setImmediate      = setImmediate || process.nextTick

###
# usage:
abstractFileBehaviorTest = require './abstract-file'
describe 'File Class', ->
  before ->
    @File = File
  abstractFileBehaviorTest()
###
module.exports = fileBehaviorTest = ->
  testFileOptions = (acturalOpts, expectedOpts)->
    for k,v of expectedOpts
      if v?
        if not isObject v
          acturalOpts.should.have.property k, v
        else
          acturalOpts.should.have.property k
          acturalOpts[k].should.be.deep.equal v
      else
        r = acturalOpts[k]
        assert.equal r?, v?
  describe '.constructor(options|string)', ->
    before ->
      @canLoadStatAsync = true
    it 'should create a file object via path string', ->
      file = @File(__dirname)
      cwd = process.cwd()
      testFileOptions file,
        cwd: cwd
        base: cwd
        path: path.resolve cwd, __dirname
        stat: null
    it 'should throw error if no path provided', ->
      should.throw @File

    it 'should create a file object via cwd,path arguments', ->
      cwd = '/he/llo'
      vPath = 'sayHi'
      file = @File(cwd: cwd, path: vPath)
      testFileOptions file,
        cwd: cwd
        base: cwd
        path: path.resolve cwd, vPath
        stat: null

  describe '#_loadStatAsync(options,done)', ->
    it 'should load a file stat object', (done)->
      cwd = __dirname
      vPath = 'fixtures/folder'
      file = @File(cwd: cwd, path: vPath)
      #if @canLoadStatAsync
      file._loadStatAsync file.defaults(), (err, stat)->
        if not err
          should.exist stat
          stat.should.be.instanceof fs.Stats
        done(err)
      #else
      #  done()
  describe '#_loadStatSync(options)', ->
    it 'should load a file stat object', ->
      cwd = __dirname
      vPath = 'fixtures/folder'
      file = @File(cwd: cwd, path: vPath)
      stat = file._loadStatSync file.defaults()
      should.exist stat
      stat.should.be.instanceof fs.Stats

  describe '#loadContentSync', ->
    it 'should load contents of a file.', ->
      contentsForLoad = @content
      loadContentTest = @loadContentTest
      file = @File cwd: __dirname, path: @contentPath
      contents = file.loadContentSync()
      contents.should.be.equal file.contents
      loadContentTest contents, contentsForLoad
    it 'should load stream contents of a file.', (done)->
      contentsForLoad = @content
      loadContentTest = @loadContentTest
      file = @File cwd: __dirname, path: @contentPath
      contents = file.loadContentSync(buffer: false)
      contents.should.be.equal file.contents
      loadContentTest contents, contentsForLoad, false, done
  describe '#loadContentAsync', ->
    it 'should load contents of a file.', (done)->
      contentsForLoad = @content
      loadContentTest = @loadContentTest
      file = @File cwd: __dirname, path: @contentPath
      file.loadContentAsync (err, contents)->
        if not err
          contents.should.be.equal file.contents
          loadContentTest contents, contentsForLoad
        done(err)
    it 'should load stream contents of a file.', (done)->
      contentsForLoad = @content
      loadContentTest = @loadContentTest
      file = @File cwd: __dirname, path: @contentPath
      file.loadContentAsync buffer:false, (err, contents)->
        if not err
          contents.should.be.equal file.contents
          loadContentTest contents, contentsForLoad, false, done
        else
          done(err)
  describe '#loadContent', ->
    it 'should load contents of a file sync.', ->
      file = @File cwd: __dirname, path: @contentPath
      contentsForLoad = @content
      contents = file.loadContent()
      contents.should.be.equal file.contents
      @loadContentTest contents, contentsForLoad
    it 'should load stream contents of a file sync.', (done)->
      file = @File cwd: __dirname, path: @contentPath
      contentsForLoad = @content
      contents = file.loadContent(buffer: false)
      contents.should.be.equal file.contents
      @loadContentTest contents, contentsForLoad, false, done
    it 'should load contents of a file async.', (done)->
      file = @File cwd: __dirname, path: @contentPath
      contentsForLoad = @content
      loadContentTest = @loadContentTest
      file.loadContent (err, contents)->
        if not err
          contents.should.be.equal file.contents
          loadContentTest contents, contentsForLoad
        done(err)
    it 'should load stream contents of a file aysnc.', (done)->
      file = @File cwd: __dirname, path: @contentPath
      contentsForLoad = @content
      loadContentTest = @loadContentTest
      file.loadContentAsync buffer:false, (err, contents)->
        if not err
          contents.should.be.equal file.contents
          loadContentTest contents, contentsForLoad, false, done
        else
          done(err)

fileBehaviorTest.loadFileContent = (contents, expectedContents, buffer, done)->
  if isFunction buffer
    done = buffer
    buffer = null
  if buffer isnt false
    contents.toString().should.be.equal expectedContents
  else
    contents.should.be.instanceof Stream
    contents.on 'error', (err)->done(err)
    contents.on 'data', (data)->
      data.toString().should.be.equal expectedContents
      done()

fileBehaviorTest.loadFolderContent= (contents, expectedContents, buffer, done)->
  if isFunction buffer
    done = buffer
    buffer = null
  if buffer isnt false
    contents = contents.map (f)->f.relative
    contents.should.be.deep.equal expectedContents
  else
    result = []
    contents.should.be.instanceof Stream
    contents.on 'error', (err)->done(err)
    contents.on 'end', ()->
      result.should.be.deep.equal expectedContents
      done()
    contents.on 'data', (file)->
      result.push file.relative
