define [], () ->
  class LoginStatusObject
    constructor: (@status, @username, @newUser, @newUserObj, @state) ->
      return