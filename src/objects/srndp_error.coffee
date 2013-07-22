define [], () ->
  class ErrorObject
    codes :
      ERR_GENERIC : "Generic Error"
      ERR_NOT_INITIALIZED : "SDK Not Initialized. Must call SRNDP.init with a valid client id."
      ERR_NOT_LOGGED_IN_OR_INVALID_TOKEN : "Trying to access an authenticated endpoint without a valid Auth Token."
      ERR_INVALID_API_CALL  : "An invalid API call."
      ERR_AUTHENTICATION_REQUIRED : "Endpoint requires authentication. Use 'auth' in SRNDP.api"
      ERR_INSECURED_CALL : "An insecure attempt to access API (check cross-origin policy)."
      ERR_NOT_SUPPORTED : "Option or call is not supported in current version"
    constructor: (@code, data, @throwable = true) ->
      @msg = @codes[code]
      unless @msg? then @msg = @codes["ERR_GENERIC"]
      if data? and data.error_message? then @msg = @msg + " (Details: " + data.error_message + ")"