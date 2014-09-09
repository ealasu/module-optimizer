{Readable, Writable} = require 'stream'
through2 = require 'through2'

module.exports = (stream) ->
  r = through2.obj()
  w = new Writable()
  r
  .pipe(stream)
  #.pipe(w)

  (file, cb) ->

    bind = ->
      stream.on 'error', onError
      stream.on 'data', onData

    unbind = ->
      stream.removeListener 'error', onError
      stream.removeListener 'data', onData

    onError = (err) ->
      unbind()
      throw err
      cb(err)

    onData = (data) ->
      unbind()
      cb(null, data)

    bind()

    r.push(file)

