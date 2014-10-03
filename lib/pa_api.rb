require "pa_api/version"

# Provides functionality to make POA and PBA API calls.
module PaApi
  require 'xmlrpc/client'
  require 'base64'

  # Provides a connection to the defualt POA API, as set in ENV['POA_API']
  class POA
    def initialize(host: ENV['POA_API'], path: '/RPC2', port: 8440)
      @conn = XMLRPC::Client.new3(host: host, path: path, port: port)
    end

    # Makes a call to the POA API, with the method param being the full POA
    # method name, as a string, and an optional params Hash.
    # Returns a Hash result.
    def call(method, params = {})
      begin
        @conn.call(method, params)
      rescue => e
        return e
      end
    end
  end

  # Provides a connection to the default PBA API as configued in ENV['PBA_API']
  class PBA
    def initialize(host: ENV['PBA_API'], path: '/RPC2', port: 5224)
      @conn = XMLRPC::Client.new3(host: host, path: path, port: port)
    end

    # Makes a call to the PBA API, with the method param being the full method
    # name, as a string, and an optional params Array. The server param can
    # also be supplied for API calls that do not use 'BM'.
    # Returns a Hash result.
    def call(method, params = [], server = 'BM')
      begin
        {
          status: 0,
          result:  @conn.call(
                    :Execute,
                    Method: method,
                    Server: server,
                    Params: params
                  )['Result'][0]
        }
      rescue XMLRPC::FaultException => e
        {
          error_message: Base64.decode64(e.faultString).strip,
          status:       -1,
          method:       method,
          params:       params,
          result:       nil
        }
      rescue => e
        {
          status:       -1,
          result:        nil,
          method:        method,
          params:        params,
          error_message: e
        }
      end
    end
  end
end

