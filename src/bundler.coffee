
module.exports = class Bundler

  constructor: (@options) ->
    @cache = @options.cache

  bundle: (bundleFilename) ->
    entryModules = for entryfile in @options.entries
      @cache.getModule entryfile

    # trace deps
    # concat
    # emit final file

