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
	//defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
	publicIp := terraform.Output(t, terraformOptions, "public_ip")

	t.Run("Test Ability to hit public IP", func(t *testing.T) {
		// website::tag::5:: Make an HTTP request to the instance and make sure we get back a 200 OK with the body "Hello, World!"
		url := fmt.Sprintf("http://%s:80", publicIp)
		http_helper.HttpGetWithRetry(t, url, nil, 200, "I'm healthy!", 30, 5*time.Second)
	})

	t.Run("Test Connection to Private Instance", func(t *testing.T) {
		privateIp := terraform.Output(t, terraformOptions, "private_instance_ip")
		url := fmt.Sprintf("http://%s:80/greet/%s:8080/", publicIp, privateIp)
		http_helper.HttpGetWithRetryWithCustomValidation(t, url, nil, 30, 5*time.Second, ValidateGreeting)

	})
}

func ValidateGreeting(statusCode int, body string) bool {
	return statusCode == 200 && strings.Contains(body, "says: Hello, World!")
}
