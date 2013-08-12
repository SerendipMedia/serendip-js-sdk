// Generated by CoffeeScript 1.6.3
(function() {
  define(['cs!objects/srndp_response', 'cs!objects/srndp_error', 'cs!objects/srndp_login_status', 'cs!srndp_settings', 'cs!srndp_api', 'cs!srndp_utils', 'jquery', 'jstorage'], function(ResponseObject, ErrorObject, LoginStatusObject, Settings, Api, _Utils) {
    var Auth;
    window.onmessage = function(msg) {
      var obj, replyMsg;
      _Utils.log("got message:");
      _Utils.log(msg);
      if (msg.origin === Settings.BASE_URL) {
        if (msg.data.indexOf("srndp-ready") !== -1) {
          window.onSrndpReady();
          Auth.checkIfAfterLogin();
        } else if (msg.data.indexOf("srndp-chk-session") !== -1) {
          SRNDP.LAST_SRNDP_RESPONSE = {
            status: msg.data.substring(18)
          };
        } else if (msg.data.indexOf("srndp-login-success") !== -1) {
          if (window.SRNDP_WAITING_FOR_LOGIN_MSG != null) {
            replyMsg = msg.data.substring(20);
            obj = JSON.parse(replyMsg);
            if (obj["success"] || obj["success"] === "true") {
              window.SRNDP_WAITING_FOR_LOGIN_MSG.resolve(Auth.getLoggedInResult(obj, false, true));
            } else {
              window.SRNDP_WAITING_FOR_LOGIN_MSG.reject(Auth.getLoginError(obj));
            }
          }
        } else if (msg.data.indexOf("srndp-login-failed") !== -1) {
          if (window.SRNDP_WAITING_FOR_LOGIN_MSG != null) {
            window.SRNDP_WAITING_FOR_LOGIN_MSG.reject();
          }
        } else {
          SRNDP.LAST_FB_RESPONSE = JSON.parse(msg.data);
        }
        return Auth.getLoginStatus().done(function(loginStatus) {
          return $(document).trigger("srndp.statusChange", loginStatus);
        });
      }
    };
    return Auth = {
      LOGIN_ENDPOINT: "/login",
      CONNECT_PARAMS: {
        status: 0,
        toolbar: 0,
        location: 1,
        menubar: 0,
        directories: 0,
        resizable: 0,
        scrollbars: 0,
        left: 0,
        top: 0
      },
      checkIfAfterLogin: function() {
        var d, hash, obj;
        hash = window.location.hash;
        d = this.getDeferredLogin();
        if ((d != null) && (hash != null) && (window.onReturnFromLogin != null)) {
          this.clearDeferredLogin();
          _Utils.eliminateHashPart();
          obj = _Utils.parseToObj(hash.substring(1));
          if ((obj != null) && obj["success"] || obj["success"] === "true") {
            return onReturnFromLogin(this.getLoggedInResult(obj));
          } else {
            if (typeof onError !== "undefined" && onError !== null) {
              return onError(this.getLoginError(obj));
            }
          }
        }
      },
      getLoggedInResult: function(obj, facebook, serendip) {
        var newUser, newUserObj;
        if (facebook == null) {
          facebook = false;
        }
        if (serendip == null) {
          serendip = false;
        }
        newUser = obj["x_new_user"] === "true" || obj["x_new_user"];
        if (newUser) {
          newUserObj = {
            username: obj["x_username"],
            email: obj["x_email"],
            name: obj["x_name"]
          };
        }
        this.setAccessToken(obj["access_token"], obj["expires_in"], !newUser);
        return new LoginStatusObject("logged_in", obj["username"], newUser, newUserObj, obj["state"], facebook, serendip);
      },
      getLoginError: function(obj) {
        return new ErrorObject("ERR_GENERIC", {
          "error_message": obj.error_description.replace(/\+/g, " ")
        });
      },
      initClient: function(clientId, chrome_extension) {
        if (chrome_extension == null) {
          chrome_extension = false;
        }
        return $srndp.Deferred(function() {
          var err, resp;
          if (typeof SRNDP !== "undefined" && SRNDP !== null) {
            SRNDP.CLIENT_ID = clientId;
            SRNDP.chrome_extension = chrome_extension;
            resp = new ResponseObject();
            return this.resolve(resp);
          } else {
            err = new ErrorObject();
            return this.reject(err);
          }
        }).promise();
      },
      loginFromIframe: function(network, clientId, implicit) {
        SRNDP.CLIENT_ID = clientId;
        return this.login(network, implicit, false, null, true, true);
      },
      login: function(network, implicit, rememberMe, state, newWindow, fromIframe) {
        var that;
        if (implicit == null) {
          implicit = false;
        }
        if (rememberMe == null) {
          rememberMe = false;
        }
        if (newWindow == null) {
          newWindow = true;
        }
        if (fromIframe == null) {
          fromIframe = false;
        }
        that = this;
        return $srndp.Deferred(function() {
          var afterLogin, authResponse, fbTokens, handler, options, params, url,
            _this = this;
          afterLogin = function(obj, clientFlow) {
            if (clientFlow == null) {
              clientFlow = false;
            }
            if (((typeof chrome !== "undefined" && chrome !== null ? chrome.runtime : void 0) != null)) {
              chrome.runtime.onMessage.removeListener(handler);
            }
            if (obj["success"] || obj["success"] === "true") {
              return _this.resolve(that.getLoggedInResult(obj, clientFlow));
            } else {
              return _this.reject(that.getLoginError(obj));
            }
          };
          window.onmessage = function(e) {
            var obj;
            if (Settings.BASE_OAUTH_URL.indexOf(e.origin) !== -1) {
              obj = e.data;
              if (typeof obj === "object") {
                return afterLogin(obj);
              }
            }
          };
          if (SRNDP.chrome_extension) {
            if (((typeof chrome !== "undefined" && chrome !== null ? chrome.runtime : void 0) != null)) {
              handler = function(msg, sender) {
                if (sender.id === chrome.i18n.getMessage("@@extension_id")) {
                  return afterLogin(msg);
                }
              };
              chrome.runtime.onMessage.addListener(handler);
            }
          }
          if (!SRNDP.CLIENT_ID) {
            return this.reject(new ErrorObject("ERR_NOT_INITIALIZED"));
          } else {
            params = {
              network: network,
              state: state,
              client_id: SRNDP.CLIENT_ID,
              response_type: "token",
              sdk: true,
              popup: newWindow,
              rememberMe: rememberMe,
              implicit: implicit
            };
            if (network === "facebook" && (SRNDP.LAST_FB_RESPONSE != null) && SRNDP.LAST_FB_RESPONSE.status === "connected" && implicit) {
              authResponse = SRNDP.LAST_FB_RESPONSE.authResponse;
              fbTokens = {
                network_token: authResponse.accessToken,
                network_secret: authResponse.signedRequest,
                network_expiration: authResponse.expiresIn
              };
              $srndp.extend(params, fbTokens);
            }
            url = Settings.BASE_OAUTH_URL + that.LOGIN_ENDPOINT;
            params.origin = window.location.href;
            url = url + "?" + $srndp.param(params);
            if (implicit) {
              return $srndp.ajax({
                url: url,
                type: 'GET',
                success: function(obj) {
                  if (fromIframe) {
                    return _this.resolve(obj);
                  } else {
                    return afterLogin(obj, true);
                  }
                },
                error: function(xhr, err) {
                  return _this.reject(new ErrorObject(err));
                }
              });
            } else {
              if (newWindow || SRNDP.chrome_extension) {
                options = network === "facebook" ? {
                  width: 535,
                  height: 463
                } : {
                  width: 535,
                  height: 663
                };
                return window.open(url, "srndp_login", $srndp.param($srndp.extend(this.CONNECT_PARAMS, options)).replace(/&/g, ","));
              } else {
                that.deferLogin();
                return document.location = url;
              }
            }
          }
        }).promise();
      },
      getLoginStatus: function() {
        var that;
        $srndp.jStorage.reInit();
        that = this;
        return $srndp.Deferred(function() {
          var at, d, facebook_authorized, srndp_authorized;
          d = that.getDeferredLogin();
          if (d == null) {
            srndp_authorized = (SRNDP.LAST_SRNDP_RESPONSE != null) && SRNDP.LAST_SRNDP_RESPONSE.status === "logged_in";
            facebook_authorized = (SRNDP.LAST_FB_RESPONSE != null) && SRNDP.LAST_FB_RESPONSE.status === "connected";
            at = that.getAccessToken();
            if (at != null) {
              if (that.isRegistered()) {
                return this.resolve(new LoginStatusObject("logged_in", null, null, null, null, facebook_authorized, srndp_authorized));
              } else {
                return this.resolve(new LoginStatusObject("signing_up", null, null, null, null, facebook_authorized, srndp_authorized));
              }
            } else {
              return this.resolve(new LoginStatusObject("logged_out", null, null, null, null, facebook_authorized, srndp_authorized));
            }
          }
        }).promise();
      },
      register: function(username, name, rememberMe, email, location, shouldActivate) {
        var that;
        if (rememberMe == null) {
          rememberMe = false;
        }
        if (shouldActivate == null) {
          shouldActivate = true;
        }
        that = this;
        return $srndp.Deferred(function() {
          var params,
            _this = this;
          params = {
            username: username,
            name: name,
            rememberMe: rememberMe,
            email: email,
            location: location,
            shouldActivate: shouldActivate
          };
          return Api.call('/auth/register.json', params, true, that.getAccessToken()).done(function(res) {
            if (res.success) {
              _this.resolve(new ResponseObject());
              that.setAccessToken(that.getAccessToken(), that.getTTL(), true);
              return $(document).trigger("srndp.statusChange", new LoginStatusObject("logged_in"));
            } else {
              return _this.reject(new ErrorObject());
            }
          }).fail(function(err) {
            return _this.reject(err);
          });
        }).promise();
      },
      activate: function() {
        var that;
        that = this;
        return $srndp.Deferred(function() {
          var _this = this;
          return Api.call('/auth/activate.json', null, true, that.getAccessToken()).done(function(res) {
            if (res.success) {
              that.setAccessToken(that.getAccessToken(), that.getTTL(), true);
              _this.resolve(new ResponseObject());
              return $(document).trigger("srndp.statusChange", new LoginStatusObject("logged_in"));
            } else {
              return _this.reject(new ErrorObject());
            }
          }).fail(function(err) {
            return _this.reject(err);
          });
        }).promise();
      },
      logout: function() {
        var that;
        that = this;
        return $srndp.Deferred(function() {
          that.removeAccessToken();
          $(document).trigger("srndp.statusChange", new LoginStatusObject("logged_out"));
          this.resolve(new ResponseObject());
          return Api.call('/auth/logout.json', null, true, that.getAccessToken()).promise();
        }).promise();
      },
      isRegistered: function() {
        var cred;
        cred = $srndp.jStorage.get("SRNDP_cred", null);
        if (cred != null) {
          return cred.act;
        } else {
          return false;
        }
      },
      getAccessToken: function() {
        var cred;
        cred = $srndp.jStorage.get("SRNDP_cred", null);
        if (cred != null) {
          return cred.at;
        } else {
          return null;
        }
      },
      setAccessToken: function(authToken, ttl, active) {
        if (active == null) {
          active = true;
        }
        return $srndp.jStorage.set("SRNDP_cred", {
          "at": authToken,
          "act": active
        }, {
          TTL: 1000 * ttl
        });
      },
      removeAccessToken: function() {
        return $srndp.jStorage.deleteKey("SRNDP_cred");
      },
      getTTL: function() {
        return $srndp.jStorage.getTTL("SRNDP_cred");
      },
      deferLogin: function(deferred) {
        return $srndp.jStorage.set("SRNDP_deflogin", {
          "d": deferred
        }, {
          TTL: 1000 * 30
        });
      },
      getDeferredLogin: function() {
        return $srndp.jStorage.get("SRNDP_deflogin");
      },
      clearDeferredLogin: function() {
        return $srndp.jStorage.deleteKey("SRNDP_deflogin");
      }
    };
  });

}).call(this);
