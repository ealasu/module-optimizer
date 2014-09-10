{EventEmitter} = require 'events'
moduleLoader = require './module_loader'

module.exports = class Cache extends EventEmitter

  constructor: (options) ->
    @_cache = {}
    @_load = moduleLoader(options)

  get: (filepath, cb) ->
    module = @_cache[filepath]
    if module
      process.nextTick -> cb(null, module)
    else
      @_load filepath, (err, module) =>
        return cb(err) if err?
        @_cache[filepath] = module
        @emit 'add', module
        cb(null, module)
    return

  # purge the whole cache
  purge: ->
    @_cache = {}

  # remove a module from the cache
  # note that this will not remove any orphaned dependents
  remove: (filepath) ->
    # sanity check
    if not @_cache[filepath]
      throw new Error "tried to purge non-cached module #{filepath}, this should never happen"
    delete @_cache[filepath]

