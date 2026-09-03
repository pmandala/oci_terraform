
# --- 1. Fetch Object Storage Namespace ---
data "oci_objectstorage_namespace" "ns" {}

# --- 2. Create Buckets ---
# Source Bucket: Where archives are uploaded
resource "oci_objectstorage_bucket" "source_bucket" {
  compartment_id = var.compartment_ocid
  name           = var.source_bucket_name
  namespace      = data.oci_objectstorage_namespace.ns.namespace

  # CRITICAL: Must be enabled so OCI Events can intercept uploads
  object_events_enabled = true
}

# Destination Bucket: Where extracted files will land
resource "oci_objectstorage_bucket" "dest_bucket" {
  compartment_id = var.compartment_ocid
  name           = var.dest_bucket_name
  namespace      = data.oci_objectstorage_namespace.ns.namespace
}

# --- 3. Locate & Deploy Pre-Built File Extractor Function ---
# Search the OCI catalog for the Pre-Built Function Listing
data "oci_functions_pbf_listings" "file_extractor" {
  filter {
    name   = "name"
    values = ["Object Storage File Extractor"]
  }
}

# Deploy the serverless App Container
resource "oci_functions_application" "extractor_app" {
  compartment_id = var.compartment_ocid
  display_name   = "file-extractor-app"
  subnet_ids     = [oci_core_subnet.pbf_subnet.id]
}

# Deploy the Extractor Function instance inside the App
resource "oci_functions_function" "file_extractor_fn" {
  application_id     = oci_functions_application.extractor_app.id
  display_name       = "file-extractor-function"
  memory_in_mbs      = 512
  timeout_in_seconds = 300

  # Points to the managed OCI Pre-Built Listing
  source_details {
    source_type    = "PRE_BUILT_FUNCTIONS"
    pbf_listing_id = data.oci_functions_pbf_listings.file_extractor.pbf_listings_collection[0].items[0].id
  }

  config = {
    "PBF_LOG_LEVEL" = "DEBUG"
  }
}

# --- 4. Event Rule Automation & Pattern Matching ---
resource "oci_events_rule" "unzip_trigger_rule" {
  compartment_id = var.compartment_ocid
  display_name   = "unzip-on-upload-trigger"
  is_enabled     = true

  condition_details {
    event_types = [
      "com.oraclecloud.objectstorage.createobject",
      "com.oraclecloud.objectstorage.updateobject"
    ]
    data = jsonencode({
      additionalDetails = {
        bucketName = [oci_objectstorage_bucket.source_bucket.name]
        namespace  = [data.oci_objectstorage_namespace.ns.namespace]
      }
      # This acts as an explicit suffix filter to evaluate only archives
      # resourceName = ["*.zip", "*.tar", "*.tar.gz", "*.tgz"]
      resourceName = "*.zip"
    })
  }

  # Invoke our OCI function when the criteria match
  actions {
    action {
      action_type = "FAAS"
      is_enabled  = true
      function_id = oci_functions_function.file_extractor_fn.id
      description = "Triggers pre-built file extractor for archive objects."
    }
  }

  # depends_on = [oci_identity_policy.extractor_automation_policy]
}
