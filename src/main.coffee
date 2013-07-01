define [
  'cs!auth'
  'cs!objects/response'
  'cs!objects/error'
  'jquery'
], (Auth,ResponseObject,ErrorObject) ->
#  Define the SRNDP object
  window.SRNDP =
    init : (initObject) ->
      return $.Deferred(
        () ->
          unless initObject.clientId and initObject.redirect_url then @reject(new ErrorObject("ERR_NOT_INITIALIZED"))
          Auth.initClient(initObject.clientId,initObject.redirect_url).done(
            (resp) => @resolve(resp)
          ).fail(
            (err) => @reject(err)
          )
      )
#  Trigger the onSrndpReady function
  if window.onSrndpReady? then window.onSrndpReady()