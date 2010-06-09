module FacebookGraph
  class Authorization
    attr_accessor :client

    
    # this will return the access token
    # that is needed for requests 
    def token
      
    end
    
    # redirect the user in their browser to this url
    # this will authorize us
    def fetch_code_url
      client.build_uri("oauth/authorize", {
        :client_id=> configuration['graph_api']['application_id'],
        :redirect_uri => callback_uri
      })
    end
    
    def fetch_authorization_url
      client.build_uri("oauth/access_token", {
      #  :client_id=> ['graph_api']['client_id'],
      #  :client_secret => configuration['graph_api']['secret'],
      #  :redirect_uri => callback_uri,
      #  :code => configuration['graph_api']['code'],
      })
    end
    
    def initialize options={}
      
    end
  end
end