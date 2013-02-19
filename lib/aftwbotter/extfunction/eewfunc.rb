# coding: utf-8
require 'kyotocabinet'

#EEWBOT = 'cnosuke_bot'
EEWBOT = 'eewbot'

if $0 == __FILE__
  class TwPost
    def initialize
    end
    def post(h)
      p h
    end
  end
end

class EEWFunc

  def initialize
    @eew_db = init_db('eew')    
  end

  def init_db(dbname)
    db = KyotoCabinet::DB::new
    unless db.open(dbname+'.kct', KyotoCabinet::DB::OWRITER | KyotoCabinet::DB::OCREATE)
      STDERR.printf("open error: %s\n", db.error)
    end
    return db
  end

  def close_db
    db = @eew_db
    unless db.close
      STDERR.printf("close error: %s\n", db.error)
    end
  end

  def check_status
    if @s['user'].fetch('screen_name') == EEWBOT
      @d = @t.split(/,/)
      return unless @d.size == 15
      unless @eew_db.get(@d[5])
        @eew_db.store(@d[5], @t)
        make_post_first
      else
        if @d[3] == '9'
          make_post_last
        end
      end
    end
  end

  def make_post_first
    str = "#{@d[9]}で最大震度#{@d[12]}の地震？ (速報推定値)"
    post_tweet(str)
  end

  def make_post_last
    loc = "http://maps.google.co.jp/maps?q=#{@d[7]}%C2%B0,#{@d[8]}%C2%B0"
    str = "【地震情報】#{@d[9]}で最大震度#{@d[12]}(M#{@d[11]})の地震が発生したみたいだお！震源はこのへん→ #{loc} (情報は全て速報推定値)"
    post_tweet(str)
  end

  def post_tweet(text)
    tp = TwPost.new
    tp.post({ 'status'=>text })
  end

  def update(s)
    @s = s
    @t = s['text']
    return unless @t
    return if @s['user'].fetch('screen_name') == 'haskeytan'
    check_status
  end

end

if $0 == __FILE__
  puts 'START TEST MODE'
  wf = EEWFunc.new

  s = {  'text' => ARGV[0].to_s, 'user'=>{ 'screen_name'=>EEWBOT }, 'id_str'=>Time.now.to_i.to_s }
  wf.update(s)
end
