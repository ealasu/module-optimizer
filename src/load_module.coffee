fs = require 'fs'
path = require 'path'
_ = require 'lodash'
async = require 'async'
File = require 'vinyl'
detective = require 'detective'
gulpStreamAdapter = require './gulp_stream_adapter'

module.exports = moduleLoader = ({transforms, resolvers} = {}) ->
  
  transforms = _.map transforms || [], (t) ->
    if typeof t.pipe == 'function'
      t = gulpStreamAdapter(t)
    t

  transform = (file, cb) ->
    async.eachSeries(
      transforms
      (fn, cb) ->
        fn file, (err, res) ->
          if res?
            file = res
          cb(err)
      cb
    )
  
    
  (filepath, cb) ->

    module = new File
      path: filepath
      contents: moduleLoader.readFile(filepath)

    transform module, ->

    requires = for k in detective(module.contents)
      v = null
      for fn in resolvers
        v = yield from fn(k, path.dirname(module.path))
        break if v?

      # make sure it was resolved
      if not v
        throw new Error "unresolved require #{k} from module #{module.path}"
      if typeof v != 'string'
        throw new TypeError "require #{k} resolved to a non-string: #{v}"

      [k, v]

    # map of require name -> resolved module filepath
    module.requires = _.zipObject requires
    module


# override this for testing
moduleLoader.readFile = (filepath) ->
  fs.readFileSync(filepath)

