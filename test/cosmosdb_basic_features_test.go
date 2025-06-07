package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"os"
	"path/filepath"
	"testing"
)

type CosmosDbBasicTestCase struct {
	environment         string
	kind                string
	capabilities        []string
	consistencyPolicy   map[string]interface{}
	failOverLocations   map[string]map[string]interface{}
	enableAzureDefender bool
}

func TestBasicConfiguration(t *testing.T) {
	t.Parallel()

	testCases := []CosmosDbBasicTestCase{
		{
			environment:         "Development",
			kind:                "MongoDB",
			enableAzureDefender: false,
			capabilities:        []string{"DisableRateLimitingResponses", "EnableAggregationPipeline", "EnableMongo"},
			consistencyPolicy: map[string]interface{}{
				"level":                   "BoundedStaleness",
				"max_interval_in_seconds": int32(100),
				"max_staleness_prefix":    int32(900),
			},
			failOverLocations: map[string]map[string]interface{}{
				"eastus": {
					"location":       "eastus",
					"zone_redundant": false,
				},
			},
		},
		{
			environment: "Test",
			kind:        "GlobalDocumentDB",
			enableAzureDefender: true,
			capabilities:        []string{"DisableRateLimitingResponses"},
			consistencyPolicy: map[string]interface{}{
				"level":                   "BoundedStaleness",
				"max_interval_in_seconds": int32(5),
				"max_staleness_prefix":    int32(100),
			},
			failOverLocations: map[string]map[string]interface{}{
				"eastus": {
					"location":       "none",
					"zone_redundant": false,
				},
			},
		},
	}

	for _, testCase := range testCases {
		subTestName := fmt.Sprintf("%s-env-%s-kind",
			testCase.environment,
			testCase.kind)

		t.Run(subTestName, func(t *testing.T) {
			testCase := testCase
			t.Parallel()

			terraformDir := test_structure.CopyTerraformFolderToTemp(t, "..", "/test/basic")
			tempRootFolderPath, _ := filepath.Abs(filepath.Join(terraformDir, "../../.."))
			defer os.RemoveAll(tempRootFolderPath)

			Vars := map[string]interface{}{
				"environment":            testCase.environment,
				"kind":                   testCase.kind,
				"capabilities":           testCase.capabilities,
				"consistency_policy":     testCase.consistencyPolicy,
				"failover_locations":     testCase.failOverLocations,
				"azure_defender_enabled": testCase.enableAzureDefender,
			}
			terraformOptions := &terraform.Options{
				TerraformDir: terraformDir,
				Vars:         Vars,
			}

			if terraformOptions.Vars["environment"] == "Test" {
				delete(terraformOptions.Vars, "failover_locations")
			}

			defer terraform.Destroy(t, terraformOptions)
			terraform.InitAndApplyAndIdempotent(t, terraformOptions)
			accountName := terraform.Output(t, terraformOptions, "accountName")
			resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
			subscriptionID := terraform.Output(t, terraformOptions, "subscription_id")
			cosmosDbAccount := GetCosmosDBAccount(t, subscriptionID, resourceGroupName, accountName)
			cosmosDbATP := GetCosmosATP(t, subscriptionID, *cosmosDbAccount.Location, *cosmosDbAccount.ID) //"West Europe"

			assert.Equal(t, testCase.kind, string(cosmosDbAccount.Kind))
			assert.Equal(t, "Standard", string(cosmosDbAccount.DatabaseAccountOfferType))
			assert.Equal(t, "BoundedStaleness", string(cosmosDbAccount.ConsistencyPolicy.DefaultConsistencyLevel))
			assert.Equal(t, true, *cosmosDbAccount.EnableAutomaticFailover)
			assert.Equal(t, testCase.enableAzureDefender, *cosmosDbATP.IsEnabled)
		})
	}
}
