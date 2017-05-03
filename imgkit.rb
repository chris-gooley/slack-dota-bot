require 'open-uri'
require 'wkhtmltoimage-binary'
require 'imgkit'
require 'json'
require 'net/http'
require 'net/http/post/multipart'


html = File.open("sample.html","r")
kit = IMGKit.new(html.read, :quality => 50)
kit.stylesheets << 'assets/css/style.css'
img = kit.to_img(:jpg)

# save temp file
t = Time.now.to_i
file  = Tempfile.new(["dota_bot_#{t}", '.jpg'], 'tmp')
file.write(img)
file.flush


uri     = URI.parse "https://discordapp.com/api/webhooks/308762835687833620/EHTdiKRucmYkX_524k7G-bQ1YqFQ-NupfFfOoTerVcd-L0mhEKrTbpkXjr9JpvASEjfD"


file_upload = UploadIO.new(File.new(file.path), "image/jpeg", "image.jpg")

multipart_request = Net::HTTP::Post::Multipart.new uri.path, "file" => file_upload, "content" => "Dota Shenigans"

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

print "  [#{self.class}]  #{uri}\n"

response = http.request(multipart_request)

print response.read_body

=begin
request = Net::HTTP.new(uri.host, uri.port) do |http|
  http.use_ssl = true
  http.request(multipart_request)
end

print "  [#{self.class}]  #{uri}\n"

response = request.start
=end

