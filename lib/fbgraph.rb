require 'rubygems'
require 'rest_client'
require 'webrick'
require 'json' unless defined? JSON

module FacebookGraph
  module Callback
    WorkingDirectory = File.expand_path( File.dirname(__FILE__) )  
    
    class Tunnel
      attr_reader :pid, :configuration, :options
      
      def initialize options={}
        @options = options
        @configuration = Tunnel.configuration['ssh_tunnel']
        start
      end
      
      def self.configuration
        @configuration ||= YAML.load_file("#{ File.dirname(__FILE__) }/../config/graph.yaml")
      end
      
      def callback_uri
        "http://#{ configuration['public_host'] }:#{ configuration['public_port']}/callback"
      end
      
      def start
        #TODO figure out a way to get the actual PID of the process being called
        tmp = Process.fork do
          system "ssh -nNT -g -R 0.0.0.0:#{ configuration['public_port'] }:0.0.0.0:#{ configuration['local_port'] } #{configuration['public_username']}@#{configuration['public_host']}"
        end
        
        # FIXME
        @pid = tmp.to_i + 1
        
        File.open(Tunnel.pid_file,"w") do |f|
          f << pid
        end
      end
      
      def shutdown
        Process.kill('TERM',pid)
        FileUtils.rm("#{ Tunnel.pid_file }")
      end

      def self.pid_file
       File.join(WorkingDirectory, "../tmp/fbcbtunnel.pid")  
      end
    end
    
    class Server
      attr_reader :http, :options, :pid, :configuration, :tunnel
      
      def initialize options={}
        @options = options
        @configuration = Server.configuration

        @http = WEBrick::HTTPServer.new(:Port => @options[:port] || 8000)
        
        @http.mount "/callback", Hook
        
        ["INT","TERM"].each do |signal| 
          trap(signal) { http.shutdown }
        end
        
        start
      end
      
      def start
        @pid = Process.fork { http.start }

        File.open(Server.pid_file,"w") do |f|
          f << pid
        end
        
        if Server.use_tunnel?
          @tunnel = Tunnel.new
          sleep 3 #give the tunnel time to connect
        end
      end
      
      def shutdown
        Process.kill('TERM',pid)
        FileUtils.rm("#{ Server.pid_file }")
        tunnel.shutdown if Server.use_tunnel?
      end
      
      def self.use_tunnel?
        configuration['ssh_tunnel'] && configuration['ssh_tunnel']['use_tunnel']
      end

      def self.pid_file
       File.join(WorkingDirectory, "../tmp/fbcbserver.pid")  
      end

      def self.configuration
        @configuration ||= YAML.load_file("#{ File.dirname(__FILE__) }/../config/graph.yaml")
      end
    end
    
    #TODO build out the handler objects for dealing with things like authorization
    class Hook < WEBrick::HTTPServlet::AbstractServlet
      def do_GET request,response
        puts response.inspect
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
    attr_reader :configuration
    
    def initialize options={}
      @options = options
      @configuration = YAML.load_file("#{ File.dirname(__FILE__) }/../config/graph.yaml")
    end
    
    def auth_get resource, parameters={}
      parameters.merge! :access_token => configuration['graph_api']['access_token']
      get(resource,parameters)
    end
    
    def get resource, parameters={}
      puts "Getting #{ build_uri(resource,parameters) }"
      JSON.parse RestClient.get( build_uri(resource,parameters) )
    end

    def post resource, parameters={}
      JSON.parse RestClient.post( build_uri(resource,parameters) )
    end
    
    # redirect the user in their browser to this url
    # this will authorize us
    def fetch_code_url
      build_uri("oauth/authorize", {
        :client_id=> configuration['graph_api']['client_id'],
        :redirect_uri => callback_uri
      })
    end
    
    def fetch_authorization_url
      build_uri("oauth/access_token", {
        :client_id=> configuration['graph_api']['client_id'],
        :client_secret => configuration['graph_api']['secret'],
        :redirect_uri => callback_uri,
        :code => configuration['graph_api']['code'],
      })
    end
    
    def sample
      "http://localhost:8000/callback?code=2.8xCTEKzLYJsxHitFi53pUQ__.3600.1275807600-606735534%7CMCeCKkpMGX0t9eJ95_KauWXCAXw."
    end

    protected 

    def callback_uri
      Callback::Server.use_tunnel? ? "http://#{ configuration['ssh_tunnel']['public_host'] }:#{ configuration['ssh_tunnel']['public_port'] }/callback/" : Server.configuration.callback_url
    end
    
    def build_uri resource,parameters={}
      uri = "https://graph.facebook.com/" << "#{ resource }?"
      uri << parameters.inject([]) {|a,k| a << k.join("=") }.join("&") unless parameters.empty?

      uri
    end
  end
end

#@server = FacebookGraph::Callback::Server.new

