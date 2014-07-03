class HandlerMixIn
  handle: (obj, event, fn) ->
    @_handlers = [] if not @_handlers?
    wrapedFn = => fn.apply @, arguments
    @_handlers.push [obj, event, wrapedFn]
    obj.on event, wrapedFn

  removeAllHandlers: (forObj) ->
    for [obj, event, fn] in @_handlers when not forObj? or obj is forObj
      obj.removeListener event, fn
    @_handlers = []

module.exports = {
  HandlerMixIn
}
