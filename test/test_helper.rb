require 'test/unit'
require 'rubygems'
require 'shoulda'
require File.dirname(__FILE__) + '/../lib/fbgraph'

#meh this doesn't work with localhost
VALID_URI_REGEX = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
