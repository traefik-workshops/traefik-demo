locals {
  # Encode the APIs configuration as JSON to pass to the k6 script.
  apis_json = jsonencode([for api in var.apis : {
    url    = api.url
    models = api.models
  }])

  # Encode users configuration.
  users_json = jsonencode([for user in var.users : {
    username = user.username
    password = user.password
  }])

  # Escape single quotes for safe embedding inside the JS single-quoted JSON.parse() arg.
  apis_json_escaped  = replace(local.apis_json, "'", "\\'")
  users_json_escaped = replace(local.users_json, "'", "\\'")
}
