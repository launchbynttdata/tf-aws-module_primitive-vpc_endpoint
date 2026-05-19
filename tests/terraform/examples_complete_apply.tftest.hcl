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

// Applies the complete example module to validate end-to-end deployment behavior.
// The terraform test framework will automatically clean up after the run.
run "apply_complete_example" {
  command = apply

  module {
    source = "./examples/complete"
  }

  assert {
    condition     = can(regex("^vpce-", output.endpoint_id))
    error_message = "Expected endpoint_id output to be a VPC endpoint ID."
  }

  assert {
    condition     = output.endpoint_state == "available"
    error_message = "Expected endpoint_state to be available after apply."
  }

  assert {
    condition     = length(output.endpoint_dns_entries) > 0
    error_message = "Expected endpoint DNS entries to be present for interface endpoint."
  }
}
