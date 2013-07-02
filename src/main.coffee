define [
  'cs!auth'
  'cs!objects/response'
  'cs!objects/error'
  'cs!settings'
  'jquery'
], (Auth,ResponseObject,ErrorObject,Settings) ->
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
          isValidMethodName = do (method) ->
            for validMethodName in ['GET','POST','PUT','HEAD','DELETE']
              return true if method == validMethodName
            return false
          unless isValidMethodName then @reject(new ErrorObject("ERR_INVALID_API_CALL"))
          else unless SRNDP.CLIENT_ID then @reject(new ErrorObject("ERR_NOT_INITIALIZED"))
          else if auth and not SRNDP.AUTH_TOKEN? then @reject(new ErrorObject("ERR_NOT_LOGGED_IN_OR_INVALID_TOKEN"))
          else
            BASE_URL = Settings.BASE_API_URL
            BASE_URL = (if auth then "https://" else "http://") + BASE_URL
            FULL_URL = BASE_URL + endpoint
            if auth
              params = $.extend(params,{client_id : SRNDP.CLIENT_ID, auth_token : SRNDP.AUTH_TOKEN})
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

#  Trigger the onSrndpReady function
  if window.onSrndpReady? then window.onSrndpReady()