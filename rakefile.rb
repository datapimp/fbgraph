task :default => :test

task :test do
  require File.dirname(__FILE__) + '/test/all_tests.rb'
end

desc "Generate the FBGraph Configuration File for callback server / tunnel"
task :generate_configuration do
  raise "File already exists" if File.exists?("./config/fbgraph_client.yml")
  
  FileUtils.mkdir("./config") unless File.exists?("./config")
  File.open("./config/fbgraph_client.yml", "w") do |f|
    f.puts "port: 8000\ntunnel:\n  host: soederpop.com\n  user: jonathan\n  port: 8000"
  end
end