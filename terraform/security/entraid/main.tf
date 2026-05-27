locals {
  domain_name = data.azuread_domains.traefik_demo.domains[0].domain_name
}

# Get default domain
data "azuread_domains" "traefik_demo" {
  only_default = true
}

# Create users
resource "azuread_user" "traefik_demo" {
  for_each = toset(var.users)

  user_principal_name     = "${each.value}@${local.domain_name}"
  display_name            = each.value
  password                = "topsecretpassword"
  force_password_change   = false
  disable_strong_password = true
}

# Create groups
resource "azuread_group" "traefik_demo" {
  for_each = toset(var.users)

  display_name     = each.value
  security_enabled = true
}

# Add users to their respective groups
resource "azuread_group_member" "traefik_demo" {
  for_each = toset(var.users)

  group_object_id  = azuread_group.traefik_demo[each.value].object_id
  member_object_id = azuread_user.traefik_demo[each.value].object_id
}

# Create permission scope uuid
resource "random_uuid" "traefik_demo_permission_scope_id" {}

# Create app role uuid
resource "random_uuid" "traefik_demo_app_role_id" {
  for_each = toset(var.users)
}

# Create app registration
resource "azuread_application" "traefik_demo" {
  display_name = "traefik_demo"

  # Configure optional claims to include group names
  optional_claims {
    access_token {
      name                  = "groups"
      essential             = true
      additional_properties = ["dns_domain_and_sam_account_name"]
    }
  }

  # Configure group membership claims to use names
  group_membership_claims = ["All"]

  web {
    redirect_uris = var.redirect_uris
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
      type = "Scope"
    }
    resource_access {
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182" # offline_access
      type = "Scope"
    }
    resource_access {
      id   = "62a82d76-70ea-41e2-9197-370581804d09" # Group.Read.All
      type = "Role"
    }
  }

  # Add API scope
  api {
    mapped_claims_enabled     = true
    known_client_applications = []

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access group membership information"
      admin_consent_display_name = "Access Groups"
      enabled                    = true
      id                         = random_uuid.traefik_demo_permission_scope_id.id
      type                       = "User"
      user_consent_description   = "Allow this application to access your group membership information"
      user_consent_display_name  = "Access your groups"
      value                      = "groups"
    }
  }

  dynamic "app_role" {
    for_each = toset(var.users)

    content {
      allowed_member_types = ["User", "Application"]
      display_name         = title("${app_role.value}s")
      description          = "${title(app_role.value)} role for API access"
      enabled              = true
      id                   = random_uuid.traefik_demo_app_role_id[app_role.value].id
      value                = "${app_role.value}s"
    }
  }
}

# Create client secret
resource "azuread_application_password" "traefik_demo" {
  application_id = azuread_application.traefik_demo.id
  display_name   = "traefik-demo-secret"
  end_date       = "2050-12-31T00:00:00Z" # Set expiry date
}

# Create service principal for the application
resource "azuread_service_principal" "traefik_demo" {
  client_id = azuread_application.traefik_demo.client_id
}

# Assign roles to users
resource "azuread_app_role_assignment" "traefik_demo" {
  for_each = toset(var.users)

  app_role_id         = [for role in azuread_application.traefik_demo.app_role : role.id if role.value == "${each.value}s"][0]
  principal_object_id = azuread_user.traefik_demo[each.value].object_id
  resource_object_id  = azuread_service_principal.traefik_demo.object_id
}