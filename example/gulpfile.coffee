gulp = require 'gulp'
Cache = require '../src/cache'
bundle = require '../src/bundler'

gulp.task 'default', ->
  cache = new Cache()
  .addResolver require('../src/resolvers/relative_file')
  bundle
    cache: cache
    entries: ['a.js']
    filename: 'optimized.js'
  .pipe gulp.dest './dest/'

