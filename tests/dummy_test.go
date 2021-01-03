package test

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"

	"github.com/stretchr/testify/assert"
)

func TestE2E(t *testing.T) {
	t.Parallel()

	lbDNSName := "ipv4.icanhazip.com"

	response := makeHTTPreq(t, lbDNSName)
	terraformApplyCurrentTime := response.Body

	fileNames := [2]string{"thepathdoesntmatters", "anotherPath"}
	testURLdummy(t, lbDNSName, fileNames[0], 200, terraformApplyCurrentTime, 6)
}

func testURLdummy(t *testing.T, endpoint string, path string, expectedStatus int, expectedBody string, minHits int) {
	hits := 0
	url := fmt.Sprintf("%s://%s/%s", "http", endpoint, path)
	actionDescription := fmt.Sprintf("Calling %s", url)
	output := retry.DoWithRetry(t, actionDescription, 100, 30*time.Second, func() (string, error) {

		//we use our own client, because terratest http_utils panics on connection refused and stops test execution
		client := http.Client{
			// By default, Go does not impose a timeout, so an HTTP connection attempt can hang for a LONG time.
			Timeout: 10 * time.Second,
		}

		resp, err := client.Get(url)
		if err != nil {
			return "", fmt.Errorf("error on http get")
		}
		defer resp.Body.Close()
		body, err2 := ioutil.ReadAll(resp.Body)
		if err2 != nil {
			return "", fmt.Errorf("error reading http body")
		}

		var response httpResponseDummy
		response.Body = strings.TrimSpace(string(body))
		response.StatusCode = resp.StatusCode
		if response.StatusCode == expectedStatus {
			logger.Logf(t, "Got expected status code %d from URL %s", expectedStatus, url)
			hits++
		}

		if hits >= minHits {
			logger.Logf(t, "Got expected hits count: %d", minHits)
			return response.Body, nil
		}

		return "", fmt.Errorf("got status %d from %s. Expecting more status %d. Count %d/%d",
			response.StatusCode, url, expectedStatus, hits, minHits)
	})
	assert.Contains(t, output, expectedBody, "Body should contain expected text")
}

type httpResponseDummy struct {
	Body       string
	StatusCode int
}

func makeHTTPreq(t *testing.T, url string) httpResponseDummy {
	client := http.Client{
		// By default, Go does not impose a timeout, so an HTTP connection attempt can hang for a LONG time.
		Timeout: 10 * time.Second,
	}

	resp, err := client.Get("http://" + url)
	if err != nil {
		logger.Logf(t, "error on http get")
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)

	var response httpResponseDummy
	response.Body = strings.TrimSpace(string(body))
	response.StatusCode = resp.StatusCode
	return response
}
