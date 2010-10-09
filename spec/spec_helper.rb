$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'fakeweb'

require 'simple_xurrency'
require 'rspec'

module HelperMethods
  def mock_xurrency_api(from_currency, to_currency, amount, result, updated_at, options = {})
    args = [from_currency, to_currency, "1"]

    response = "{\"result\":{\"value\":#{result},\"target\":\"#{to_currency}\",\"base\":\"#{from_currency}\",\"updated_at\":\"#{updated_at}\"},\"status\":\"ok\"}"

    response = "{\"message\":\"#{options[:fail_with]}\", \"status\":\"fail\"\}" if options[:fail_with]

    FakeWeb.register_uri(:get, "http://xurrency.com/api/#{args.join('/')}", :body => response)
  end
end

RSpec.configuration.include(HelperMethods)