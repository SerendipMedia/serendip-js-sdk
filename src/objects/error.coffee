define [], () ->
  class ErrorObject
    codes :
      ERR_GENERIC : "Generic Error"
      ERR_NOT_INITIALIZED : "SDK Not Initialized. Must call SRNDP.init with a valid client id."
      ERR_NOT_LOGGED_IN_OR_INVALID_TOKEN : "Trying to access an autheticated endpoint without a valid Auth Token."
      ERR_INVALID_API_CALL  : "An invalid API call."
      ERR_AUTHENTICATION_REQUIRED : "Endpoint requires authentication. Use 'auth' in SRNDP.api"
    constructor: (@code, serverError) ->
      @msg = @codes[code]
      unless @msg? then @msg = @codes["ERR_GENERIC"]
      if serverError? and serverError.error_message? then @msg = @msg + " (Message From Server: " + serverError.error_message + ")"