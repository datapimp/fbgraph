module FacebookGraph
  class Client
    attr_accessor :authorization
    attr_reader :configuration, :server
    
    def initialize options={}
      @configuration = options
      @authorization = Authorization.new :client => self
      @server = Callback::Server.new options if options[:port]
    end

    # take a command line request
    # figure out what information is being requested, what options are being passed
    # and translate it to a GET or POST request request against the graph API
    def run action, options
      method, resource, parameters = build_request(action, options)
      response = self.send method, resource, parameters
      format_response(response, action, options)
    end
    
    def get resource, parameters={}
      JSON.parse do_get(resource, parameters)
    end

    def post resource, parameters={}
      JSON.parse do_post(resource, parameters)
    end
    
    protected 
    
    # format the JSON response for command line display
    # which will depend on the action called, the options passed etc
    def format_response decoded_json={}, action="", response={}
    
    end
    
    # figure out what the user is asking for
    # and point it to the appropriate graph resource
    def build_request action="", options={}
      
    end
    
    def do_get resource, parameters
      RestClient.get( build_uri(resource,parameters) )    
    end
    
    def do_post resource, parameters
      RestClient.post( build_uri(resource,parameters) )    
    end
    
    def callback_uri
      if Callback::Server.use_tunnel?
        return "http://#{ configuration['ssh_tunnel']['public_host'] }:#{ configuration['ssh_tunnel']['public_port'] }/callback/"
      else
        return "http://#{ configuration['host'] }:#{ configuration['port'] }/fbgraph_callback"
      end
    end
    
    def build_uri resource,parameters={}
      uri = "https://graph.facebook.com/" << "#{ resource }?"
      uri << parameters.inject([]) {|a,k| a << k.join("=") }.join("&") unless parameters.empty?

      "#{ uri }"
    end
  end
end