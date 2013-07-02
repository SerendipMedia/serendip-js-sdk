define [], () ->
  class LoginStatusObject
    constructor: (@status, @username, @newUser, @newUserObj, @state, @facebook_authorized) ->
      return