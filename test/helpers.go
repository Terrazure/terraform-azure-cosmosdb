package test

import (
	helpers "github.com/Terrazure/terratest-helpers"
	"github.com/Azure/azure-sdk-for-go/profiles/latest/cosmos-db/mgmt/documentdb"
	security2 "github.com/Azure/azure-sdk-for-go/services/preview/security/mgmt/v3.0/security"
	"testing"
)

func GetCosmosDBAccount(t *testing.T, subscriptionID string, resourceGroupName string, accountName string) documentdb.DatabaseAccountGetResults {
	t.Helper()
	client := documentdb.NewDatabaseAccountsClient(subscriptionID)
	helpers.ConfigureAzureResourceClient(t, &client.Client)
	ctx, cancel := helpers.BuildDefaultHttpContext()
	defer cancel()
	cosmosDBAccount, err := client.Get(ctx, resourceGroupName, accountName)

	if err != nil {
		t.Fatalf("Error when fetching MongoDB Account '%s' in rg '%s'", accountName, resourceGroupName)
	}

	return cosmosDBAccount
}

func GetCosmosATP(t *testing.T, subscriptionID, location, resourceID string) security2.AdvancedThreatProtectionSetting {
	t.Helper()
	cosmosATPClient := security2.NewAdvancedThreatProtectionClient(subscriptionID, location)
	helpers.ConfigureAzureResourceClient(t, &cosmosATPClient.Client)
	ctx, cancel := helpers.BuildDefaultHttpContext()
	defer cancel()
	props, err := cosmosATPClient.Get(ctx, resourceID)
	if err != nil {
		t.Fatalf("Error when trying to get Cosmos DB ATP %s", err)
	}

	return props
}
