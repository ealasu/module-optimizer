
module.exports = class Watcher

  constructor: ({@cache, @bundlers}) ->
    # hook events
    @cache.on 'add', @onAdd.bind @

  onAdd: (filepath) ->
    # watch the file

  onChange: (filepath) ->
    @cache.purge filepath
    # find the bundlers that use this module, and rebundle them

