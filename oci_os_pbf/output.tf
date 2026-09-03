output "source_bucket_url" {
  value = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.ns.namespace}/b/${oci_objectstorage_bucket.source_bucket.name}/o"
}

output "destination_bucket_url" {
  value = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.ns.namespace}/b/${oci_objectstorage_bucket.dest_bucket.name}/o"
}

output "event_rule_state" {
  value = oci_events_rule.unzip_trigger_rule.state
}


output "Instructions" {
  value = <<EOF
Terminal :
echo "Hello from file 1" > file1.txt
echo "Hello from file 2" > file2.txt
zip test-archive.zip file1.txt file2.txt

oci os object put --region "${var.region}" -bn "${oci_objectstorage_bucket.source_bucket.name}" --file test-archive.zip --name test-archive.zip

# Invoke the extractor with its required request body
oci fn function invoke \\
  --function-id "${oci_functions_function.file_extractor_fn.id}" \\
  --fn-invoke-type sync \\
  --file - \\
  --body '{
    "COMPARTMENT_ID": "${var.compartment_ocid}",
    "REGION": "${var.region}",
    "SOURCE_BUCKET": "${oci_objectstorage_bucket.source_bucket.name}",
    "ZIP_FILE_NAME": "test-archive.zip",
    "TARGET_BUCKET": "${oci_objectstorage_bucket.dest_bucket.name}",
    "ALLOW_OVERWRITE": "true"
  }'

# Verify the Extraction Destination
oci os object list --region "${var.region}" -bn "${oci_objectstorage_bucket.dest_bucket.name}"

EOF

}
