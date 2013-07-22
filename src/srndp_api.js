// Generated by CoffeeScript 1.6.3
(function() {
  define(['cs!srndp_settings', 'cs!objects/srndp_error', 'jquery'], function(Settings, ErrorObject) {
    var Api;
    return Api = {
      call: function(endpoint, params, auth, at, method) {
        if (method == null) {
          method = 'GET';
        }
        return $.Deferred(function() {
          var BASE_URL, FULL_URL, isValidMethodName,
            _this = this;
          isValidMethodName = (function(method) {
            var validMethodName, _i, _len, _ref;
            _ref = ['GET', 'POST', 'PUT', 'HEAD', 'DELETE'];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              validMethodName = _ref[_i];
              if (method === validMethodName) {
                return true;
              }
            }
            return false;
          })(method);
          if (!isValidMethodName) {
            return this.reject(new ErrorObject("ERR_INVALID_API_CALL"));
          } else if (!SRNDP.CLIENT_ID) {
            return this.reject(new ErrorObject("ERR_NOT_INITIALIZED"));
          } else if (auth && (at == null)) {
            return this.reject(new ErrorObject("ERR_NOT_LOGGED_IN_OR_INVALID_TOKEN"));
          } else {
            BASE_URL = Settings.BASE_API_URL;
            BASE_URL = (auth ? Settings.SECURE_PROTOCOL : "http://") + BASE_URL;
            FULL_URL = BASE_URL + endpoint;
            if (auth) {
              params = $.extend(params, {
                client_id: SRNDP.CLIENT_ID,
                auth_token: at
              });
            } else {
              params = $.extend(params, {
                client_id: SRNDP.CLIENT_ID
              });
            }
            return $.ajax({
              type: method,
              url: FULL_URL,
              data: params,
              success: function(data) {
                return _this.resolve(data);
              },
              error: function(error) {
                if (error.status === 401) {
                  return _this.reject(new ErrorObject("ERR_AUTHENTICATION_REQUIRED"));
                } else {
                  return _this.reject(new ErrorObject("ERR_INVALID_API_CALL", error.responseJSON));
                }
              }
            });
          }
        }).promise();
      }
    };
  });

}).call(this);