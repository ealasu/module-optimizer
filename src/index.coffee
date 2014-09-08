_ = require 'lodash'
Cache = require './cache'
bundle = require './bundler'
relativeFileResolver = require './resolvers/relative_file'

module.exports = (entries, filename, options) ->

  cache = new Cache()
    .addResolver relativeFileResolver

  if options?.transforms?
    _.each options.transforms, cache.addTransform.bind(cache)
  if options?.resolvers?
    _.each options.resolvers, cache.addResolver.bind(cache)

  return bundle
    cache: cache
    entries: _.flatten [entries]
    filename: filename

