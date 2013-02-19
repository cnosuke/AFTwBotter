# coding: utf-8
require './lib/aftwbotter/extfunction/ldwheather.rb'

if $0 == __FILE__
  class TwPost
    def initialize
    end
    def post(h)
      p h
    end
  end
end

class WheatherFunc

  def location?
    locs = ['つくば','東京','千葉']
    @location = locs.select{ |l| @status_text =~ /#{l}/ }.first
    if @location
      return @location
    else
      @location = 'つくば'
      return @location
    end
  end

  def hasday?
    days = {  'today'=>['今日','きょう','本日','ほんじつ'], 'tomorrow'=>['明日','あす','あした'], 'dayaftertomorrow'=>['明後日','みょうごにち','あさって']}  
    days.each do |day,rbs|
      if rbs.map{ |rb| !(@status_text =~ /#{rb}/) }.include?(false)
        @day = day
        return day 
      end  
    end  
    return nil
  end

  def check_status
    if @status_text =~ /@haskeytan/
      if @status_text =~ /(天気|てんき)/
        if location?
          if hasday?
            post_tweet(make_tweet(@day))
          else
            post_tweet(make_tweet('today'))
          end
        else
          post_tweet('場所がわからないお') #一生入らないはずの場所
        end
      end
    end
  end

  def make_tweet(day)
    days = { 'today'=>'今日', 'tomorrow'=>'明日', 'dayaftertomorrow'=>'明後日' }
    ldw = LDWeather.new(day,@location)
    str = "#{days[day]}の#{@location}の天気は#{ldw.weather}らしいよ！"
    if ldw.temp_max && ldw.temp_min
      str += "最高気温は#{ldw.temp_max.to_s}度で最低気温は#{ldw.temp_min.to_s}度だぉ！"
    end
    return str
  end

  def post_tweet(text)
      tp = TwPost.new
    tp.post({  'status'=>"@#{  @s['user'].fetch('screen_name')} #{text}",'in_reply_to_status_id'=>@s['id_str']})
  end

  def update(s)
    @s = s
    @status_text = s['text']
    return unless @status_text
    return if s['user'].fetch('screen_name') == 'haskeytan'
    check_status
  end
end

if $0 == __FILE__
  puts 'START TEST MODE'
  wf = WheatherFunc.new

  s = { 'text' => ARGV[0].to_s, 'user'=>{'screen_name'=>'cnosuke'}, 'id_str'=>Time.now.to_i.to_s }
  wf.update(s)
end
