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

// Package testimpl contains the shared test implementation for the
// tf-aws-module_primitive-vpc_endpoint module. It is invoked by the
// post_deploy_functional test runner after Terraform has applied the
// examples/complete configuration.
package testimpl

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestComposableComplete validates a deployed VPC endpoint is in the expected state.
//
// Verification steps:
//  1. Read the endpoint ID from the Terraform outputs.
//  2. Load AWS credentials from the environment (supports SSO, instance profile, etc.).
//  3. Call DescribeVpcEndpoints to retrieve the live resource.
//  4. Assert that the endpoint state is "available", confirming the resource was
//     provisioned successfully and is ready to serve traffic.
func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	tfOptions := ctx.TerratestTerraformOptions()

	// Retrieve the endpoint ID created by the module under test.
	endpointID := terraform.Output(t, tfOptions, "endpoint_id")
	require.NotEmpty(t, endpointID, "endpoint_id output must not be empty")

	// Fall back to the example default region if the output is absent.
	region := terraform.Output(t, tfOptions, "region")
	if region == "" {
		region = "us-east-2"
	}

	// Load AWS config from the environment. The test runner is expected to have
	// valid credentials available (e.g. via AWS_PROFILE, AWS_DEFAULT_REGION, or
	// an IAM role attached to the CI runner).
	awsCfg, err := config.LoadDefaultConfig(context.Background(),
		config.WithRegion(region),
	)
	require.NoError(t, err, "failed to load AWS config")

	ec2Client := ec2.NewFromConfig(awsCfg)

	// Describe the specific endpoint to verify its live state. Using the ID
	// directly avoids paginating through unrelated endpoints.
	result, err := ec2Client.DescribeVpcEndpoints(context.Background(), &ec2.DescribeVpcEndpointsInput{
		VpcEndpointIds: []string{endpointID},
	})
	require.NoError(t, err, "failed to describe VPC endpoint %s", endpointID)
	require.Len(t, result.VpcEndpoints, 1, "expected exactly one endpoint")

	endpoint := result.VpcEndpoints[0]

	// "available" is the terminal success state for a VPC endpoint. Any other
	// state (pending, pendingAcceptance, rejected, failed) indicates the
	// endpoint is not yet ready or encountered an error.
	assert.Equal(t, "available", string(endpoint.State),
		"VPC endpoint should be in available state")
}
