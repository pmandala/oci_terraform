# The Console creates these automatically for a pre-built function. Terraform
# does not, so manage them explicitly for reliable event invocations.

# 1. Create a Dynamic Group matching only your deployed function
/*resource "oci_identity_dynamic_group" "extractor_fn_dg" {
  compartment_id = var.tenancy_ocid # Dynamic groups must be created in the Root tenancy
  name           = "file-extractor-function-dg"
  description    = "Dynamic group targeting the Object Storage File Extractor function instance."

  # Rule targets the exact resource ID of your function
  matching_rule = "ALL {resource.id = '${oci_functions_function.file_extractor_fn.id}', resource.compartment.id = '${var.compartment_ocid}'}"
} */

/*locals {
  dg_name = oci_identity_dynamic_group.extractor_fn_dg.name
}


# 2. Assign Policies to the Dynamic Group and Cloud Events
resource "oci_identity_policy" "extractor_automation_policy" {
  compartment_id = var.compartment_ocid
  name           = "file-extractor-automation-policy"
  description    = "Allows Cloud Events to run functions and gives the function access to Object Storage."

  statements = [
    # Allow the OCI Event service to execute functions inside your compartment
    "Allow service cloudEvents to use functions-family in compartment id ${var.compartment_ocid}",

    # Allow the function (via the Dynamic Group) to read archives from the source bucket
    "Allow dynamic-group ${local.dg_name} to read objectstorage-namespaces in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${local.dg_name} to read compartments in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${local.dg_name} to read objects in compartment id ${var.compartment_ocid}'",

    # Allow the function (via the Dynamic Group) to write/overwrite files in the destination bucket
    "Allow dynamic-group ${local.dg_name} to manage objects in compartment id ${var.compartment_ocid}'",
    "Allow dynamic-group ${local.dg_name} to manage buckets in compartment id ${var.compartment_ocid}",
  ]
}*/

/*

Allow service cloudEvents to use functions-family in compartment id ocid1.compartment.oc1..aaaaaaaar3sd2asx3l3ljkjyk34dxblvbmsaeflkrhndl2eswv7db4k5qjfa
Allow dynamic-group weigoh_test_dynamic_group to read objectstorage-namespaces in compartment id ocid1.compartment.oc1..aaaaaaaar3sd2asx3l3ljkjyk34dxblvbmsaeflkrhndl2eswv7db4k5qjfa
Allow dynamic-group weigoh_test_dynamic_group to read compartments in compartment id ocid1.compartment.oc1..aaaaaaaar3sd2asx3l3ljkjyk34dxblvbmsaeflkrhndl2eswv7db4k5qjfa
Allow dynamic-group weigoh_test_dynamic_group to read objects in compartment id ocid1.compartment.oc1..aaaaaaaar3sd2asx3l3ljkjyk34dxblvbmsaeflkrhndl2eswv7db4k5qjfa'
Allow dynamic-group weigoh_test_dynamic_group to manage objects in compartment id ocid1.compartment.oc1..aaaaaaaar3sd2asx3l3ljkjyk34dxblvbmsaeflkrhndl2eswv7db4k5qjfa'
Allow dynamic-group weigoh_test_dynamic_group to manage buckets in compartment id ocid1.compartment.oc1..aaaaaaaar3sd2asx3l3ljkjyk34dxblvbmsaeflkrhndl2eswv7db4k5qjfa

*/
