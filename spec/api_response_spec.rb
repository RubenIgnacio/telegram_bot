# frozen_string_literal: true
require 'minitest_helper'

describe TelegramBot::ApiResponse do
  include TestHelper

  ApiResponse = TelegramBot::ApiResponse

  def test_error_handling
    VCR.use_cassette("integration_test") do
      assert_raises(ApiResponse::ResponseError) do
        new_test_api_response.get('getNothing')
      end
    end
    VCR.use_cassette("integration_test") do
      new_test_api_response.get('getNothing') do |err|
        assert_kind_of ApiResponse::ResponseError, err
      end
    end
  end

  def test_success_case
    VCR.use_cassette("integration_test") do
      response = new_test_api_response.get("getUpdates", offset: 0, timeout: 50)
      assert_kind_of ApiResponse::Response, response
      assert_kind_of Array, response.result
      assert_kind_of Integer, response.result.first["update_id"]
    end
  end
end
