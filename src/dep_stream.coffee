_ = require 'lodash'
es = require 'event-stream'

module.exports = (options) ->
  {cache, entries} = options

  # trace dependencies, and assign an id to each module
  moduleIds = {} # map of module filepath -> module id
  i = 1

  traceDeps = (moduleFilepath) =>
    return if moduleIds[moduleFilepath]
    moduleIds[moduleFilepath] = i++
    _.each cache.get(moduleFilepath).requires, traceDeps

  _.each entries, traceDeps

  es.readArray _.pairs moduleIds
  .pipe es.map ([moduleFilepath, moduleId], cb) =>
    module = cache.get(moduleFilepath)
    m =
      id: moduleId
      source: module.content.toString()
      deps: _.mapValues module.requires, (v) ->
        moduleIds[v]
    if _.contains entries, moduleFilepath
      m.entry = true
    cb null, m
