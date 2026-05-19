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

// Package test is the post-deploy functional test entry point for the
// tf-aws-module_primitive-vpc_endpoint module.
//
// Test flow (managed by lcaf-component-terratest/lib.RunSetupTestTeardown):
//  1. terraform init + apply against examples/complete using test.tfvars
//  2. Call TestComposableComplete (defined in tests/testimpl) to assert state
//  3. terraform destroy to clean up all AWS resources
//
// Run with:
//
//	cd tests/post_deploy_functional && go test -v -timeout 30m
//
// Or via the repo Makefile:
//
//	make test
package test

import (
	"testing"

	"github.com/launchbynttdata/lcaf-component-terratest/lib"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/launchbynttdata/tf-aws-module_primitive-vpc_endpoint/tests/testimpl"
)

const (
	// testConfigsExamplesFolderDefault is the path to the Terraform example used
	// as the test fixture, relative to this file's directory.
	testConfigsExamplesFolderDefault = "../../examples/complete"

	// infraTFVarFileNameDefault is the .tfvars file that supplies input values
	// for the example during testing.
	infraTFVarFileNameDefault = "test.tfvars"
)

// TestVpcEndpointPrimitive is the top-level test that exercises the complete
// example configuration. It relies on real AWS credentials being available in
// the environment and will create and destroy actual AWS resources.
func TestVpcEndpointPrimitive(t *testing.T) {
	ctx := types.CreateTestContextBuilder().
		SetTestConfig(&testimpl.ThisTFModuleConfig{}).
		SetTestConfigFolderName(testConfigsExamplesFolderDefault).
		SetTestConfigFileName(infraTFVarFileNameDefault).
		// IS_TERRAFORM_IDEMPOTENT_APPLY: run a second apply after the first and
		// assert no changes — this catches resources that are not truly idempotent.
		SetTestSpecificFlags(map[string]types.TestFlags{
			"complete": {"IS_TERRAFORM_IDEMPOTENT_APPLY": true},
		}).
		Build()

	lib.RunSetupTestTeardown(t, *ctx, testimpl.TestComposableComplete)
}
