_ = require 'lodash'
es = require 'event-stream'

module.exports = ({cache, entries}) ->

  # trace dependencies, and assign an id to each module
  moduleIds = {} # map of module filepath -> module id
  i = 1

  traceDeps = (moduleFilepath) =>
    return if moduleIds[moduleFilepath]
    moduleIds[moduleFilepath] = i++
    _.each cache.get(moduleFilepath).requires, traceDeps

  _.each entries, traceDeps

  # emit the result as a stream, to be consumed by browser-pack
  es.readArray _.pairs moduleIds
  .pipe es.map ([moduleFilepath, moduleId], cb) =>
    module = cache.get(moduleFilepath)
    m =
      id: moduleId
      source: module.contents.toString()
      deps: _.mapValues module.requires, (v) ->
        moduleIds[v]
    if _.contains entries, moduleFilepath
      m.entry = true
    cb null, m
