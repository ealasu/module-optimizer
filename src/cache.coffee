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
    if module
      # update dependents
      dependent = _.last dependencyChain
      if dependent
        module.dependents[dependent] = true
      return module

    module = new File
      path: filepath
      contents: @_loadModuleContents(filepath)

    @_transform module

    module.dependents = {} # set of filepaths
    module.requires = {} # map of module name -> module filepath
    requires = detective(module.contents)
    if requires
      requires.forEach (r) ->
        module.requires[r] = null

    @_resolve module

    # fill cache
    _.each module.requires, (requireFilepath) =>
      # make sure this isn't a circular dependency
      if _.contains dependencyChain, requireFilepath
        throw new Error "circular dependency on module #{requireFilepath}, chain: #{dependencyChain.join(', ')}"

      @get requireFilepath, dependencyChain.concat([filepath])

    @_cache[filepath] = module
    @emit 'add', module
    return module

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

  # remove a module from the cache, and recursively remove any orphaned dependents
  remove: (filepath) ->
    m = @_cache[filepath]

    # sanity check
    if not m
      throw new Error "tried to purge non-cached module #{filepath}, this should never happen"

    delete @_cache[filepath]

    for own k of m.requires
      requiredModule = @_cache[m.requires[k]]
      delete requiredModule.dependents[filepath]
      if _.isEmpty requiredModule.dependents
        @remove requiredModule.path # TODO does this need to be absolute?

