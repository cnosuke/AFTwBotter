# -*- coding: utf-8 -*-
require 'net/https'
require 'oauth'
require 'cgi'
require 'json'
require 'yaml'
require 'logger'
require './lib/aftwbotter/notifier/kayac_post.rb'
require './lib/aftwbotter/twfunctions.rb'

module AFTwBotter
  class Config
    @yaml = YAML.load(open('config.yml').read)

    def self.api
      @yaml['api']
    end

    def self.oauth
      y = @yaml['oauth']
      consumer = OAuth::Consumer.new(
        y['consumer_token'],
        y['consumer_secret'],
        :site => 'http://twitter.com'
      )
      access_token = OAuth::AccessToken.new(
        consumer,
        y['access_token'],
        y['access_token_secret']
      )
      return {:consumer => consumer, :access_token => access_token }
    end
  end

  class Crawler
    def self.run
      twf = TwFunctions.new

      consumer = Config.oauth[:consumer]
      access_token = Config.oauth[:access_token]
      uri = URI.parse(Config.api['userstream']['uri'])

      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.ca_file = Config.api['userstream']['ca']
      https.verify_mode = OpenSSL::SSL::VERIFY_PEER
      https.verify_depth = 5

      while true
        begin
          https.start do |https|
            request = Net::HTTP::Get.new(uri.request_uri)
            request.oauth!(https, consumer, access_token) # OAuthで認証
            buf = ""
            begin
              https.request(request) do |response|
                $LOG.info 'Start https request'
                response.read_body do |chunk|
                  buf << chunk
                  while (line = buf[/.+?(\r\n)+/m]) != nil # 改行コードで区切って一行ずつ読み込み
                    begin
                      buf.sub!(line,"") # 読み込み済みの行を削除
                      line.strip!
                      status = JSON.parse(line)
                      twf.ping(status)
                    rescue
                      break # parseに失敗したら、次のループでchunkをもう1個読み込む
                    end
                  end
                end
              end
            rescue => e
              $LOG.error e.to_s
              retry
            rescue Timeout::Error => e
              $LOG.error e.to_s
              retry
            end
          end
        rescue => e
          $LOG.error e.to_s
          Kayac.post({  :message => "[Notice] 謎のエラー…。10秒後に最初からやりなおします。" })
          sleep 10
          retry
        end
        Kayac.post({  :message => "[Notice] while loopの終端に達したよ！最初からやるね！" })
        sleep 1 #超高速無限ループを回避
      end
      twf.close
    end
  end
end
