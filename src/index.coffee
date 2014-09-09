_ = require 'lodash'
Cache = require './cache'
bundle = require './bundler'
relativeFileResolver = require './resolvers/relative_file'

module.exports = (entries, filename, options) ->

  cache = new Cache
    resolvers: [relativeFileResolver].concat(options?.resolvers)
    transforms: options?.transforms

  return bundle
    cache: cache
    entries: _.flatten [entries]
    filename: filename

