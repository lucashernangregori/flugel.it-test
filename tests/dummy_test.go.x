package test

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
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
	//lbDNSName := "traefik-lb-1915134126.us-east-1.elb.amazonaws.com"
	lbDNSName := "localhost"

	fileNames := [2]string{"test1.txt", "test2.txt"}
	testURLdummy(t, lbDNSName, fileNames[0], 200, terraformApplyCurrentTime, 6)
}

func testURLdummy(t *testing.T, endpoint string, path string, expectedStatus int, expectedBody string, minHits int) {
	hits := 0
	url := fmt.Sprintf("%s://%s/%s", "http", endpoint, path)
	actionDescription := fmt.Sprintf("Calling %s", url)
	output := retry.DoWithRetry(t, actionDescription, 100, 30*time.Second, func() (string, error) {
		body, err := func() (string, error) {
			defer func() {
				if r := recover(); r != nil {
					fmt.Println("panic occured and cached: ", r)
				}
			}()

			//panic("got 2")
			//statusCode, body := http_helper.HttpGet(t, url, nil)
			client := http.Client{
				// By default, Go does not impose a timeout, so an HTTP connection attempt can hang for a LONG time.
				Timeout: 10 * time.Second,
				// Include the previously created transport config
			}

			resp, err := client.Get(url)
			if err != nil {
				return "", fmt.Errorf("error al hacer el get")
			}
			defer resp.Body.Close()
			body, err2 := ioutil.ReadAll(resp.Body)
			if err2 != nil {
				return "", fmt.Errorf("error al leer el body")
			}

			//resp.StatusCode, strings.TrimSpace(string(body))
			var response httpResponse
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

			return "", fmt.Errorf("got status %d instead of the expected %d from %s", response.StatusCode, expectedStatus, url)
		}()
		return body, err
	})
	assert.Contains(t, output, expectedBody, "Body should contain expected text")
}

//channel := make(chan httpResponse)
//go makeRequest(t, url, channel)
//response := makeRequest(t, url)
// defer func() httpResponse {
// 	var response httpResponse
// 	response.Body = ""
// 	response.StatusCode = 0
// 	logger.Log(t, "recover function called")
// 	return response
// }()
// statusCode, body := http_helper.HttpGet(t, url, nil)
// var response httpResponse
// response.Body = body
// response.StatusCode = statusCode
//response := <-channel
func makeRequest(t *testing.T, url string) httpResponse {
	defer func() httpResponse {
		fmt.Println("recover")
		recover()
		var response httpResponse
		response.Body = ""
		response.StatusCode = 0
		logger.Log(t, "recover function called")
		return response
	}()
	statusCode, body := http_helper.HttpGet(t, url, nil)
	var response httpResponse
	response.Body = body
	response.StatusCode = statusCode
	return response
}

func makeRequestAsync(t *testing.T, url string, c chan httpResponse) {
	statusCode, body := http_helper.HttpGet(t, url, nil)
	var response httpResponse
	response.Body = body
	response.StatusCode = statusCode
	c <- response // send response to channel
}

type httpResponse struct {
	Body       string
	StatusCode int
}
