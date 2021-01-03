package test

import (
	"testing"

	helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/stretchr/testify/assert"
)

func TestE2E(t *testing.T) {
	t.Parallel()

	terraformApplyCurrentTime := "1"
	lbDNSName := "2"
	url := lbDNSName + "/test1.txt"
	statusCode, body := helper.HttpGet(t, url, nil)
	assert.Equal(t, statusCode, 200)
	assert.Equal(t, body, terraformApplyCurrentTime)
}
