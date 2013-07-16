define [
  'cs!utils'
  'cs!settings'
  'cs!auth'
  'facebook_sdk'
  'jquery.cookie'
], (_Utils,Settings,Auth) ->
  window.fbAsyncInit = () ->
    # init the FB JS SDK
    FB.init(
      appId      : Settings.FB_APP_ID
      channelUrl : Settings.BASE_URL + '/public/website/channel.html'
      status     : true
    )
    FB.Event.subscribe('auth.statusChange', (response) ->
      if (window.__SRNDP__ORIGIN_?)
        _Utils.log(response)
        parent.postMessage(JSON.stringify(response),window.__SRNDP__ORIGIN_)
    )
  window.onmessage = (msg) ->
    if (msg.origin is window.__SRNDP__ORIGIN_)
      if msg.data.indexOf("srndp-init") != -1
        _Utils.log("srndp-init")
        clientId = msg.data.substring(11)
        @CLIENT_ID = clientId
      else
        switch msg.data
          when "srndp-logout-fb"
            FB.logout()
          when "srndp-login-srndp"
            Auth.loginFromIframe("serendip",@CLIENT_ID,true).done( (res) ->
              replyMsg = JSON.stringify(res)
              _Utils.log("srndp-login-success:"+replyMsg)
              parent.postMessage("srndp-login-success:"+replyMsg,window.__SRNDP__ORIGIN_)
            ).fail( (err) ->
              _Utils.log("srndp-login-failed")
              parent.postMessage("srndp-login-failed",window.__SRNDP__ORIGIN_)
            )

  # init code
  window.SRNDP = {}
  parent.postMessage("srndp-ready",window.__SRNDP__ORIGIN_)
  Utils.log("srndp-ready")
  session = $.cookie(Settings.SESSION_COOKIE_NAME)
  if session?
    session = session.indexOf('user')
  else
    session = -1
  replyMsg = if session is -1 then "logged_out" else "logged_in"
  parent.postMessage("srndp-chk-session:"+replyMsg,window.__SRNDP__ORIGIN_)
  Utils.log("srndp-chk-session:"+replyMsg)

