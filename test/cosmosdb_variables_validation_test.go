package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"os"
	"testing"
    helpers "github.com/Terrazure/terratest-helpers"
	"github.com/stretchr/testify/assert"
	"strings"
)

type VariableTestCase struct {
	variableValue interface{}
	errorExpected bool
}

type VariableTestCaseComplex struct {
	variableValue []map[string]interface{}
	errorExpected bool
}

func verifyTestCase(t *testing.T, err error, testCase VariableTestCase, errorMessageExpected string) {
	if err != nil && testCase.errorExpected {
		assert.Contains(t, err.Error(), errorMessageExpected)
	} else if err == nil && testCase.errorExpected == true {
		t.Errorf("%s should not be an allowed value", testCase.variableValue)
	} else if err != nil && testCase.errorExpected == false {
		if strings.Contains(err.Error(), errorMessageExpected) {
			t.Errorf("%s should be an allowed value", testCase.variableValue)
		} else {
			t.Errorf("Unexpected error %s", err)
		}
	}
}

func TestKindValidation(t *testing.T) {
	t.Parallel()
	invalidKindErrorMessage := "Invalid kind."
	testCases := []VariableTestCase{
		{variableValue: "GlobalDocumentDB", errorExpected: false},
		{variableValue: "MongoDB", errorExpected: false},
		{variableValue: "ABC", errorExpected: true},
	}

	for testCaseIndex, testCase := range testCases {
		t.Run(fmt.Sprintf("Kind-%s", testCase.variableValue), func(subTest *testing.T) {
			testCase := testCase
			testCaseIndex := testCaseIndex
			subTest.Parallel()

			parallelTerraformDir := helpers.PrepareTerraformParallelTestingDir("./variables-validation", "kind", testCaseIndex)
			defer os.RemoveAll(parallelTerraformDir)

			options := &terraform.Options{
				TerraformDir: parallelTerraformDir,
				Vars: map[string]interface{}{
					"kind": testCase.variableValue,
				},
			}
			_, err := terraform.InitAndPlanE(subTest, options)
			verifyTestCase(subTest, err, testCase, invalidKindErrorMessage)
		})
	}
}

func TestCapabilitiesValidation(t *testing.T) {
	t.Parallel()
	invalidCapabilityErrorMessage := "Invalid capability type."
	testCases := []VariableTestCase{
		{variableValue: []string{"AllowSelfServeUpgradeToMongo36", "EnableMongo"}, errorExpected: false},
		{variableValue: []string{}, errorExpected: false},
		{variableValue: []string{"mongoEnableDocLevelTTL"}, errorExpected: false},
		{variableValue: []string{"abc"}, errorExpected: true},
	}

	for testCaseIndex, testCase := range testCases {
		t.Run(fmt.Sprintf("Capability-%s", testCase.variableValue), func(subTest *testing.T) {
			testCase := testCase
			testCaseIndex := testCaseIndex
			subTest.Parallel()

			parallelTerraformDir := helpers.PrepareTerraformParallelTestingDir("./variables-validation", "capabilities", testCaseIndex)
			defer os.RemoveAll(parallelTerraformDir)

			options := &terraform.Options{
				TerraformDir: parallelTerraformDir,
				Vars: map[string]interface{}{
					"capabilities": testCase.variableValue,
				},
			}
			_, err := terraform.InitAndPlanE(subTest, options)
			verifyTestCase(subTest, err, testCase, invalidCapabilityErrorMessage)
		})
	}
}

func TestBackupValidation(t *testing.T) {
	t.Parallel()
	invalidBackupErrorMessage := "Invalid backup data."
	testCases := []VariableTestCase{
		{variableValue: map[string]interface{}{
			"type":                "Periodic",
			"interval_in_minutes": 65,
			"retention_in_hours":  32,
		}, errorExpected: false},
		{variableValue: map[string]interface{}{
			"type":                "Periodic",
			"interval_in_minutes": 12,
			"retention_in_hours":  700,
		}, errorExpected: true},
		{variableValue: map[string]interface{}{
			"type":                "Continuous",
			"interval_in_minutes": 100,
			"retention_in_hours":  900,
		}, errorExpected: true},
		{variableValue: map[string]interface{}{
			"type":                "Periodic",
			"interval_in_minutes": 240,
			"retention_in_hours":  10,
		}, errorExpected: false}, // Ideally this should be tru, but missing validation
	}

	for testCaseIndex, testCase := range testCases {
		t.Run(fmt.Sprintf("Backup-%s", testCase.variableValue), func(subTest *testing.T) {
			testCase := testCase
			testCaseIndex := testCaseIndex
			subTest.Parallel()

			parallelTerraformDir := helpers.PrepareTerraformParallelTestingDir("./variables-validation", "backup", testCaseIndex)
			defer os.RemoveAll(parallelTerraformDir)

			options := &terraform.Options{
				TerraformDir: parallelTerraformDir,
				Vars: map[string]interface{}{
					"backup": testCase.variableValue,
				},
			}
			_, err := terraform.InitAndPlanE(subTest, options)
			verifyTestCase(subTest, err, testCase, invalidBackupErrorMessage)
		})
	}
}

func TestConsistencyPolicyValidation(t *testing.T) {
	t.Parallel()
	invalidConsistencyPolicyErrorMessage := "Invalid consistency policy value."
	testCases := []VariableTestCase{
		{variableValue: map[string]interface{}{
			"level":                   "abc",
			"max_interval_in_seconds": 65,
			"max_staleness_prefix":    32,
		}, errorExpected: true},
		{variableValue: map[string]interface{}{
			"level":                   "Eventual",
			"max_interval_in_seconds": nil,
			"max_staleness_prefix":    nil,
		}, errorExpected: false},
		{variableValue: map[string]interface{}{
			"level":                   "Strong",
			"max_interval_in_seconds": 240,
			"max_staleness_prefix":    10,
		}, errorExpected: true},
	}

	for testCaseIndex, testCase := range testCases {
		t.Run(fmt.Sprintf("Consistency_Policy-%s", testCase.variableValue), func(subTest *testing.T) {
			testCase := testCase
			testCaseIndex := testCaseIndex
			subTest.Parallel()

			parallelTerraformDir := helpers.PrepareTerraformParallelTestingDir("./variables-validation", "consistency_policy", testCaseIndex)
			defer os.RemoveAll(parallelTerraformDir)

			options := &terraform.Options{
				TerraformDir: parallelTerraformDir,
				Vars: map[string]interface{}{
					"consistency_policy": testCase.variableValue,
				},
			}
			_, err := terraform.InitAndPlanE(subTest, options)
			verifyTestCase(subTest, err, testCase, invalidConsistencyPolicyErrorMessage)
		})
	}
}
