define [
  'cs!srndp_settings',
  'cs!objects/srndp_error'
  'jquery'
], (Settings,ErrorObject) ->
  Api =
    call : (endpoint, params, auth, at, method = 'GET') ->
      return $.Deferred(
        () ->
          isValidMethodName = do (method) ->
            for validMethodName in ['GET','POST','PUT','HEAD','DELETE']
              return true if method == validMethodName
            return false
          unless isValidMethodName then @reject(new ErrorObject("ERR_INVALID_API_CALL"))
          else unless SRNDP.CLIENT_ID then @reject(new ErrorObject("ERR_NOT_INITIALIZED"))
          else if auth and not at? then @reject(new ErrorObject("ERR_NOT_LOGGED_IN_OR_INVALID_TOKEN"))
          else
            BASE_URL = Settings.BASE_API_URL
            BASE_URL = (if auth then Settings.SECURE_PROTOCOL else "http://") + BASE_URL
            FULL_URL = BASE_URL + endpoint
            if auth
              params = $.extend(params,{client_id : SRNDP.CLIENT_ID, auth_token : at})
            else
              params = $.extend(params,{client_id : SRNDP.CLIENT_ID})
            $.ajax
              type : method
              url : FULL_URL
              data : params
              success : (data) =>
                @resolve(data)
              error : (error) =>
                if (error.status == 401) #Unauthorized
                  @reject(new ErrorObject("ERR_AUTHENTICATION_REQUIRED"))
                else
                  @reject(new ErrorObject("ERR_INVALID_API_CALL",error.responseJSON))

      ).promise()