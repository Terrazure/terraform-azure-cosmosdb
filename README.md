<!-- BEGIN_TF_DOCS -->
[![Terraform Unit Tests](https://github.com/Terrazure/terraform-azure-cosmosdb/actions/workflows/tf-unit-tests.yml/badge.svg)](https://github.com/Terrazure/terraform-azure-cosmosdb/actions/workflows/tf-unit-tests.yml)
[![Terraform Plan/Apply](https://github.com/Terrazure/terraform-azure-cosmosdb/actions/workflows/tf-plan-apply.yml/badge.svg)](https://github.com/Terrazure/terraform-azure-cosmosdb/actions/workflows/tf-plan-apply.yml)

# Azure CosmosDB Account

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Sample

<details>
<summary>Click to expand</summary>

```hcl
module "cosmosdb" {
  source = "../module"

  location            = local.location
  resource_group_name = azurerm_resource_group.group.name
  workload_name       = "primary-db"

  authorized_ips_or_cidr_blocks = ["103.59.72.25"]
  authorized_vnet_subnet_ids    = [azurerm_subnet.snet.id]
  azure_defender_enabled        = true

  backup = {
    type                = "Periodic"
    interval_in_minutes = 60 * 4 # 4 hours
    retention_in_hours  = 10
  }

  consistency_policy = {
    level                   = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100001
  }

  failover_locations = {
    eastus = {
      location       = "eastus"
      zone_redundant = true
    },
    westus = {
      location = "westus"
    },
  }

  # Various RBAC roles assignment as per requirement
  account_contributor_object_ids = [data.azurerm_client_config.current.object_id]
  operator_object_ids            = [data.azurerm_client_config.current.object_id]
}
```
### For a complete deployment example, please check [sample folder](/samples).
</details>

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_contributor_object_ids"></a> [account\_contributor\_object\_ids](#input\_account\_contributor\_object\_ids) | List of object IDs to be added with DocumentDB Account Contributor role on Cosmos DB. | `list(string)` | `[]` | no |
| <a name="input_account_reader_object_ids"></a> [account\_reader\_object\_ids](#input\_account\_reader\_object\_ids) | List of object IDs to be added with Cosmos DB Account Contributor role on Cosmos DB. | `list(string)` | `[]` | no |
| <a name="input_authorized_ips_or_cidr_blocks"></a> [authorized\_ips\_or\_cidr\_blocks](#input\_authorized\_ips\_or\_cidr\_blocks) | List of authorized IP addresses or CIDR Blocks to allow access from. | `list(string)` | `[]` | no |
| <a name="input_authorized_vnet_subnet_ids"></a> [authorized\_vnet\_subnet\_ids](#input\_authorized\_vnet\_subnet\_ids) | IDs of the virtual network subnets authorized to connect to the Storage Account. | `list(string)` | `[]` | no |
| <a name="input_azure_defender_enabled"></a> [azure\_defender\_enabled](#input\_azure\_defender\_enabled) | Is Azure Defender enabled for this Azure CosmosDB Account? | `bool` | `false` | no |
| <a name="input_backup"></a> [backup](#input\_backup) | Backup details for CosmosDB. This block requires the following inputs:<br> - `type' : The type of the backup. Possible values are Continuous and Periodic. <br> - 'interval_in_minutes' (Optional) : The interval in minutes between two backups.Possible values are between 60 and 1440. <br> 'retention_in_hours' (Optional) : The time in hours that each backup is retained. Possible values are between 8 and 720.` | <pre>object({<br>    type                = string<br>    interval_in_minutes = optional(number)<br>    retention_in_hours  = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_backup_operator_object_ids"></a> [backup\_operator\_object\_ids](#input\_backup\_operator\_object\_ids) | List of object IDs to be added with Cosmos DB Backup Operator role on Cosmos DB. | `list(string)` | `[]` | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | Configures the capabilities to enable for this Cosmos DB account. <br> Possible values are 'AllowSelfServeUpgradeToMongo36', 'DisableRateLimitingResponses', 'EnableAggregationPipeline', 'EnableCassandra', 'EnableGremlin', 'EnableMongo', 'EnableTable', 'EnableServerless', 'MongoDBv3.4' and 'mongoEnableDocLevelTTL' | `list(string)` | `[]` | no |
| <a name="input_consistency_policy"></a> [consistency\_policy](#input\_consistency\_policy) | Specifies a consistency\_policy resource, used to define the consistency policy for this CosmosDB account. This block requires the following inputs:<br> - `level`:  The Consistency Level - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix. <br> - `max_interval_in_seconds` (Optional):  When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. <br> - `max_staleness_prefix' (Optional): The number of stale requests tolerated. Accepted range for this value is 10 – 2147483647 and value must be greater then 100000 when more then one geo_location is used` | <pre>object({<br>    level                   = string<br>    max_interval_in_seconds = optional(number)<br>    max_staleness_prefix    = optional(number)<br>  })</pre> | <pre>{<br>  "level": "BoundedStaleness",<br>  "max_interval_in_seconds": 5,<br>  "max_staleness_prefix": 100<br>}</pre> | no |
| <a name="input_customer_managed_keys"></a> [customer\_managed\_keys](#input\_customer\_managed\_keys) | Specifies customer managed keys configuration. This block requires the following inputs:<br> - `cmk_enabled`: If Customer Managed Key needs to be enabled? <br> - `user_managed_identity_id`: Managed Identity to access Key Vault.<br> - `kvt_key_versionless_id` Versionless id of Key Vault's key | <pre>object({<br>    cmk_enabled              = bool<br>    user_managed_identity_id = string<br>    kvt_key_versionless_id   = string<br>  })</pre> | <pre>{<br>  "cmk_enabled": false,<br>  "kvt_key_versionless_id": "",<br>  "user_managed_identity_id": ""<br>}</pre> | no |
| <a name="input_failover_locations"></a> [failover\_locations](#input\_failover\_locations) | Configures the geographic locations the data is replicated. This block requires the following inputs:<br> - `location`: The name of the Azure region to host replicated data. <br> - `zone_redundant' (Optional) : Should zone redundancy be enabled for this region?` | <pre>map(object({<br>    location       = string<br>    zone_redundant = optional(bool)<br>  }))</pre> | `null` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Specifies the Kind of CosmosDB to create - possible values are 'GlobalDocumentDB' and 'MongoDB'. Defaults to GlobalDocumentDB. | `string` | `"GlobalDocumentDB"` | no |
| <a name="input_location"></a> [location](#input\_location) | Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_mongo_server_version"></a> [mongo\_server\_version](#input\_mongo\_server\_version) | The Server Version of a MongoDB account. Possible values are 4.2, 4.0, 3.6, and 3.2. | `number` | `4.2` | no |
| <a name="input_operator_object_ids"></a> [operator\_object\_ids](#input\_operator\_object\_ids) | List of object IDs to be added with Cosmos DB Operator role on Cosmos DB. | `list(string)` | `[]` | no |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | Specifies the private endpoint details for this resource. This block requires the following inputs:<br> - `subnet_id`: The subnet ID to use for the private endpoint. | <pre>map(object({<br>    subnet_id = string<br>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the resource. | `string` | n/a | yes |
| <a name="input_restore_operator_object_ids"></a> [restore\_operator\_object\_ids](#input\_restore\_operator\_object\_ids) | List of object IDs to be added with Cosmos DB Restore Operator role on Cosmos DB. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional tags for the resources. | `map(string)` | `{}` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Specifies the workload name that will use this resource. This will be used in the resource name. | `string` | n/a | yes |
| <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled) | True to enabled zone redundancy on default primary location | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cosmosdb_endpoint"></a> [cosmosdb\_endpoint](#output\_cosmosdb\_endpoint) | The endpoint used to connect to the CosmosDB account. |
| <a name="output_id"></a> [id](#output\_id) | The Cosmos DB Account ID. |
| <a name="output_name"></a> [name](#output\_name) | The Cosmos DB Account name. |

## Resources

| Name | Type |
|------|------|
| [azurerm_advanced_threat_protection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/advanced_threat_protection) | resource |
| [azurerm_cosmosdb_account.db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_private_endpoint.private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_naming"></a> [naming](#module\_naming) | Azure/naming/azurerm | n/a |
| <a name="module_role_assignment"></a> [role\_assignment](#module\_role\_assignment) | github.com/Terrazure/terraform-azure-rbac | n/a |
<!-- END_TF_DOCS -->
