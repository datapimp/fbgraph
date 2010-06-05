require 'rubygems'
require 'rest_client'
require 'webrick'
require 'json' unless defined? JSON

module FacebookGraph
  
  module Callback
    class Server
      attr_reader :http, :options, :pid

      def initialize options={}
        @options = options
        @http = WEBrick::HTTPServer.new(:Port => @options[:port] || 8000)

        @http.mount "/callback", Hook
        
        trap("INT") { http.shutdown }
        
        @pid = Process.fork do
          http.start
        end
      end
      
      def kill
        Process.kill('INT',pid)
      end
    end
    
    class Hook < WEBrick::HTTPServlet::AbstractServlet
      def do_GET request,response
        response.status = 200
        response['Content-Type'] = "application/json"
        response.body = "{\"success\":true,\"method\":\"GET\"}"
      end
      
      def do_POST request, response
        response.status = 200
        response['Content-Type'] = "application/json"
        response.body = "{\"success\":true,\"method\":\"POST\"}"
      end
    end
  end
  
  class Client
    attr_accessor :options

    def initialize options={}
      @options = options
    end

    def get resource, parameters={}
      JSON.parse RestClient.get( build_uri(resource,parameters) )
    end

    def post resource, parameters={}
      JSON.parse RestClient.post( build_uri(resource,parameters) )
    end

    protected 

    def build_uri resource,parameters={}
      uri = "http://graph.facebook.com/" << resource
      uri << parameters.inject([]) {|a,k| a << k.join("=") }.join("&") unless parameters.empty?

      uri
    end
  end
end