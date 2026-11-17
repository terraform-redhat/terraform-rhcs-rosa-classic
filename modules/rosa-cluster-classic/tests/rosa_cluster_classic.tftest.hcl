// Copyright Red Hat
// SPDX-License-Identifier: Apache-2.0

mock_provider "aws" {
  alias = "default"

  mock_data "aws_partition" {
    defaults = {
      dns_suffix         = "amazonaws.com"
      id                 = "aws"
      partition          = "aws"
      reverse_dns_prefix = "amazonaws.com"
    }
  }

  mock_data "aws_subnet" {
    defaults = {
      availability_zone = "us-east-1a"
      id                = "subnet-fake12345"
    }
  }
}

mock_provider "rhcs" {
  alias           = "import_sim"
  override_during = plan

  mock_resource "rhcs_cluster_rosa_classic" {
    defaults = {
      id = "rhcs-fake-classic-cluster-id"
    }
  }
}

variables {
  cluster_name           = "existing-classic-cluster"
  openshift_version      = "4.15.0"
  oidc_config_id         = "00000000000000000000000000000000"
  operator_role_prefix   = "test-operator-prefix"
  account_role_prefix    = "test-account-prefix"
  aws_subnet_ids         = ["subnet-fake12345"]
  aws_availability_zones = ["us-east-1a"]
  aws_account_id         = "123456789012"
  aws_account_arn        = "arn:aws:iam::123456789012:root"
  aws_region             = "us-east-1"
}

run "delete_protection_null" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    delete_protection = null
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.delete_protection == false
    error_message = "delete_protection must be false when unset."
  }
}

run "delete_protection_enabled" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    delete_protection = true
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.delete_protection == true
    error_message = "delete_protection must be true when explicitly enabled."
  }
}

run "delete_protection_disabled" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    delete_protection = false
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.delete_protection == false
    error_message = "delete_protection must be false when explicitly disabled."
  }
}

run "channel_invalid_format" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    channel = "invalid-channel"
  }

  expect_failures = [
    var.channel
  ]
}

run "channel_valid_format" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    channel = "stable-4.16"
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.channel == "stable-4.16"
    error_message = "channel must be passed through to the resource."
  }
}

run "version_channel_group_invalid" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    version_channel_group = "candidate"
  }

  expect_failures = [var.version_channel_group]
}

run "version_channel_group_eus" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    version_channel_group = "eus"
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.channel_group == "eus"
    error_message = "version_channel_group must be passed through to the resource."
  }
}

run "version_channel_group_fast" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    version_channel_group = "fast"
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.channel_group == "fast"
    error_message = "version_channel_group must accept 'fast' and pass it through to the resource."
  }
}

// The two runs below use issensitive(), which requires Terraform >= 1.8. The module
// itself still supports the lower required_version in versions.tf; only this test
// suite needs the newer CLI, which the pinned CI Terraform provides.
//
// Do not "simplify" these assertions away: they are the proof that the proxy inputs
// carry a sensitivity mark. Note that the rhcs provider schema already marks
// proxy.http_proxy, proxy.https_proxy and proxy.additional_trust_bundle sensitive on
// its own, so asserting on those attributes would pass even without the module-level
// sensitive = true. The discriminating checks are issensitive(var.*) and the whole
// proxy object / proxy.no_proxy being marked, which only happens because the module's
// sensitive inputs appear in the conditional predicate in main.tf.
run "proxy_inputs_are_sensitive" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    http_proxy              = "http://proxy.example.com:3128"
    https_proxy             = "https://proxy.example.com:3129"
    no_proxy                = ".example.com"
    additional_trust_bundle = "mock-pem-bundle-not-a-real-certificate"
  }

  assert {
    condition     = issensitive(var.http_proxy)
    error_message = "http_proxy must be declared sensitive."
  }

  assert {
    condition     = issensitive(var.https_proxy)
    error_message = "https_proxy must be declared sensitive."
  }

  assert {
    condition     = issensitive(var.additional_trust_bundle)
    error_message = "additional_trust_bundle must be declared sensitive."
  }

  assert {
    condition     = !issensitive(var.no_proxy)
    error_message = "no_proxy must stay non-sensitive, matching the rhcs provider schema."
  }

  assert {
    condition     = issensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy)
    error_message = "The proxy object must be sensitive because sensitive inputs drive the conditional that builds it."
  }

  assert {
    condition     = issensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy.no_proxy)
    error_message = "no_proxy is redacted inside the proxy object because the enclosing conditional predicate is sensitive."
  }

  assert {
    condition     = nonsensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy.http_proxy) == "http://proxy.example.com:3128"
    error_message = "http_proxy must still reach the resource unchanged."
  }

  assert {
    condition     = nonsensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy.https_proxy) == "https://proxy.example.com:3129"
    error_message = "https_proxy must still reach the resource unchanged."
  }

  assert {
    condition     = nonsensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy.no_proxy) == ".example.com"
    error_message = "no_proxy must still reach the resource unchanged."
  }

  assert {
    condition     = nonsensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy.additional_trust_bundle) == "mock-pem-bundle-not-a-real-certificate"
    error_message = "additional_trust_bundle must still reach the resource unchanged."
  }
}

run "proxy_absent_when_all_proxy_inputs_null" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    http_proxy              = null
    https_proxy             = null
    no_proxy                = null
    additional_trust_bundle = null
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy == null
    error_message = "proxy must be null when every proxy input is unset."
  }
}

// Partial branch of the main.tf conditional: only no_proxy is set, the other three
// inputs are null. The object is still built, and it is still sensitive as a whole --
// a null value of a sensitive variable keeps its mark, so "var.http_proxy != null"
// evaluates to a sensitive false and the predicate stays sensitive no matter which of
// the four inputs are set. The three unset members plan as null.
run "proxy_partial_only_no_proxy_set" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    http_proxy              = null
    https_proxy             = null
    no_proxy                = ".example.com"
    additional_trust_bundle = null
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy != null
    error_message = "proxy must still be built when only no_proxy is set."
  }

  assert {
    condition     = nonsensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy.no_proxy) == ".example.com"
    error_message = "no_proxy must reach the resource unchanged when it is the only proxy input set."
  }

  assert {
    condition     = nonsensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy.http_proxy) == null
    error_message = "http_proxy must plan as null when it is unset."
  }

  assert {
    condition     = nonsensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy.https_proxy) == null
    error_message = "https_proxy must plan as null when it is unset."
  }

  assert {
    condition     = nonsensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy.additional_trust_bundle) == null
    error_message = "additional_trust_bundle must plan as null when it is unset."
  }

  assert {
    condition     = issensitive(rhcs_cluster_rosa_classic.rosa_classic_cluster.proxy)
    error_message = "The proxy object stays sensitive even when only no_proxy is set, because the null sensitive inputs keep their mark in the conditional predicate."
  }
}

run "trust_policy_external_id_is_passed_to_sts" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    trust_policy_external_id = "test-external-id-12345"
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.sts.trust_policy_external_id == "test-external-id-12345"
    error_message = "trust_policy_external_id must be passed to the cluster STS settings."
  }
}

run "default_ingress_component_routes_are_passed_to_resource" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    default_ingress_component_routes = {
      oauth = {
        hostname       = "oauth.apps.example.com"
        tls_secret_ref = "oauth-tls"
      }
      console = {
        hostname       = "console.apps.example.com"
        tls_secret_ref = "console-tls"
      }
    }
  }

  assert {
    condition     = length(rhcs_default_ingress.default_ingress.component_routes) == 2
    error_message = "The default ingress must contain both configured component routes."
  }

  assert {
    condition     = rhcs_default_ingress.default_ingress.component_routes["oauth"].hostname == "oauth.apps.example.com" && rhcs_default_ingress.default_ingress.component_routes["oauth"].tls_secret_ref == "oauth-tls"
    error_message = "The OAuth component route must reach the RHCS resource."
  }

  assert {
    condition     = rhcs_default_ingress.default_ingress.component_routes["console"].hostname == "console.apps.example.com" && rhcs_default_ingress.default_ingress.component_routes["console"].tls_secret_ref == "console-tls"
    error_message = "The console component route must reach the RHCS resource."
  }
}

run "channel_and_version_channel_group_mutual_exclusion" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    channel               = "stable-4.16"
    version_channel_group = "stable"
  }

  expect_failures = [
    rhcs_cluster_rosa_classic.rosa_classic_cluster
  ]
}

run "max_cluster_wait_timeout_unset_passthrough" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    wait_for_create_complete            = true
    max_cluster_wait_timeout_in_minutes = null
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.max_cluster_wait_timeout_in_minutes == null
    error_message = "max_cluster_wait_timeout_in_minutes must pass through as null when unset."
  }
}

run "max_cluster_wait_timeout_set_passthrough" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    wait_for_create_complete            = true
    max_cluster_wait_timeout_in_minutes = 90
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.max_cluster_wait_timeout_in_minutes == 90
    error_message = "max_cluster_wait_timeout_in_minutes must pass through to the resource when set."
  }
}

run "max_cluster_wait_timeout_no_effect_branch" {
  command = plan

  providers = {
    aws  = aws.default
    rhcs = rhcs.import_sim
  }

  variables {
    wait_for_create_complete            = false
    max_cluster_wait_timeout_in_minutes = 90
  }

  assert {
    condition     = rhcs_cluster_rosa_classic.rosa_classic_cluster.max_cluster_wait_timeout_in_minutes == 90
    error_message = "max_cluster_wait_timeout_in_minutes must still pass through when wait_for_create_complete is false."
  }
}
