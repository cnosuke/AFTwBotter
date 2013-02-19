require './lib/aftwbotter/crawler.rb'

$LOG = Logger.new('./log/crawler_'+Time.now.to_i.to_s+'.log')
$LOG.datetime_format = '%Y-%m-%d %H:%M:%S '
# $LOG.level = Logger::ERROR

#if ARGV[0] == '--daemon'
#  Process.daemon(true, nil) #chdirはしないけど、STDIOは全部閉じる
#end

module AFTwBotter
end
