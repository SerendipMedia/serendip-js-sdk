define [
  'module'
  'cs!srndp_settings'
], (module,Settings) ->
  _Utils =
    logging : Settings.logging
    parseToObj : (s) ->
      obj = {}
      pairs = s.split("&")
      if pairs? then for pair in pairs
        keyval = pair.split("=")
        if keyval.length is 2
          obj[keyval[0]] = keyval[1]
      obj
    eliminateHashPart : () ->
      href = document.location.href
      hashPosition = href.indexOf("#")
      if hashPosition != -1
        urlToPreserve = href.substring(0,hashPosition)
        window.history.pushState({"pageTitle":document.title},"", urlToPreserve)
    log : (msg) ->
      if @logging
        console.log msg