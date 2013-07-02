define [
  'cs!objects/response'
  'cs!objects/error'
  'cs!objects/login_status'
  'cs!settings'
  'jquery'
  'jstorage'
], (ResponseObject,ErrorObject,LoginStatusObject,Settings) ->
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
          window.onmessage = (e) =>
            if (Settings.BASE_OAUTH_URL.indexOf(e.origin) != -1)
              if e.data["success"] is "true"
                newUser =  (e.data["x_new_user"] is "true")
                if newUser
                  newUserObj =
                    username : e.data["x_username"]
                    email : e.data["x_email"]
                    name : e.data["x_name"]
                @resolve(new LoginStatusObject("logged_in",e.data["username"],newUser,newUserObj,e.data["state"]))
              else
                @reject(new ErrorObject("ERR_GENERIC",{"error_message" : e.data.error_description.replace(/\+/g," ")}))
          unless SRNDP.CLIENT_ID then @reject(new ErrorObject("ERR_NOT_INITIALIZED"))
          else
            url = Settings.BASE_OAUTH_URL + that.LOGIN_ENDPOINT
            origin = window.location.protocol + "//"  +window.location.hostname
            port = window.location.port
            if port?
              origin = origin + ":" + port
            params =
              network : network
              state : state
              client_id : SRNDP.CLIENT_ID
              response_type : "token"
              sdk : true
              origin : origin
              rememberMe : rememberMe
            url = url + "?" + $.param(params)
            if (newWindow)
              options = if (network == "facebook")
                          {width : 535, height: 463}
                        else
                          {width : 535, height: 663}
              window.open(url,"_blank",$.param($.extend(@CONNECT_PARAMS,options)).replace(/&/g,","))
            else
              @reject(new ErrorObject("ERR_NOT_SUPPORTED",{"error_message" : "newWindow=false not supported"}))
      ).promise()
