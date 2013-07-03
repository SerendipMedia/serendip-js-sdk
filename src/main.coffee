define [
  'cs!auth'
  'cs!api'
  'cs!objects/response'
  'cs!objects/error'
  'cs!settings'
  'jquery'
], (Auth,Api,ResponseObject,ErrorObject,Settings) ->
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
    subscribe : (event, callback) ->
      $(document).on(event, (e,obj) ->
        callback(obj) if obj?
      )
    login : (network, implicit = false, rememberMe = false, state, newWindow = true) ->
      return $.Deferred(
        () ->
          Auth.login(network,implicit,rememberMe,state,newWindow).done(
            (resp) =>
              @resolve(resp)
          ).fail(
            (err) =>
              @reject(err)
          )
      ).promise()
    logoutFromFB : () ->
      SRNDP_FB_IFRAME.contentWindow.postMessage("srndp-logout-fb",Settings.BASE_URL)
      @logout()
    activate : () ->
      return $.Deferred(
        () ->
          Auth.activate().done(
            (resp) =>
              @resolve(resp)
          ).fail(
            (err) =>
              @reject(err)
          )
      ).promise()
    register : (username, name, rememberMe = false, email,location, shouldActivate) ->
      return $.Deferred(
        () ->
          Auth.register(username, name, rememberMe , email,location, shouldActivate).done(
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
    isRegistered : () ->
      Auth.isRegistered();
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

  # call serendip ready
  window.onSrndpReady()
