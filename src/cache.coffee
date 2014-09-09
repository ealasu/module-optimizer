fs = require 'fs'
path = require 'path'
{EventEmitter} = require 'events'
_ = require 'lodash'
File = require 'vinyl'
detective = require 'detective'

module.exports = class Cache extends EventEmitter

  constructor: ->
    @_cache = {}
    @_transforms = []
    @_resolvers = []

  addTransform: (fn) ->
    @_transforms.push fn
    @

  addResolver: (fn) ->
    @_resolvers.push fn
    @

  # override this for testing
  _loadModuleContents: (filepath) ->
    fs.readFileSync(filepath)

  get: (filepath, dependencyChain = []) ->
    module = @_cache[filepath]
    if not module
      module = @_loadModule(filepath)
      @_cache[filepath] = module
      @emit 'add', module
    module

  _loadModule: (filepath) ->
    module = new File
      path: filepath
      contents: @_loadModuleContents(filepath)

    @_transform module

    module.requires = {} # map of module name -> module filepath
    requires = detective(module.contents)
    if requires
      requires.forEach (r) ->
        module.requires[r] = null

    @_resolve module

    module


  _transform: (module) ->
    for fn in @_transforms
      fn(module)

  _resolve: (module) ->
    module.requires = _.mapValues module.requires, (v, k) =>
      for fn in @_resolvers
        v = fn(k, path.dirname(module.path))
        break if v?

      # make sure it was resolved
      if not v?
        throw new Error "unresolved require #{k} from module #{module.path}"
      if typeof v != 'string'
        throw new TypeError "require #{k} resolved to a non-string: #{v}"

      v

  # purge the whole cache
  purge: ->
    @_cache = {}

  # remove a module from the cache
  # note that this will not remove any orphaned dependents
  remove: (filepath) ->
    m = @_cache[filepath]

    # sanity check
    if not m
      throw new Error "tried to purge non-cached module #{filepath}, this should never happen"

    delete @_cache[filepath]

