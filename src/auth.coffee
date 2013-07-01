define [
  'cs!objects/response'
  'cs!objects/error'
  'jquery'
], (ResponseObject,ErrorObject) ->
  Auth =
    initClient : (clientId, redirect_url) ->
      return $.Deferred(
        () ->
          if SRNDP?
            SRNDP.CLIENT_ID = clientId
            SRNDP.REDIRECT_URL = redirect_url
            resp = new ResponseObject()
            @resolve(resp)
          else
            err = new ErrorObject()
            @reject(err)
      )