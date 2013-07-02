define [], () ->
  Settings =
    SECURE_PROTOCOL : "http://"
    BASE_API_URL : "localapi.serendip.me:9000/v1"
    BASE_URL : "http://local.serendip.me"
    FB_APP_ID : '180530865322766'
  Settings.BASE_OAUTH_URL = Settings.BASE_URL + "/auth"
  Settings