{EventEmitter} = require 'events'

# Watch files for changes.
# When a file changes or gets deleted, remove it from the cache, and then rebundle all affected bundles.
# When a file gets deleted, or gets removed from the dependency tree, stop watching it.
# When the cache detects a new file, start watching it.
module.exports = class Watcher extends EventEmitter

  constructor: ({@cache, @bundlers}) ->
    # hook events
    @cache.on 'add', @moduleAdded.bind @

  moduleAdded: (filepath) ->
    # watch the file

  moduleChanged: (filepath) ->
    @cache.purgeModule filepath
    @emit 'change', filepath

