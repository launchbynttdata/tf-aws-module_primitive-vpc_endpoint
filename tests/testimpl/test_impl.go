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
func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	tfOptions := ctx.TerratestTerraformOptions()

	endpointID := terraform.Output(t, tfOptions, "endpoint_id")
	require.NotEmpty(t, endpointID, "endpoint_id output must not be empty")

	region := terraform.Output(t, tfOptions, "region")
	if region == "" {
		region = "us-east-2"
	}

	awsCfg, err := config.LoadDefaultConfig(context.Background(),
		config.WithRegion(region),
	)
	require.NoError(t, err, "failed to load AWS config")

	ec2Client := ec2.NewFromConfig(awsCfg)

	result, err := ec2Client.DescribeVpcEndpoints(context.Background(), &ec2.DescribeVpcEndpointsInput{
		VpcEndpointIds: []string{endpointID},
	})
	require.NoError(t, err, "failed to describe VPC endpoint %s", endpointID)
	require.Len(t, result.VpcEndpoints, 1, "expected exactly one endpoint")

	endpoint := result.VpcEndpoints[0]
	assert.Equal(t, "available", string(endpoint.State),
		"VPC endpoint should be in available state")
}
