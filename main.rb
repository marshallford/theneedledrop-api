#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
# require your gems as usual
require 'httparty'
require 'json'
require 'yt'
require 'deep_merger'

# setup youtube api
file = File.read('config.json')
fileHash = JSON.parse(file)
youtubeApiKey = fileHash['youtubeApiKey']
Yt.configure do |config|
  config.api_key = youtubeApiKey
end

# vars
artistTitle= []
albumTitle = []
videoURL = []
albumReviewVideos = []

# array of videos
channel = Yt::Channel.new url: 'youtube.com/theneedledrop'
videos = channel.videos.first(100)

# remove videos that are not album review from array
counter = 0
videos.each do |video|
	tempTitle = video.title.gsub(/\s+/, "").downcase
	if tempTitle.include? "albumreview"
		albumReviewVideos[counter] = video
		counter = counter + 1
	end
end

# loop through array of album review videos and parse
albumReviewVideos.each_with_index do |video, index|
	tempTitle = video.title.strip
	artistTitle[index] = video.title.split("-")[0].strip
	albumTitle[index] = video.title.to_s.split("-")[1].strip.split("ALBUM REVIEW")[0].strip
	videoURL[index] = "https://www.youtube.com/watch?v=" + video.id
end

# test output
artistTitle.each_with_index do |video, index|
	# puts artistTitle[index] + " - " + albumTitle[index] + " - " + videoURL[index]
end

# start the creation of the hash
hash = { :resultCount => albumTitle.length.to_s , :lastUpdated => Time.new.utc.to_s }

# create hash
albumTitle.each_with_index do |item, index|
	source = {:results => [ {:artistTitle => artistTitle[index], :albumTitle => albumTitle[index], :youtubeURL => videoURL[index]} ]}
	DeepMerger.deep_merge!(hash, source)
end

# save hash as json to file
File.open("album-reviews.json","w") do |f|
  f.write(JSON.pretty_generate(JSON.parse(hash.to_json)))
end
