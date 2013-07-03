define [
  'cs!settings'
  'facebook_sdk'
], (Settings) ->
  window.fbAsyncInit = () ->
    # init the FB JS SDK
    FB.init(
      appId      : Settings.FB_APP_ID
      channelUrl : Settings.BASE_URL + '/public/website/channel.html'
      status     : true
    )
    FB.Event.subscribe('auth.statusChange', (response) ->
      if (window.__SRNDP__ORIGIN_?)
        parent.postMessage(JSON.stringify(response),window.__SRNDP__ORIGIN_);
    )
  window.onmessage = (msg) ->
    if (msg.origin is window.__SRNDP__ORIGIN_)
      switch msg.data
        when "srndp-logout-fb"
          FB.logout()
