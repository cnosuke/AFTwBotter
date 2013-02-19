class Kayac
  def self.post(post_data = self.postdata)
    require 'rubygems'
    require 'net/https'
    require 'json' if RUBY_VERSION < '1.9.0' # 1.9以降ではRuby本体に組み込まれている為
    result = JSON.parse("{ }")
    uri = URI.parse('http://im.kayac.com/api/post/cnosuke')
    http = Net::HTTP.new(uri.host, uri.port)
    
    http.start do |http|
      request = Net::HTTP::Post.new(uri.request_uri)

      request.set_form_data(post_data)

      http.request(request) do |res|
        res.read_body do |body|
          result = JSON.parse(body)
        end
      end
    end
    return result
  end

  def self.postdata
    { 
      :message => "Hellow Kayac World!",
      :handler => "http://google.com/",
      #:password : "hoge",
      #:sig : "sigsig"
    }
  end

end
