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
      unless initObject.clientId then @reject(new ErrorObject("ERR_NOT_INITIALIZED"))
      #          init the iframe
      SRNDP_FB_IFRAME.contentWindow.postMessage("srndp-init:"+initObject.clientId,Settings.BASE_URL)
      Auth.initClient(initObject.clientId)
    api : (endpoint, params, auth = false, method = 'GET') ->
      at = null
      if (auth) then at = Auth.getAccessToken()
      Api.call(endpoint,params,auth,at,method)
    subscribe : (event, callback) ->
      $(document).on(event, (e,obj) ->
        callback(obj) if obj?
      )
    login : (network, implicit = false, rememberMe = false, state, newWindow = true) ->
      return $.Deferred(
        () ->
          if (network == "serendip")
            SRNDP_FB_IFRAME.contentWindow.postMessage("srndp-login-srndp",Settings.BASE_URL)
            window.SRNDP_WAITING_FOR_LOGIN_MSG = @
          else
            Auth.login(network,implicit,rememberMe,state,newWindow).done(
              (resp) =>
                @resolve(resp)
            ).fail(
              (err) =>
                @reject(err)
            )
      ).promise()
    activate : () ->
      Auth.activate()
    register : (username, name, rememberMe = false, email,location, shouldActivate) ->
      Auth.register(username, name, rememberMe , email,location, shouldActivate)
    getLoginStatus : () ->
      Auth.getLoginStatus()
    isRegistered : () ->
      Auth.isRegistered();
    logout : (facebook = false) ->
      if (facebook)
        SRNDP_FB_IFRAME.contentWindow.postMessage("srndp-logout-fb",Settings.BASE_URL)
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
