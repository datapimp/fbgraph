require 'rubygems'
require 'rest_client'
require 'webrick'
require 'json' unless defined? JSON

require "#{ File.dirname(__FILE__) }/fbgraph/client"
require "#{ File.dirname(__FILE__) }/fbgraph/callback"
require "#{ File.dirname(__FILE__) }/fbgraph/authorization"

module FacebookGraph
  
end