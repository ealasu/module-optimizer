gulp = require 'gulp'
Cache = require '../src/cache'
bundle = require '../src/bundler'

gulp.task 'default', ->
  cache = new Cache
  bundle
    cache: cache
    entries: ['a.js']
    filename: 'optimized.js'
  .pipe gulp.dest './dest/'

