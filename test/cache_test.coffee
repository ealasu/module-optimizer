require('chai').should()
sinon = require 'sinon'

File = require 'vinyl'
Cache = require '../src/cache'

describe 'Cache', ->

  build = (files) ->
    cache = new Cache
    if files
      cache._loadModuleContents = sinon.stub()
      for own k of files
        cache._loadModuleContents.withArgs(k).returns new Buffer(files[k])
      cache.addResolver (name) -> name
    cache

  describe 'get', ->

    it 'should work for simple cases', ->
      cache = build
        'a.js': 'a'

      a = cache.get 'a.js'
      a.should.be.an.instanceof File
      a.path.should.equal 'a.js'
      a.contents.toString().should.equal 'a'

      a2 = cache.get 'a.js'
      a2.should.equal a

    it 'should work for nested modules', ->
      cache = build
        'a': 'a'
        'b': 'require("a");'
        'c': 'require("a"); require("b");'

      a = cache.get 'a'
      a.should.be.an.instanceof File
      a.contents.toString().should.equal 'a'
      a.requires.should.eql {}
      a.dependents.should.eql {}

      b = cache.get 'b'
      b.should.be.an.instanceof File
      b.contents.toString().should.equal 'require("a");'
      b.requires.should.eql {'a': 'a'}
      b.dependents.should.eql {}

      c = cache.get 'c'
      c.should.be.an.instanceof File
      c.contents.toString().should.equal 'require("a"); require("b");'
      c.requires.should.eql {'a': 'a', 'b': 'b'}
      c.dependents.should.eql {}

      a2 = cache.get 'a'
      a2.should.equal a
      a2.dependents.should.eql {'b': true, 'c': true}

      b2 = cache.get 'b'
      b2.should.equal b
      b2.dependents.should.eql {'c': true}


  describe 'remove', ->

    it 'should work', ->
      cache = build
        a: 'a'

      a = cache.get 'a'
      a.should.be.ok

      cache.remove 'a'

      a2 = cache.get 'a'
      a2.should.be.ok
      a2.should.not.equal a

  describe 'purge', ->

    it 'should work', ->
      cache = build
        a: 'a'

      a = cache.get 'a'
      a.should.be.ok

      cache.purge()

      a2 = cache.get 'a'
      a2.should.be.ok
      a2.should.not.equal a

