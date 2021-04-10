package test

import (
	"fmt"
	"golang.org/x/crypto/ssh"
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
		url := fmt.Sprintf("http://%s:8080", publicIp)
		http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 30, 5*time.Second)
	})

	t.Run("Ping the private instance", func(t *testing.T) {
		// SSH into public instance
		connectToHost("ubuntu", publicIp)
		// ping private box ip
		// get responses
	})
}

func connectToHost(user, host string) (*ssh.Client, *ssh.Session, error) {
	var pass string
	fmt.Print("Password: ")
	fmt.Scanf("%s\n", &pass)

	sshConfig := &ssh.ClientConfig{
		User: user,
		Auth: []ssh.AuthMethod{ssh.Password(pass)},
	}
	sshConfig.HostKeyCallback = ssh.InsecureIgnoreHostKey()

	client, err := ssh.Dial("tcp", host, sshConfig)
	if err != nil {
		return nil, nil, err
	}

	session, err := client.NewSession()
	if err != nil {
		client.Close()
		return nil, nil, err
	}

	return client, session, nil
}
