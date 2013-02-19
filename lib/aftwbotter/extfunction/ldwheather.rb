# coding: utf-8

require 'open-uri'
require 'rexml/document'

class LDWeather

  attr_reader :loc
  attr_reader :day
  attr_reader :weather
  attr_reader :temp_max
  attr_reader :temp_min
  attr_reader :link

  def initialize(day='today', loc='つくば')
    @day, @loc = day, loc
    load(@day, @loc)
  end

  def load(day='today', loc='つくば')
    @day, @loc = day, loc
    loc_code = { 'つくば市'=>55, '東京'=>63, '千葉'=>67, '銚子'=>68, '館山'=>69, '富山'=>44 }
    
    c = loc_code.select{|k,v| k =~ /#{@loc}/ }.first.last

    doc = REXML::Document.new(open("http://weather.livedoor.com/forecast/webservice/rest/v1?city=#{c.to_s}&day=#{day}").read)
    
    #doc.elements['lwws/location'].attributes
    #doc.elements['lwws/description'].text
    @weather = doc.elements['lwws/telop'].text
    @temp_max = doc.elements['lwws/temperature/max/celsius'].text
    @temp_min = doc.elements['lwws/temperature/min/celsius'].text
    
    doc.elements.each('lwws/pinpoint/location') do |e|
      if e.elements['title'].text =~ /つくば市/
        @link =  e.elements['link'].text
      end
    end
  end
end

if $0 == __FILE__
  ldw = LDWeather.new('today', ARGV[0])
  p ldw
end
