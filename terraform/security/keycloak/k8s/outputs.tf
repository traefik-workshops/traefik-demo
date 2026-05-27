output "users" {
  description = "All users with their IDs, emails, groups, and claims"
  value = [
    for user in local.all_users : {
      id           = uuidv5("dns", user.username)
      username     = user.username
      email        = user.email
      groups       = user.groups
      claims       = user.claims
      password     = user.password
      access_token = lookup(kubernetes_secret_v1.user_tokens.data, user.username, "")
    }
  ]
}

output "users_map" {
  description = "Map of users keyed by username"
  value = {
    for user in local.all_users : user.username => {
      id           = uuidv5("dns", user.username)
      username     = user.username
      email        = user.email
      groups       = user.groups
      claims       = user.claims
      password     = user.password
      access_token = lookup(kubernetes_secret_v1.user_tokens.data, user.username, "")
    }
  }
}
