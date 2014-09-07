{expect} = require 'chai'
sinon = require 'sinon'
es = require 'event-stream'

depStream = require '../src/dep_stream'

describe 'depStream', ->

  runTest = ({entries, cache, expected}, done) ->
    depStream
      cache:
        get: (k) ->
          throw new Error("unexpected cache.get: #{k}") if not cache[k]
          cache[k]
      entries: entries
    .pipe es.writeArray (err, res) ->
      return done(err) if err
      expect(res).to.deep.equal expected
      done()

  it 'should work', (done) ->
    runTest
      entries: ['a.js']
      cache:
        'a.js':
          contents: new Buffer 'a'
          requires: {}
      expected: [
        id: 1
        source: 'a'
        deps: {}
        entry: true
      ]
    , done

  it 'should work for complex cases', (done) ->
    runTest
      entries: ['a.js']
      cache:
        'a.js':
          contents: new Buffer 'a'
          requires:
            './b.js': 'b.js'
        'b.js':
          contents: new Buffer 'b'
          requires: {}
      expected: [
        id: 1
        source: 'a'
        deps:
          './b.js': 2
        entry: true
      ,
        id: 2
        source: 'b'
        deps: {}
      ]
    , done
