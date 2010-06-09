module FacebookGraph
  class Authorization
    attr_accessor :client, :authorization_code, :access_token
    
    def initialize options={}
      @client = options[:client]
    end
    
    # redirect the user in their browser to this url
    # this will authorize us
    def authorization_code_uri
      client.build_uri("oauth/authorize", {
      #  :client_id=> configuration['graph_api']['application_id'],
      #  :redirect_uri => client.callback_uri
      })
    end
    
    def access_token_uri
      client.build_uri("oauth/access_token", {
      #  :client_id=> ['graph_api']['client_id'],
      #  :client_secret => configuration['graph_api']['secret'],
      #  :redirect_uri => callback_uri,
      #  :code => configuration['graph_api']['code'],
      })
    end
  end
end