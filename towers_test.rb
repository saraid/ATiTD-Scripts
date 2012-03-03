require 'open-uri'
require 'nokogiri'
require 'chronic' # Because Time.parse doesn't exist without this somehow.

events = Nokogiri::HTML(open('http://www.atitd.com/events.html'))
events = events.css('font').collect do |news_item|
  next unless news_item.text.match /Hour of Towers/
  date = news_item.css('em').first.text
  type = news_item.css('span').text.match(/Hour of the ([\w ]+)\./)[1]

  unless defined? $offset
    $offset = date.match(/GMT([+-]\d+)/)[1][0..2].to_i * 60 * 60
    $offset -= Time.now.utc_offset
  end

  { :date => Time.parse(date) - $offset, :type => type }
end
events.compact!

data = Nokogiri::HTML(open('http://www.atitd.org/wiki/tale6/Test_of_Towers'))
['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

events.each { |tower|
  puts "#{tower[:type]} (at #{tower[:date].strftime "%a %b %d, %I:%M%p %Z"})"
  puts data.css('h3 + ul').detect { |ul| !ul.previous.previous.css("##{tower[:type].gsub ' ', '_'}").empty? }.children.collect { |li| li.text }
}
