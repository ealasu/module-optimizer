gulp = require 'gulp'
gutil = require 'gulp-util'
plugins = do require 'gulp-load-plugins'
rimraf = require 'rimraf'
runSequence = require 'run-sequence'

gulp.task 'clean', (cb) ->
  rimraf './lib', cb

gulp.task 'test', ->
  gulp.src './test/**/*.coffee',
    cwd: __dirname
    read: false
  .pipe do plugins.plumber
  .pipe plugins.mocha
    reporter: 'list'

gulp.task 'coffee', ->
  gulp.src './src/**/*.coffee',
    cwd: __dirname
  .pipe plugins.coffee
    bare: true
  .on 'error', gutil.log
  .pipe gulp.dest './lib/'

gulp.task 'dist', ->
  runSequence(
    'clean'
    'test'
    'coffee'
  )

