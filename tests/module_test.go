package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const awsRegion = "ap-northeast-2"
const description = "Terratest"

func TestModule(t *testing.T) {
	t.Parallel()

	vpc := aws.GetDefaultVpc(t, awsRegion)
	vpcId := vpc.Id
	securityGroups := []map[string]interface{}{
		{
			"identifier":       "terratest-securitygroup-00",
			"description":      description,
			"name_tag_postfix": "terratest-securitygroup-00",
			"ingresses": []map[string]interface{}{
				{
					"identifier":  "ssh",
					"description": "ssh",
					"from_port":   "22",
					"to_port":     "22",
					"protocol":    "tcp",
					"cidr_blocks": []string{"1.2.3.4/32"},
				},
				{
					"identifier":  "itself",
					"description": "itself",
					"from_port":   "443",
					"to_port":     "443",
					"protocol":    "tcp",
					"self":        true,
				},
			},
			"egresses": []map[string]interface{}{},
		},
		{
			"identifier":       "terratest-securitygroup-01",
			"description":      description,
			"name_tag_postfix": "terratest-securitygroup-01",
			"ingresses": []map[string]interface{}{
				{
					"identifier":                       "web",
					"description":                      "web",
					"from_port":                        "80",
					"to_port":                          "80",
					"protocol":                         "tcp",
					"source_security_group_identifier": "terratest-securitygroup-00",
				},
			},
			"egresses": []map[string]interface{}{
				{
					"identifier":  "default",
					"description": "Default",
					"from_port":   0,
					"to_port":     0,
					"protocol":    "-1",
					"cidr_blocks": []string{"0.0.0.0/0"},
				},
			},
		},
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"vpc_id":          vpcId,
			"security_groups": securityGroups,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	securityGroupIdMap := terraform.OutputMap(t, terraformOptions, "security_group_id_map")

	for _, securityGroupId := range securityGroupIdMap {
		assert.Regexp(t, "sg-\\d+", securityGroupId)
	}
}
