package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"

	"github.com/stretchr/testify/assert"
)

func TestE2E(t *testing.T) {
	t.Parallel()

	terraformApplyCurrentTime := "2021-01-03T08:38:35Z"
	lbDNSName := "traefik-lb-1915134126.us-east-1.elb.amazonaws.com"

	fileNames := [2]string{"test1.txt", "test2.txt"}
	testURLdummy(t, lbDNSName, fileNames[0], 200, terraformApplyCurrentTime)
}

func testURLdummy(t *testing.T, endpoint string, path string, expectedStatus int, expectedBody string) {
	url := fmt.Sprintf("%s://%s/%s", "http", endpoint, path)
	actionDescription := fmt.Sprintf("Calling %s", url)
	output := retry.DoWithRetry(t, actionDescription, 10, 2*time.Minute, func() (string, error) {
		statusCode, body := http_helper.HttpGet(t, url, nil)
		if statusCode == expectedStatus {
			logger.Logf(t, "Got expected status code %d from URL %s", expectedStatus, url)
			return body, nil
		}
		return "", fmt.Errorf("got status %d instead of the expected %d from %s", statusCode, expectedStatus, url)
	})
	assert.Contains(t, output, expectedBody, "Body should contain expected text")
}
