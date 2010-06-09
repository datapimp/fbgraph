module FacebookGraph
  class Client
    attr_accessor :authorization
    attr_reader :configuration
    
    def initialize options={}
      @configuration = options
      @authorization = Authorization.new :client => self
    end
    
    def get resource, parameters={}
      JSON.parse do_get(resource, parameters)
    end

    def post resource, parameters={}
      JSON.parse do_post(resource, parameters)
    end
    
    protected 

    def do_get resource, parameters
      RestClient.get( build_uri(resource,parameters) )    
    end
    
    def do_post resource, parameters
      RestClient.post( build_uri(resource,parameters) )    
    end
    
    def callback_uri
      Callback::Server.use_tunnel? ? "http://#{ configuration['ssh_tunnel']['public_host'] }:#{ configuration['ssh_tunnel']['public_port'] }/callback/" : (Server.configuration['call_back_url'] || "/callback")
    end
    
    def build_uri resource,parameters={}
      uri = "https://graph.facebook.com/" << "#{ resource }?"
      uri << parameters.inject([]) {|a,k| a << k.join("=") }.join("&") unless parameters.empty?

      uri
    end
  end
end