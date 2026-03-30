mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      name = "us-east-1"
    }
  }

  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }

  mock_resource "aws_iam_openid_connect_provider" {
    defaults = {
      arn = "arn:aws:iam::123456789012:oidc-provider/mock"
    }
  }
}

mock_provider "rhcs" {
  mock_resource "rhcs_rosa_oidc_config" {
    defaults = {
      id                = "mock-oidc-config"
      oidc_endpoint_url = "mock.example.com"
      thumbprint        = "0123456789abcdef0123456789abcdef01234567"
    }
  }
}

mock_provider "time" {
  mock_resource "time_sleep" {
    defaults = {
      id = "mock-sleep"
    }
  }
}

mock_provider "null" {
  mock_resource "null_resource" {
    defaults = {
      id = "mock-null"
    }
  }
}

run "oidc_prefix_exceeds_max_length" {
  command = plan

  variables {
    managed     = true
    oidc_prefix = "abcdefghijklmnopq"
  }

  expect_failures = [
    var.oidc_prefix
  ]
}

run "oidc_prefix_invalid_pattern" {
  command = plan

  variables {
    managed     = true
    oidc_prefix = "Invalidprefix12"
  }

  expect_failures = [
    var.oidc_prefix
  ]
}
