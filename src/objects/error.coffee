define [], () ->
  class ErrorObject
    codes :
      ERR_GENERIC : "Generic Error"
      ERR_NOT_INITIALIZED : "SDK Not Initialized. Must call SRNDP.init with a valid client id"
    constructor: (@code) ->
      @msg = @codes[code]
      unless @msg? then @msg = @codes["ERR_GENERIC"]