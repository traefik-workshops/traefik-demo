variable "categories" {
  description = "Map of category keys to create with their values"
  type = map(object({
    name        = string
    description = string
    values      = list(string)
  }))
}

locals {
  # Flatten the categories map to create individual category values
  category_values_map = merge([
    for category_key, category in var.categories : {
      for value in category.values :
      "${category_key}_${value}" => {
        category_key = category_key
        value        = value
      }
    }
  ]...)
}
