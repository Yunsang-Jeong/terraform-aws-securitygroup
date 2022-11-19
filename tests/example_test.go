package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestExample(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputMapOfObjects(t, terraformOptions, "this")

	for _, securityGroupId := range outputs["security_group_id_map"].(map[string]interface{}) {
		assert.Regexp(t, "sg-\\d+", securityGroupId.(string))
	}
}
