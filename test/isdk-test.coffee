chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

#isdk            = require '../src/'
setImmediate    = setImmediate || process.nextTick

describe "isdk", ->
