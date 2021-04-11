package test

import (
	"fmt"
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

	t.Run("Ping the private instance", func(t *testing.T) {
		// SSH into public instance
		// ping private box ip
		// get responses
	})
}
