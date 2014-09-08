fs = require 'fs'
path = require 'path'

module.exports = (name, dirpath) ->
  # only look at relative paths
  if name.slice(0, 1) == '.'
    filepath = path.join dirpath, name
    if fs.existsSync(filepath) and fs.statSync(filepath).isFile()
      return filepath
  return null
