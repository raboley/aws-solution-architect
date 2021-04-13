package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAwsHelloWorldExample(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
	})
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	publicIp := terraform.Output(t, terraformOptions, "public_ip")

	t.Run("We can talk to public", func(t *testing.T) {
		url := fmt.Sprintf("http://%s:80", publicIp)
		http_helper.HttpGetWithRetry(t, url, nil, 200, "I'm healthy!", 30, 5*time.Second)
	})

	t.Run("Public can talk to Private", func(t *testing.T) {
		privateIp := terraform.Output(t, terraformOptions, "private_instance_ip")
		url := fmt.Sprintf("http://%s:80/greet/%s/", publicIp, privateIp)
		http_helper.HttpGetWithRetryWithCustomValidation(t, url, nil, 30, 5*time.Second, ValidateGreeting)
	})
}

func ValidateGreeting(statusCode int, body string) bool {
	return statusCode == 200 && strings.Contains(body, "says: I'm healthy!")
}
