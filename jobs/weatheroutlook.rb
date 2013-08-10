require "net/http"
require "json"

# WOEID for location:
# http://woeid.rosselliot.co.nz
woeid  = 28347135   # shah alam 
# woeid  = 733075   # rotterdam
# woeid  = 28289421   # antarctica

# Units for temperature:
# f: Fahrenheit
# c: Celsius
format = "f"

query  = URI::encode "select * from weather.forecast WHERE woeid=#{woeid} and u='#{format}'&format=json"

SCHEDULER.every "15m", :first_in => 0 do |job|
  http     = Net::HTTP.new "query.yahooapis.com"
  request  = http.request Net::HTTP::Get.new("/v1/public/yql?q=#{query}")
  response = JSON.parse request.body
  results  = response["query"]["results"]["channel"]["item"]["forecast"]

  if results
	forecasts = []
	for day in (0..4) 
		day = results[day]

		this_day = {
			high: day["high"],
			low:  day["low"],
			date: day["date"],
			code: day["code"],
			text: day["text"], 
			format: format
		}
		forecasts.push(this_day)
	end
  
	send_event "weatheroutlook", { forecasts: forecasts }
  end
end
