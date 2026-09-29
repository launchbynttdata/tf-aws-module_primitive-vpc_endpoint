// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Package testimpl contains shared endpoint verification logic for the
// tf-aws-module_primitive-vpc_endpoint module.
//
// It is used by both post-deploy runners:
//   - post_deploy_functional: run read-only checks, then perform a write probe
//   - post_deploy_functional_readonly: run read-only checks only
package testimpl

import (
	"context"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	ec2types "github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type endpointVerification struct {
	client     *ec2.Client
	endpointID string
}

// TestComposableComplete runs read-only assertions first, then performs a
// small mutating operation (temporary tag add/remove) to prove write behavior.
func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	verification := verifyEndpointReadOnly(t, ctx)
	runEndpointTagWriteProbe(t, verification.client, verification.endpointID)
}

// TestComposableCompleteReadOnly validates the deployed endpoint via read-only
// SDK calls only.
func TestComposableCompleteReadOnly(t *testing.T, ctx types.TestContext) {
	verifyEndpointReadOnly(t, ctx)
}

func verifyEndpointReadOnly(t *testing.T, ctx types.TestContext) endpointVerification {
	t.Helper()

	tfOptions := ctx.TerratestTerraformOptions()

	endpointID := terraform.OutputContext(t, context.Background(), tfOptions, "endpoint_id")
	require.NotEmpty(t, endpointID, "endpoint_id output must not be empty")

	region := terraform.OutputContext(t, context.Background(), tfOptions, "region")
	if region == "" {
		region = "us-east-2"
	}

	expectedServiceName := fmt.Sprintf("com.amazonaws.%s.s3", region)
	expectedSubnetIDs := terraform.OutputListContext(t, context.Background(), tfOptions, "subnet_ids")
	require.Len(t, expectedSubnetIDs, 2, "complete example should create two endpoint subnets")
	expectedSecurityGroupID := terraform.OutputContext(t, context.Background(), tfOptions, "endpoint_security_group_id")
	require.NotEmpty(t, expectedSecurityGroupID, "endpoint_security_group_id output must not be empty")

	awsCfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
	require.NoError(t, err, "failed to load AWS config")

	ec2Client := ec2.NewFromConfig(awsCfg)
	endpoint := waitForEndpointAvailability(t, ec2Client, endpointID)

	assert.Equal(t, endpointID, aws.ToString(endpoint.VpcEndpointId), "endpoint ID should match Terraform output")
	assert.Equal(t, ec2types.VpcEndpointTypeInterface, endpoint.VpcEndpointType, "endpoint type should match module input")
	assert.Equal(t, expectedServiceName, aws.ToString(endpoint.ServiceName), "service name should match example configuration")
	assert.ElementsMatch(t, expectedSubnetIDs, endpoint.SubnetIds, "endpoint subnets should match example outputs")
	assert.ElementsMatch(t, []string{expectedSecurityGroupID}, securityGroupIDs(endpoint.Groups), "endpoint security groups should match example output")
	assert.True(t, strings.EqualFold(string(endpoint.State), "available"), "endpoint should reach available state")

	return endpointVerification{
		client:     ec2Client,
		endpointID: endpointID,
	}
}

func waitForEndpointAvailability(t *testing.T, client *ec2.Client, endpointID string) ec2types.VpcEndpoint {
	t.Helper()

	deadline := time.Now().Add(3 * time.Minute)
	for {
		result, err := client.DescribeVpcEndpoints(context.Background(), &ec2.DescribeVpcEndpointsInput{
			VpcEndpointIds: []string{endpointID},
		})
		require.NoError(t, err, "failed to describe VPC endpoint %s", endpointID)
		require.Len(t, result.VpcEndpoints, 1, "expected exactly one endpoint")

		endpoint := result.VpcEndpoints[0]
		state := strings.ToLower(string(endpoint.State))
		if state == "available" {
			return endpoint
		}
		if state == "failed" || state == "rejected" || state == "deleted" {
			require.FailNowf(t, "endpoint entered terminal failure state", "endpoint %s is in unexpected state %s", endpointID, endpoint.State)
		}
		if time.Now().After(deadline) {
			require.FailNowf(t, "timed out waiting for endpoint", "endpoint %s did not reach available state before timeout, last state: %s", endpointID, endpoint.State)
		}

		time.Sleep(10 * time.Second)
	}
}

func runEndpointTagWriteProbe(t *testing.T, client *ec2.Client, endpointID string) {
	t.Helper()

	probeKey := "LcafFunctionalWriteProbe"
	_, err := client.CreateTags(context.Background(), &ec2.CreateTagsInput{
		Resources: []string{endpointID},
		Tags: []ec2types.Tag{
			{
				Key:   aws.String(probeKey),
				Value: aws.String("true"),
			},
		},
	})
	require.NoError(t, err, "functional test should be able to add a temporary endpoint tag")

	_, err = client.DeleteTags(context.Background(), &ec2.DeleteTagsInput{
		Resources: []string{endpointID},
		Tags: []ec2types.Tag{
			{
				Key: aws.String(probeKey),
			},
		},
	})
	require.NoError(t, err, "functional test should be able to remove the temporary endpoint tag")
}

func securityGroupIDs(groups []ec2types.SecurityGroupIdentifier) []string {
	ids := make([]string, 0, len(groups))
	for _, group := range groups {
		ids = append(ids, aws.ToString(group.GroupId))
	}
	return ids
}
