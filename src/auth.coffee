define [
  'cs!objects/response'
  'cs!objects/error'
  'cs!objects/login_status'
  'cs!settings'
  'cs!api'
  'jquery'
  'jstorage'
  'facebook_sdk'
], (ResponseObject,ErrorObject,LoginStatusObject,Settings,Api) ->
  window.fbAsyncInit = () ->
    # init the FB JS SDK
    FB.init(
      appId      : Settings.FB_APP_ID
      channelUrl : Settings.BASE_URL + '/public/website/channel.html'
      status     : true
    )
    FB.Event.subscribe('auth.statusChange', (response) ->
      SRNDP.LAST_FB_RESPONSE = response
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
    login : (network, rememberMe = false, state, newWindow = true) ->
      that = @
      return $.Deferred(
        () ->
          afterLogin = (obj) =>
            if obj["success"] or obj["success"] is "true"
              newUser =  (obj["x_new_user"] is "true")
              if newUser
                newUserObj =
                  username : obj["x_username"]
                  email : obj["x_email"]
                  name : obj["x_name"]
              that.setAccessToken(obj["access_token"],obj["expires_in"])
              @resolve(new LoginStatusObject("logged_in",obj["username"],newUser,newUserObj,obj["state"]))
            else
              @reject(new ErrorObject("ERR_GENERIC",{"error_message" : obj.error_description.replace(/\+/g," ")}))
          window.onmessage = (e) =>
            if (Settings.BASE_OAUTH_URL.indexOf(e.origin) != -1)
              obj = e.data
              afterLogin(obj)
          unless SRNDP.CLIENT_ID then @reject(new ErrorObject("ERR_NOT_INITIALIZED"))
          else
            # try FB client-side first
            params =
              network : network
              state : state
              client_id : SRNDP.CLIENT_ID
              response_type : "token"
              sdk : true
              rememberMe : rememberMe
            if network is "facebook" and SRNDP.LAST_FB_RESPONSE? and SRNDP.LAST_FB_RESPONSE.status is "connected"
              authResponse = SRNDP.LAST_FB_RESPONSE.authResponse
              fbTokens =
                network_token : authResponse.accessToken
                network_secret : authResponse.signedRequest
                network_expiration : authResponse.expiresIn
              $.extend(params,fbTokens)
            url = Settings.BASE_OAUTH_URL + that.LOGIN_ENDPOINT
            origin = window.location.protocol + "//"  +window.location.hostname
            port = window.location.port
            if port?
              origin = origin + ":" + port
            params.origin = origin
            url = url + "?" + $.param(params)
            if (fbTokens?)
              $.ajax(
                url : url
                type : 'GET'
                success : (obj) ->
                  afterLogin(obj)
                error : () ->
                  @reject(new ErrorObject("ERR_NOT_INITIALIZED"))
              )
            else
              if (newWindow)
                options = if (network == "facebook")
                            {width : 535, height: 463}
                          else
                            {width : 535, height: 663}
                window.open(url,"_blank",$.param($.extend(@CONNECT_PARAMS,options)).replace(/&/g,","))
              else
                @reject(new ErrorObject("ERR_NOT_SUPPORTED",{"error_message" : "newWindow=false not supported"}))
      ).promise()
    getLoginStatus : () ->
      that = @
      return $.Deferred(
        () ->
          at = that.getAccessToken()
          if at?
            @resolve(new LoginStatusObject("logged_in"))
          else
            @resolve(new LoginStatusObject("logged_out"))
      ).promise()
    logout : () ->
      that = @
      return $.Deferred(
        () ->
          Api.call('/auth/logout.json',null,true,that.getAccessToken()).done(
            (response) =>
              if (response.success is true)
                that.removeAccessToken()
                @resolve(new ResponseObject())
              else
                @reject(new ErrorObject())
          ).fail(
            (err) =>
              @reject(err)
          )
      ).promise()
    getAccessToken : () ->
      cred = $.jStorage.get("SRNDP_cred", null)
      if cred? then cred.at else null
    setAccessToken : (authToken, ttl) ->
      $.jStorage.set("SRNDP_cred",{"at" : authToken},{TTL : 100 * ttl})
    removeAccessToken : () ->
      $.jStorage.deleteKey("SRNDP_cred")
