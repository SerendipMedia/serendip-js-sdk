define [
  'module'
], (module) ->
  Settings = {}
  env = module.config()["env"]
  if env?
    Settings = module.config()[env]
    Settings.BASE_OAUTH_URL = Settings.BASE_URL + "/auth"
  Settings