variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "workload_name" {
  type        = string
  description = "Specifies the workload name that will use this resource. This will be used in the resource name."
}

variable "tags" {
  type        = map(string)
  description = "Optional tags for the resources."
  default     = {}
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the resource."
}

variable "kind" {
  type        = string
  description = "Specifies the Kind of CosmosDB to create - possible values are 'GlobalDocumentDB' and 'MongoDB'. Defaults to GlobalDocumentDB."
  default     = "GlobalDocumentDB"

  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB"], var.kind)
    error_message = "Invalid kind. Allowed values are 'GlobalDocumentDB' and 'MongoDB'."
  }
}

variable "mongo_server_version" {
  type        = number
  description = "The Server Version of a MongoDB account. Possible values are 4.2, 4.0, 3.6, and 3.2."
  default     = 4.2

  validation {
    condition     = contains([4.2, 4.0, 3.6, 3.2], var.mongo_server_version)
    error_message = "Invalid Mongo server version. Allowed values are 4.2, 4.0, 3.6, and 3.2."
  }
}

variable "authorized_ips_or_cidr_blocks" {
  type        = list(string)
  description = "List of authorized IP addresses or CIDR Blocks to allow access from."
  default     = []
}

variable "authorized_vnet_subnet_ids" {
  type        = list(string)
  description = "IDs of the virtual network subnets authorized to connect to the CosmosDB Account."
  default     = []
}

variable "private_endpoint" {
  type        = list(string)
  description = "Specifies the private endpoint details for EventHub Namespace. List of  subnet IDs to use for the private endpoint of the CosmosDB account."
  default     = []
}

variable "capabilities" {
  type        = list(string)
  description = "Configures the capabilities to enable for this Cosmos DB account. \n Possible values are 'AllowSelfServeUpgradeToMongo36', 'DisableRateLimitingResponses', 'EnableAggregationPipeline', 'EnableCassandra', 'EnableGremlin', 'EnableMongo', 'EnableTable', 'EnableServerless', 'MongoDBv3.4' and 'mongoEnableDocLevelTTL'"
  default     = []

  validation {
    condition = length([for o in var.capabilities : true
      if contains(["AllowSelfServeUpgradeToMongo36", "DisableRateLimitingResponses", "EnableAggregationPipeline", "EnableCassandra", "EnableGremlin", "EnableMongo", "EnableTable", "EnableServerless", "MongoDBv3.4", "mongoEnableDocLevelTTL"], o)
    ]) == length(var.capabilities)
    error_message = "Invalid capability type. \n Allowed values are 'AllowSelfServeUpgradeToMongo36', 'DisableRateLimitingResponses', 'EnableAggregationPipeline', 'EnableCassandra', 'EnableGremlin', 'EnableMongo', 'EnableTable', 'EnableServerless', 'MongoDBv3.4' and 'mongoEnableDocLevelTTL'."
  }
}

variable "backup" {
  description = "Backup details for CosmosDB. This block requires the following inputs:\n - `type' : The type of the backup. Possible values are Continuous and Periodic. \n - 'interval_in_minutes' (Optional) : The interval in minutes between two backups.Possible values are between 60 and 1440. \n 'retention_in_hours' (Optional) : The time in hours that each backup is retained. Possible values are between 8 and 720."
  type = object({
    type                = string
    interval_in_minutes = optional(number)
    retention_in_hours  = optional(number)
  })
  default = null

  validation {
    condition     = var.backup == null ? true : contains(["Continuous", "Periodic"], var.backup.type)
    error_message = "Invalid backup data. \n Possible backup type values are 'Continuous' and 'Periodic'."
  }
  validation {
    condition     = var.backup == null ? true : var.backup.interval_in_minutes == null || (coalesce(var.backup.interval_in_minutes, 0) >= 60 && coalesce(var.backup.interval_in_minutes, 1441) <= 1440)
    error_message = "Invalid backup data. \n Interval value is configurable only when type is Periodic and possible values are between 60 and 1440."
  }
  validation {
    condition     = var.backup == null ? true : var.backup.retention_in_hours == null || (coalesce(var.backup.retention_in_hours, 8) >= 8 && coalesce(var.backup.retention_in_hours, 720) <= 720)
    error_message = "Invalid backup data. \n Retention value is configurable only when type is Periodic and possible values are between 8 and 720."
  }
}

variable "consistency_policy" {
  description = "Specifies a consistency_policy resource, used to define the consistency policy for this CosmosDB account. This block requires the following inputs:\n - `level`:  The Consistency Level - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix. \n - `max_interval_in_seconds` (Optional):  When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. \n - `max_staleness_prefix' (Optional): The number of stale requests tolerated. Accepted range for this value is 10 – 2147483647 and value must be greater then 100000 when more then one geo_location is used"
  type = object({
    level                   = string
    max_interval_in_seconds = optional(number)
    max_staleness_prefix    = optional(number)
  })
  default = {
    level                   = "BoundedStaleness"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  validation {
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_policy.level)
    error_message = "Invalid Consistency policy value. Allowed values for 'level' are 'BoundedStaleness', 'Eventual', 'Session', 'Strong' or 'ConsistentPrefix'."
  }
  validation {
    condition     = var.consistency_policy.max_interval_in_seconds == null ? true : (var.consistency_policy.level == "BoundedStaleness" && coalesce(var.consistency_policy.max_interval_in_seconds, 5) >= 5 && coalesce(var.consistency_policy.max_interval_in_seconds, 86400) <= 86400)
    error_message = "Invalid consistency policy value. \n Accepted range for 'max_staleness_prefix' value is 5 – 86400. Required when consistency_level is set to BoundedStaleness."
  }
  validation {
    condition     = var.consistency_policy.max_staleness_prefix == null ? true : (var.consistency_policy.level == "BoundedStaleness" && coalesce(var.consistency_policy.max_staleness_prefix, 10) >= 10 && coalesce(var.consistency_policy.max_staleness_prefix, 2147483647) <= 2147483647)
    error_message = "Invalid consistency policy value. \n Accepted range for 'max_staleness_prefix' value is 10 – 2147483647. Required when consistency_level is set to BoundedStaleness."
  }
}

variable "zone_redundancy_enabled" {
  description = "True to enabled zone redundancy on default primary location"
  type        = bool
  default     = true
}

variable "failover_locations" {
  description = "Configures the geographic locations the data is replicated. This block requires the following inputs:\n - `location`: The name of the Azure region to host replicated data. \n - `zone_redundant' (Optional) : Should zone redundancy be enabled for this region?"
  type = map(object({
    location       = string
    zone_redundant = optional(bool)
  }))
  default = null
}

variable "account_contributor_object_ids" {
  type        = list(string)
  description = "List of object IDs to be added with DocumentDB Account Contributor role on Cosmos DB."
  default     = []

  validation {
    condition = (
      length([for object_id in var.account_contributor_object_ids
        : 1 if can(regex("^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$", object_id))
      ]) == length(var.account_contributor_object_ids)
    )
    error_message = "Invalid object IDs for DocumentDB Account Contributor role. Object IDs must be valid GUIDs."
  }
}

variable "account_reader_object_ids" {
  type        = list(string)
  description = "List of object IDs to be added with Cosmos DB Account Contributor role on Cosmos DB."
  default     = []

  validation {
    condition = (
      length([for object_id in var.account_reader_object_ids
        : 1 if can(regex("^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$", object_id))
      ]) == length(var.account_reader_object_ids)
    )
    error_message = "Invalid object IDs for Cosmos DB Account Reader role. Object IDs must be valid GUIDs."
  }
}

variable "backup_operator_object_ids" {
  type        = list(string)
  description = "List of object IDs to be added with Cosmos DB Backup Operator role on Cosmos DB."
  default     = []

  validation {
    condition = (
      length([for object_id in var.backup_operator_object_ids
        : 1 if can(regex("^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$", object_id))
      ]) == length(var.backup_operator_object_ids)
    )
    error_message = "Invalid object IDs for Cosmos DB Backup Operator role. Object IDs must be valid GUIDs."
  }
}

variable "restore_operator_object_ids" {
  type        = list(string)
  description = "List of object IDs to be added with Cosmos DB Restore Operator role on Cosmos DB."
  default     = []

  validation {
    condition = (
      length([for object_id in var.restore_operator_object_ids
        : 1 if can(regex("^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$", object_id))
      ]) == length(var.restore_operator_object_ids)
    )
    error_message = "Invalid object IDs for Cosmos DB Restore Operator role. Object IDs must be valid GUIDs."
  }
}

variable "operator_object_ids" {
  type        = list(string)
  description = "List of object IDs to be added with Cosmos DB Operator role on Cosmos DB."
  default     = []

  validation {
    condition = (
      length([for object_id in var.operator_object_ids
        : 1 if can(regex("^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$", object_id))
      ]) == length(var.operator_object_ids)
    )
    error_message = "Invalid object IDs for Cosmos DB Operator role. Object IDs must be valid GUIDs."
  }
}

variable "azure_defender_enabled" {
  type        = bool
  description = "Is Azure Defender enabled for this Azure CosmosDB Account?"
  default     = false
}

variable "customer_managed_keys" {
  type = object({
    cmk_enabled              = bool
    user_managed_identity_id = string
    kvt_key_versionless_id   = string
  })
  description = "Specifies customer managed keys configuration. This block requires the following inputs:\n - `cmk_enabled`: If Customer Managed Key needs to be enabled? \n - `user_managed_identity_id`: Managed Identity to access Key Vault.  \n - `kvt_key_versionless_id` Versionless id of Key Vault's key "
  default = {
    cmk_enabled              = false
    user_managed_identity_id = ""
    kvt_key_versionless_id   = ""
  }
}