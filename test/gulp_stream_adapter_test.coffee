{expect} = require 'chai'
through2 = require 'through2'
gulpStreamAdapter = require '../src/gulp_stream_adapter'

describe 'gulpStreamAdapter', ->

  it 'should work', (cb) ->
  
    stream = through2.obj (chunk, enc, cb) ->
      cb(null, chunk)

    adapter = gulpStreamAdapter stream

    adapter 'x', (err, res) ->
      expect(res).to.equal 'x'
      adapter 'y', (err, res) ->
        expect(res).to.equal 'y'
        cb()

