new = (options = {}) ->
  spy =
    called: false
    reads: {}
    writes: {}
    called_with: {}

  setmetatable spy,
    __call: (_, ...) ->
      spy.called = true
      rawset spy, 'called_with', {...}
      options.with_return

    __index: (t,k) ->
      table.insert spy.reads, k
      if options.as_null_object
        sub = new options
        rawset spy, k, sub
        return sub
      spy.writes[k]

    __newindex: (t,k,v) ->
      spy.writes[k] = v
  spy

return setmetatable {}, __call: (_, options) -> new options
