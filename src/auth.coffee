define [
  'cs!objects/response'
  'cs!objects/error'
  'cs!objects/login_status'
  'cs!settings'
  'cs!api'
  'cs!srndp_utils'
  'jquery'
  'jstorage'
], (ResponseObject,ErrorObject,LoginStatusObject,Settings,Api,_Utils) ->
#  on every page load we will check if we return from login
  # catch FB message
  window.onmessage = (msg) ->
      _Utils.log("got message:")
      _Utils.log(msg)
      if (msg.origin == Settings.BASE_URL)
        if msg.data.indexOf("srndp-ready") != -1
          # call serendip ready
          window.onSrndpReady()
#          check if after login
          Auth.checkIfAfterLogin()
        else if msg.data.indexOf("srndp-chk-session") != -1
          SRNDP.LAST_SRNDP_RESPONSE =
            status : msg.data.substring(18)
        else if msg.data.indexOf("srndp-login-success") != -1
          if window.SRNDP_WAITING_FOR_LOGIN_MSG?
            replyMsg = msg.data.substring(20)
            obj = JSON.parse(replyMsg)
            if obj["success"] or obj["success"] is "true"
              window.SRNDP_WAITING_FOR_LOGIN_MSG.resolve(Auth.getLoggedInResult(obj,false,true))
            else
              window.SRNDP_WAITING_FOR_LOGIN_MSG.reject(Auth.getLoginError(obj))
        else if msg.data.indexOf("srndp-login-failed") != -1
          if window.SRNDP_WAITING_FOR_LOGIN_MSG?
            window.SRNDP_WAITING_FOR_LOGIN_MSG.reject()
        else
          SRNDP.LAST_FB_RESPONSE = JSON.parse(msg.data)
        Auth.getLoginStatus().done( (loginStatus) ->
          $(document).trigger("srndp.statusChange",loginStatus)
        )
#        extensions handling
  if (chrome?.runtime?)
    chrome.runtime.onMessage.addListener( (msg,sender) ->
      console.log("Sender is: ")
      console.log(sender)
      console.log(msg)
      SRNDP.LAST_FB_RESPONSE = JSON.parse(msg)
    )
    Auth.getLoginStatus().done( (loginStatus) ->
      $(document).trigger("srndp.statusChange",loginStatus)
    )
  Auth =
    LOGIN_ENDPOINT : "/login"
    CONNECT_PARAMS :
      status : 0
      toolbar : 0
      location : 1
      menubar : 0
      directories : 0
      resizable : 0
      scrollbars : 0
      left : 0
      top : 0
    checkIfAfterLogin : () ->
      hash = window.location.hash
      d = @getDeferredLogin()
      if d? and hash? and window.onReturnFromLogin?
        @clearDeferredLogin()
        _Utils.eliminateHashPart()
        obj = _Utils.parseToObj(hash.substring(1))
        if obj? and obj["success"] or obj["success"] is "true"
          onReturnFromLogin(@getLoggedInResult(obj))
        else
          if onError? then onError(@getLoginError(obj))
    getLoggedInResult : (obj,facebook = false, serendip = false) ->
      newUser =  (obj["x_new_user"] is "true" or obj["x_new_user"])
      if newUser
        newUserObj =
          username : obj["x_username"]
          email : obj["x_email"]
          name : obj["x_name"]
      @setAccessToken(obj["access_token"],obj["expires_in"],!newUser)
      new LoginStatusObject("logged_in",obj["username"],newUser,newUserObj,obj["state"],facebook,serendip)
    getLoginError : (obj) ->
      new ErrorObject("ERR_GENERIC",{"error_message" : obj.error_description.replace(/\+/g," ")})
    initClient : (clientId) ->
      return $.Deferred(
        () ->
          if SRNDP?
            SRNDP.CLIENT_ID = clientId
            resp = new ResponseObject()
            @resolve(resp)
          else
            err = new ErrorObject()
            @reject(err)
      ).promise()
    loginFromIframe : (network, clientId,implicit) ->
      SRNDP.CLIENT_ID = clientId
      @login(network,implicit, false,null,true,true)
    login : (network, implicit = false, rememberMe = false, state, newWindow = true, fromIframe = false) ->
      that = @
      return $.Deferred(
        () ->
          afterLogin = (obj, clientFlow = false) =>
            if obj["success"] or obj["success"] is "true"
              @resolve(that.getLoggedInResult(obj,clientFlow))
            else
              @reject(that.getLoginError(obj))
          window.onmessage = (e) =>
            if (Settings.BASE_OAUTH_URL.indexOf(e.origin) != -1)
              obj = e.data
              if (typeof obj is "object") then afterLogin(obj)
          unless SRNDP.CLIENT_ID then @reject(new ErrorObject("ERR_NOT_INITIALIZED"))
          else
            params =
              network : network
              state : state
              client_id : SRNDP.CLIENT_ID
              response_type : "token"
              sdk : true
              popup : newWindow
              rememberMe : rememberMe
              implicit : implicit
#              implicit login
            if network is "facebook" and SRNDP.LAST_FB_RESPONSE? and SRNDP.LAST_FB_RESPONSE.status is "connected" and implicit
              authResponse = SRNDP.LAST_FB_RESPONSE.authResponse
              fbTokens =
                network_token : authResponse.accessToken
                network_secret : authResponse.signedRequest
                network_expiration : authResponse.expiresIn
              $.extend(params,fbTokens)
            url = Settings.BASE_OAUTH_URL + that.LOGIN_ENDPOINT
            params.origin = window.location.href
            url = url + "?" + $.param(params)
            if (implicit)
              $.ajax(
                url : url
                type : 'GET'
                success : (obj) =>
                  if (fromIframe)
                    @resolve(obj)
                  else
                    afterLogin(obj,true)
                error : (xhr,err) =>
                  @reject(new ErrorObject(err))
              )
            else
              if (newWindow)
                options = if (network == "facebook")
                            {width : 535, height: 463}
                          else
                            {width : 535, height: 663}
                window.open(url,"srndp_login",$.param($.extend(@CONNECT_PARAMS,options)).replace(/&/g,","))
              else
                that.deferLogin()
                document.location = url
      ).promise()
    getLoginStatus : () ->
      # reinit storage
      $.jStorage.reInit()

      that = @
      return $.Deferred(
        () ->
          d = that.getDeferredLogin()
          unless d?
            srndp_authorized =  (SRNDP.LAST_SRNDP_RESPONSE? and SRNDP.LAST_SRNDP_RESPONSE.status is "logged_in")
            facebook_authorized =  (SRNDP.LAST_FB_RESPONSE? and SRNDP.LAST_FB_RESPONSE.status is "connected")
            at = that.getAccessToken()
            if at?
              if that.isRegistered()
                @resolve(new LoginStatusObject("logged_in",null,null,null,null,facebook_authorized,srndp_authorized))
              else
                @resolve(new LoginStatusObject("signing_up",null,null,null,null,facebook_authorized,srndp_authorized))
            else
              @resolve(new LoginStatusObject("logged_out",null,null,null,null,facebook_authorized,srndp_authorized))
      ).promise()
    register : (username, name, rememberMe = false, email,location, shouldActivate=true) ->
      that = @
      return $.Deferred(
        () ->
          params =
            username : username
            name : name
            rememberMe : rememberMe
            email : email
            location : location
            shouldActivate : shouldActivate
          Api.call('/auth/register.json',params,true,that.getAccessToken()).done( (res) =>
            if (res.success)
              @resolve(new ResponseObject())
              that.setAccessToken(that.getAccessToken(),that.getTTL(),true)
              $(document).trigger("srndp.statusChange",new LoginStatusObject("logged_in"))
            else
              @reject(new ErrorObject())
          ).fail( (err) =>
            @reject(err)
          )
      ).promise()
    activate : () ->
      that = @
      return $.Deferred(
        () ->
          Api.call('/auth/activate.json',null,true,that.getAccessToken()).done( (res) =>
            if (res.success)
              that.setAccessToken(that.getAccessToken(),that.getTTL(),true)
              @resolve(new ResponseObject())
              $(document).trigger("srndp.statusChange",new LoginStatusObject("logged_in"))
            else
              @reject(new ErrorObject())
          ).fail( (err) =>
            @reject(err)
          )
      ).promise()
    logout : () ->
      that = @
      return $.Deferred(
        () ->
          that.removeAccessToken()
          $(document).trigger("srndp.statusChange",new LoginStatusObject("logged_out"))
          @resolve(new ResponseObject())
          Api.call('/auth/logout.json',null,true,that.getAccessToken()).promise()
      ).promise()
    isRegistered : () ->
      cred = $.jStorage.get("SRNDP_cred", null)
      if cred? then cred.act else false
    getAccessToken : () ->
      cred = $.jStorage.get("SRNDP_cred", null)
      _Utils.log "getting access token:"
      _Utils.log(cred)
      if cred? then cred.at else null
    setAccessToken : (authToken, ttl = 24*60*60, active = true) ->
      $.jStorage.set("SRNDP_cred",{"at" : authToken, "act" : active},{TTL : 1000 * ttl})
    removeAccessToken : () ->
      $.jStorage.deleteKey("SRNDP_cred")
    getTTL : () ->
      $.jStorage.getTTL("SRNDP_cred")
    deferLogin : (deferred) ->
      $.jStorage.set("SRNDP_deflogin",{"d" : deferred},{TTL : 1000 * 30})
    getDeferredLogin : () ->
      $.jStorage.get("SRNDP_deflogin")
    clearDeferredLogin : () ->
      $.jStorage.deleteKey("SRNDP_deflogin")

