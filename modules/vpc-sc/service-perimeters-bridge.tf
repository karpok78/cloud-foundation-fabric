/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# tfdoc:file:description Bridge service perimeter resources.

# this code implements "additive" service perimeters, if "authoritative"
# service perimeters are needed, switch to the
# google_access_context_manager_service_perimeters resource

locals {
  bridge_perimeters = merge(local.data.service_perimeters_bridge, var.service_perimeters_bridge)
}

resource "google_access_context_manager_service_perimeter" "bridge" {
  for_each                  = local.bridge_perimeters
  parent                    = "accessPolicies/${local.access_policy}"
  name                      = "accessPolicies/${local.access_policy}/servicePerimeters/${each.key}"
  title                     = each.key
  perimeter_type            = "PERIMETER_TYPE_BRIDGE"
  use_explicit_dry_run_spec = each.value.use_explicit_dry_run_spec

  dynamic "spec" {
    for_each = (each.value.spec_resources == null ? [] : [""])
    content {
      resources = each.value.spec_resources == null ? [] : each.value.spec_resources
    }
  }

  dynamic "status" {
    for_each = (each.value.status_resources == null ? [] : [""])
    content {
      resources = each.value.status_resources == null ? [] : each.value.status_resources
    }
  }

  # lifecycle {
  #   ignore_changes = [spec[0].resources, status[0].resources]
  # }

  depends_on = [
    google_access_context_manager_access_policy.default,
    google_access_context_manager_access_level.basic,
    google_access_context_manager_service_perimeter.regular
  ]
}
