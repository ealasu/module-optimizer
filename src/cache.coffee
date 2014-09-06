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

  addResolver: (fn) ->
    @_resolvers.push fn

  getModule: (filepath, dependencyChain = []) ->
    module = @_cache[filepath]
    if module
      # update dependents
      dependent = _.last dependencyChain
      if dependent
        module.dependents[dependent] = true
      return module

    module = new File
      path: filepath
      contents: fs.readFileSync(filepath)

    @_transform module

    module.dependents = {} # set of filepaths
    module.requires = {} # map of module name -> module filepath
    requires = detective(module.contents)
    if requires
      requires.forEach (r) ->
        module.requres[r] = null

    @_resolve module

    # fill cache
    for own k of module.requires
      requireFilepath = module.requires[k]

      # make sure this isn't a circular dependency
      if requireFilepath in dependencyChain
        throw new Error "circular dependency on module #{requireFilepath}, chain: #{dependencyChain.join(', ')}"

      @getModule requireFilepath, dependencyChain.concat([filepath])

    @_cache[filepath] = module
    @emit 'add', module
    return module

  _transform: (module) ->
    for fn in @_transforms
      fn(module)

  _resolve: (module) ->
    for fn in @_resolvers
      fn(module)

    # make sure all the requires were resolved
    for own k of module.requires
      unResolved = do ->
        filepath = module.requires[k]
        return true if not filepath
        try
          stat = fs.statSync filepath
          return true if not stat.isFile()
        catch ex
          return true
      if unResolved
        throw new Error "unresolved require #{k} from module #{module.path}"

  # purge the whole cache
  purge: ->
    @_cache = {}

  # remove a module from the cache, and
  # recursively remove all of its orphaned dependents
  purgeModule: (filepath) ->
    m = @_cache[filepath]

    # sanity check
    if not m
      throw new Error "tried to purge non-cached module #{filepath}, this should never happen"

    delete @_cache[filepath]

    for own k of m.requires
      requiredModule = @_cache[m.requires[k]]
      delete requiredModule.dependents[filepath]
      if _.isEmpty requiredModule.dependents
        @purge requiredModule.path

