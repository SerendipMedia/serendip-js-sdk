define [
  'cs!objects/response'
  'cs!objects/error'
  'cs!objects/login_status'
  'cs!settings'
  'cs!api'
  'jquery'
  'jstorage'
], (ResponseObject,ErrorObject,LoginStatusObject,Settings,Api) ->
  # catch FB message
  window.onmessage = (msg) ->
      if (msg.origin == Settings.BASE_URL)
        SRNDP.LAST_FB_RESPONSE = JSON.parse(msg.data)
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
    login : (network, implicit = false, rememberMe = false, state, newWindow = true) ->
      that = @
      return $.Deferred(
        () ->
          afterLogin = (obj) =>
            if obj["success"] or obj["success"] is "true"
              newUser =  (obj["x_new_user"] is "true" or obj["x_new_user"])
              if newUser
                newUserObj =
                  username : obj["x_username"]
                  email : obj["x_email"]
                  name : obj["x_name"]
              that.setAccessToken(obj["access_token"],obj["expires_in"],!newUser)
              @resolve(new LoginStatusObject("logged_in",obj["username"],newUser,newUserObj,obj["state"]))
            else
              @reject(new ErrorObject("ERR_GENERIC",{"error_message" : obj.error_description.replace(/\+/g," ")}))
          window.onmessage = (e) =>
            if (Settings.BASE_OAUTH_URL.indexOf(e.origin) != -1)
              obj = e.data
              afterLogin(obj)
          unless SRNDP.CLIENT_ID then @reject(new ErrorObject("ERR_NOT_INITIALIZED"))
          else
            params =
              network : network
              state : state
              client_id : SRNDP.CLIENT_ID
              response_type : "token"
              sdk : true
              rememberMe : rememberMe
#              implpicit login
            if network is "facebook" and SRNDP.LAST_FB_RESPONSE? and SRNDP.LAST_FB_RESPONSE.status is "connected" and implicit
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
          facebook_authorized =  (SRNDP.LAST_FB_RESPONSE? and SRNDP.LAST_FB_RESPONSE.status is "connected")
          at = that.getAccessToken()
          if at?
            if that.isRegistered()
              @resolve(new LoginStatusObject("logged_in",null,null,null,null,facebook_authorized))
            else
              @resolve(new LoginStatusObject("signing_up",null,null,null,null,facebook_authorized))
          else
            @resolve(new LoginStatusObject("logged_out",null,null,null,null,facebook_authorized))
      ).promise()
    register : (username, name, rememberMe = false, email,location, shouldActivate) ->
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
          @resolve(new ResponseObject())
          Api.call('/auth/logout.json',null,true,that.getAccessToken()).promise()
      ).promise()
    isRegistered : () ->
      cred = $.jStorage.get("SRNDP_cred", null)
      if cred? then cred.act else false
    getAccessToken : () ->
      cred = $.jStorage.get("SRNDP_cred", null)
      if cred? then cred.at else null
    setAccessToken : (authToken, ttl, active = true) ->
      $.jStorage.set("SRNDP_cred",{"at" : authToken, "act" : active},{TTL : 100 * ttl})
    removeAccessToken : () ->
      $.jStorage.deleteKey("SRNDP_cred")
    getTTL : () ->
      $.jStorage.getTTL("SRNDP_cred")

