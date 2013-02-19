# coding: utf-8
require 'net/https'
require 'json'

module AFTwBotter
class TwPost
  def initialize
    @consumer = Config.oauth[:consumer]
    @access_token = Config.oauth[:access_token]
    @uri = URI.parse(Config.api['api_twitter']['uri'])
    @https = Net::HTTP.new(@uri.host, @uri.port)
    @https.use_ssl = true
    @https.ca_file = URI.parse(Config.api['api_twitter']['ca'])
    @https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    @https.verify_depth = 5
  end
  
  def makespase
    str = ''
    moji = [' ','　']
    10.times do str << moji[rand(2)] end
    return str
  end

  def post(postdata)
    @https.start do |https|
      request = Net::HTTP::Post.new(@uri.request_uri)
      postdata['status'] += makespase
      request.set_form_data(postdata)

      request.oauth!(https, @consumer, @access_token) # OAuthで認証
      
      buf = ""
      
      @https.request(request) do |res|
        res.read_body do |body|
          status = JSON.parse(body)
        end
      end
    end
  end
end
end