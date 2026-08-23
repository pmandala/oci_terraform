module "audit" {
  count     = length(local.all_comp_ids)
  source    = "../security_rules"
  comp_id   = local.all_comp_ids[count.index]
  comp_name = local.comp_map[local.all_comp_ids[count.index]]
}