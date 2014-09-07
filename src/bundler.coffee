_ = require 'lodash'
source = require 'vinyl-source-stream'
pack = require 'browser-pack'
es = require 'event-stream'

module.exports = class Bundler

  constructor: ({@cache, @entries}) ->

  bundle: (bundleFilename) ->
    @_depStream()
    .pipe pack(raw: true)
    .pipe source(bundleFilename)

  _depStream: ->
    # trace dependencies, and assign an id to each module
    moduleIds = {} # map of module filepath -> module id
    i = 1

    traceDeps = (module) ->
      return if moduleIds[module.path]
      moduleIds[module.path] = i++
      for k in Object.keys(module.requires)
        traceDeps @cache.get module.requires[k]

    for entryFilepath in @entries
      traceDeps @cache.get entryFilepath

    es.readArray _.pairs moduleIds
    .pipe es.map ([moduleFilepath, moduleId], cb) =>
      module = @cache.get moduleFilepath
      cb null,
        id: moduleId
        source: module.content.toString()
        deps: _.mapValues module.requires, (v) ->
          moduleIds[v]
        entry: _.contains @entries, moduleFilepath

