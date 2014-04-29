require 'webrick'
server = WEBrick::HTTPServer.new Port: 8080

server.mount_proc("/") do |request, response|
  
  response.content_type = "text/text"
  response.body = request.path
  trap('INT') { server.shutdown }
end


server.start