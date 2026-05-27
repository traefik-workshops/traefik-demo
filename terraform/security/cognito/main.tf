locals {
  user_pool_name = "traefik-demo"
}

resource "aws_cognito_user_pool" "pool" {
  name = local.user_pool_name

  # Password policy
  password_policy {
    minimum_length                   = 8
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
    password_history_size            = 0
    temporary_password_validity_days = 30
  }

  # Email verification
  auto_verified_attributes = ["email"]

  # User attributes
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "traefik-demo"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  callback_urls                        = var.redirect_uris
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = replace(local.user_pool_name, "_", "-")
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user" "users" {
  for_each                 = toset(var.users)
  user_pool_id             = aws_cognito_user_pool.pool.id
  username                 = each.key
  desired_delivery_mediums = ["EMAIL"]

  password       = "topsecretpassword"
  message_action = "SUPPRESS"

  attributes = {
    email          = "${each.key}@cognito.traefik"
    email_verified = "true"
  }
}

resource "aws_cognito_user_group" "groups" {
  for_each = toset(var.users)

  name         = "${each.value}s"
  description  = "${title(each.value)} group"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_in_group" "user_group_assignments" {
  for_each     = toset(var.users)
  user_pool_id = aws_cognito_user_pool.pool.id
  group_name   = aws_cognito_user_group.groups[each.key].name
  username     = each.key

  depends_on = [aws_cognito_user.users, aws_cognito_user_group.groups]
}
