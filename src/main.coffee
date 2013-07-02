define [
  'cs!auth'
  'cs!api'
  'cs!objects/response'
  'cs!objects/error'
  'jquery'
], (Auth,Api,ResponseObject,ErrorObject) ->
#  Define the SRNDP object
  window.SRNDP =
    init : (initObject) ->
      return $.Deferred(
        () ->
          unless initObject.clientId then @reject(new ErrorObject("ERR_NOT_INITIALIZED"))
          Auth.initClient(initObject.clientId).done(
            (resp) => @resolve(resp)
          ).fail(
            (err) => @reject(err)
          )
      )
    api : (endpoint, params, auth = false, method = 'GET') ->
      return $.Deferred(
        () ->
          at = null
          if (auth) then at = Auth.getAccessToken();
          Api.call(endpoint,params,auth,at,method).done(
            (resp) =>
              @resolve(resp)
          ).fail(
            (err) =>
              @reject(err)
          )
      ).promise()
    login : (network, rememberMe = false, state, newWindow = true) ->
      return $.Deferred(
        () ->
          Auth.login(network,rememberMe,state,newWindow).done(
            (resp) =>
              @resolve(resp)
          ).fail(
            (err) =>
              @reject(err)
          )
      ).promise()
    getLoginStatus : () ->
      return $.Deferred(
        () ->
          Auth.getLoginStatus().done(
            (resp) =>
              @resolve(resp)
          ).fail(
            (err) =>
              @reject(err)
          )
      ).promise()
    logout : () ->
      return $.Deferred(
        () ->
          Auth.logout().done(
            (resp) =>
              @resolve(resp)
          ).fail(
            (err) =>
              @reject(err)
          )
      ).promise()
#  Trigger the onSrndpReady function
  if window.onSrndpReady? then window.onSrndpReady()