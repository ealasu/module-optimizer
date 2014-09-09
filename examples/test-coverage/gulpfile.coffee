gulp = require 'gulp'
istanbul = require 'gulp-istanbul'
optimize = require '../..'

gulp.task 'default', ->
  optimize 'a.js', 'optimized.js',
    transforms: [
      istanbul()
    ]
  .pipe gulp.dest './dest/'

