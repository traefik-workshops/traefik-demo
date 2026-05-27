resource "nutanix_category_key" "category_key" {
  for_each = var.categories

  name        = each.value.name
  description = each.value.description
}

resource "nutanix_category_value" "category_value" {
  for_each = local.category_values_map

  name  = nutanix_category_key.category_key[each.value.category_key].id
  value = each.value.value
}
