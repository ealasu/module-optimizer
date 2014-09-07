source = require 'vinyl-source-stream'
pack = require 'browser-pack'
depStream = require './dep_stream'

module.exports = ({cache, entries, filename}) ->
  depStream {cache, entries}
  .pipe pack(raw: true)
  .pipe source(filename)

