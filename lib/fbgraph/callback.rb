module FacebookGraph
  module Callback
    class Tunnel
      attr_reader :pid, :configuration, :options
    
      def initialize options={}
        @options = options
        start
      end
      
      def callback_uri
        "http://#{ options['host'] }:#{ options['port']}/fbgraph_callback"
      end
    
      def start
        #TODO figure out a way to get the actual PID of the process being called
        tmp = Process.fork do
          system "ssh -nNT -g -R 0.0.0.0:#{ options['tunnel_port'] }:0.0.0.0:#{ options['port'] } #{options['tunnel_user']}@#{configuration['tunnel_host']}"
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
       File.join("fbgraph_callback_tunnel.pid")  
      end
    end
  
    class Server
      attr_reader :http, :options, :pid, :configuration, :tunnel
    
      def initialize options={}
        @options = options

        @http = WEBrick::HTTPServer.new(:Port => @options[:port] || 8000)
      
        @http.mount "/fbgraph_callback", Hook
      
        ["INT","TERM"].each do |signal| 
          trap(signal) { http.shutdown }
        end
      
        start
      end
    
      def callback_uri
        "http://localhost:#{ options[:port] || 8000 }/fbgraph_callback"
      end
      
      def start
        @pid = Process.fork { http.start }

        File.open(Server.pid_file,"w") do |f|
          f << pid
        end
      
        if use_tunnel?
          @tunnel = Tunnel.new
          sleep 3
        end
      end
    
      def shutdown
        Process.kill('TERM',pid)
        FileUtils.rm("#{ Server.pid_file }")
        tunnel.shutdown if use_tunnel?
      end
    
      def use_tunnel?
        options[:use_tunnel?]
      end

      def self.pid_file
       File.join("fbgraph_callback_server.pid")  
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
end