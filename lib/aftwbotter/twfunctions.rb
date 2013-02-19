# coding: utf-8
require 'observer'
require 'json'
require './lib/aftwbotter/record/record_to_kc.rb'
require './lib/aftwbotter/extfunction/wheatherfunc.rb'
require './lib/aftwbotter/extfunction/eewfunc.rb'
require './lib/aftwbotter/twitter_post.rb'

module AFTwBotter

  class TWFShowText
    def update(s)
      if s['text']
        puts "#{ s['user']['screen_name']}: #{CGI.unescapeHTML(s['text'])}"
      end
    end
  end

  class TWFRecordTweet
    def update(s)
      open('log/stream.log','a'){ |io| io.puts s.to_json }
    end
  end

  class KmdrFunc
    def update(s)
      status_text = s['text']
      return unless status_text
      tp = TwPost.new
      tp.post({ 'status'=>"@#{ s['user'].fetch('screen_name')} hoge",'in_reply_to_status_id'=>s['id_str']})                
    end
  end

  class TwFunctions
    def initialize
      fs = 
        [ TWFShowText,
          TWFRecordTweet,
          KmdrFunc,
          WheatherFunc,
          EEWFunc
        ]
      
      #@rtkc = RecordToKC.new
      
      @twoa = TwFunctionObservable.new
      
      fs.each do |f|
        @twoa.add_observer f.new
      end
      
      #@twoa.add_observer @rtkc  
    end
    
    def close
      #@twoa.delete_observer @rtkc
      #@rtkc.close_all_db
    end

    def ping(arg)
      @twoa.ping(arg)
    end

  end

  class TwFunctionObservable
    include Observable
    def ping(arg)
      changed
      notify_observers(arg)
    end
  end

end
