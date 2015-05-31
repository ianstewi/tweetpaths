class MapsController < ApplicationController
  
  def add
  
    if !session[:session]
      render :reload_page
      return
    end
    
    begin
      timezone_adjustment = Time.new.utc_offset - session[:session].utc_offset
    rescue
      timezone_adjustment = Time.new.utc_offset
    end
	
    if params[:from_date_text] and params[:from_date_text] != ''
      begin
        from_date = (Time.parse(params[:from_date_text]) + timezone_adjustment).getlocal(session[:session].utc_offset)
      rescue
        from_date_error = true
      else
        @display_from_date = from_date.strftime('%a %b %d')
      end
    else
      from_date = Time.at(0)
    end
	  
    if params[:to_date_text] and params[:to_date_text] != ''
      begin
        to_date = (Time.parse(params[:to_date_text]) + 86399 + timezone_adjustment).getlocal(session[:session].utc_offset)
      rescue
        to_date_error = true
      else
        @display_to_date = to_date.strftime('%a %b %d')
      end
    else
      to_date = Time.new + 86400
    end
	
    if from_date_error or to_date_error
      if from_date_error and to_date_error
        error_message = 'Invalid Start and End Dates'
      elsif from_date_error
        error_message = 'Invalid Start Date'
      else
        error_message = 'Invalid End Date'
      end
      display_error(error_message, from_date_error, to_date_error)

    else
      begin
        fetched_tweets = Tweet.user_timeline(session[:session].client, params[:user])
	  
      rescue Exception => e

        if e.message.match(/Not authorized$/)
          error_message = "#{params[:user]} has protected their tweets"
          display_error(error_message, false, false, false, true)
        elsif e.message.match(/Not found$/) or e.message.match(/that page does not exist$/)
          error_message = "There is no Twitter user called #{params[:user]}"
          display_error(error_message, false, false, true, false)
        else
          error_message = "Error fetching tweets from Twitter: #{e.message}"
          display_error(error_message, false, false, false, false)
        end

      else
	  
        @tweets = Array.new

        last_tweet = false
        fetched_tweets.reverse.each do |raw_tweet|
          begin
            tweet_time = raw_tweet.created_at.getlocal(session[:session].utc_offset)
          rescue
            tweet_time = raw_tweet.created_at
          end
          if tweet_time >= from_date and tweet_time <= to_date and raw_tweet.geo?
            tweet = process_tweet(raw_tweet, last_tweet)
            last_tweet = raw_tweet
            @tweets << tweet
            session[:north] ||= tweet[:lat]
            session[:south] ||= tweet[:lat]
            session[:east] ||= tweet[:lng]
            session[:west] ||= tweet[:lng]
            session[:north] = tweet[:lat] if tweet[:lat] > session[:north]
            session[:south] = tweet[:lat] if tweet[:lat] < session[:south]
            session[:east] = tweet[:lng] if tweet[:lng] > session[:east]
            session[:west] = tweet[:lng] if tweet[:lng] < session[:west]
          end
        end

        if @tweets.empty?
          if @display_from_date or @display_to_date
            error_message = "#{params[:user]} has no tweets with locations for those days"
          else
            error_message = "#{params[:user]} has no tweets with locations"
          end
          if params[:user].casecmp(session[:session].screen_name) == 0
            display_error(error_message, false, false, false, true, true)
          else
            display_error(error_message, false, false, false, true)
          end
        else
          session[:user_number] ||= -1
          session[:user_number] += 1
          @marker_colour = ['red', 'blue', 'green', 'ltblue', 'yellow', 'purple', 'pink']
          @marker_rgb = ['#FD7567', '#6991FD', '#00E64F', '#67DDDD', '#FDF569', '#8E67FD', '#E661AC']		  
        end
      end
    end	
  end
  
  def index
    session[:north] = nil
    session[:south] = nil
    session[:east] = nil
    session[:west] = nil
    session[:user_number] = -1
	
    unless @signed_in
      if request.user_agent
        user_agent = request.user_agent
      else
        user_agent = 'No user agent'
      end
	  
      if request.referer
        referer = request.referer
      else
        referer = ''
      end
    end
	  
  end
  
  def reset
    redirect_to :action => :index
  end
  
  private
  
  def process_tweet(raw_tweet, last_tweet)
    tweet = Hash.new
    puts "Processing tweet #{raw_tweet.full_text}"
	
    display_urls = Hash.new
    expanded_urls = Hash.new
    raw_tweet.uris.each do |uri_entry|
      url = uri_entry.url.to_s
      puts "URL #{url}"
      display_urls[url] = uri_entry.display_url.to_s if uri_entry.display_url
      expanded_urls[url] = uri_entry.expanded_url.to_s if uri_entry.expanded_url
      puts "display_url #{display_urls[url]}"
      puts "expanded_url #{expanded_urls[url]}"
    end
    
    tweet[:display_urls] = display_urls
    tweet[:expanded_urls] = expanded_urls
	
    tweet[:lat] = raw_tweet.geo.coordinates[0]
    tweet[:lng] = raw_tweet.geo.coordinates[1]
	
    tweet[:text] = raw_tweet.text.html_safe
	
    tweetphotos = Array.new
    plixis = Array.new
    lockerz = Array.new
    yfrogs = Array.new
    twitpics = Array.new
    instagrams = Array.new
    
    expanded_urls.each_key do |url|
      if expanded_urls[url].match(/http:\/\/tweetphoto.com\/(\d+)/)
        tweetphotos << $1
      end
	
      if expanded_urls[url].match(/http:\/\/plixi.com\/p\/(\d+)/)
        plixis << $1
      end
	
      if expanded_urls[url].match(/http:\/\/lockerz.com\/s\/(\d+)/)
        lockerz << $1
      end
	
      if expanded_urls[url].match(/http:\/\/yfrog.com\/(\w+)/)
        yfrogs << $1
      end
	
      if expanded_urls[url].match(/http:\/\/twitpic.com\/([\w]+)/)
        twitpics << $1
      end
	  
      if expanded_urls[url].match(/http:\/\/instagram.com\/p\/([-\w]+)/)
        instagrams << $1
      end
    end
  
    tweet[:tweetphotos] = tweetphotos
    tweet[:plixis] = plixis
    tweet[:lockerz] = lockerz
    tweet[:yfrogs] = yfrogs
    tweet[:twitpics] = twitpics
    tweet[:instagrams] = instagrams
    tweet[:media] = raw_tweet.media
	
    if tweet[:tweetphotos].empty? and tweet[:plixis].empty? and tweet[:lockerz].empty? and tweet[:yfrogs].empty? and tweet[:twitpics].empty? and tweet[:instagrams].empty? and tweet[:media].empty?
      tweet[:images] = false
    else
      tweet[:images] = true
    end
	
    mentioned_users = Array.new
    tweet[:text].scan(/@([\w_]+)/) {|user| mentioned_users << user}
    tweet[:mentioned_users] = mentioned_users

    begin
      tweet[:time] = raw_tweet.created_at.getlocal(session[:session].utc_offset)
    rescue
      tweet[:time] = raw_tweet.created_at
    end
	
    tweet[:profile_image_url] = raw_tweet.user.profile_image_url
    tweet[:screen_name] = raw_tweet.user.screen_name
    tweet[:name] = raw_tweet.user.name
    tweet[:id] = raw_tweet.id
	
    if last_tweet
      time_diff = raw_tweet.created_at - last_tweet.created_at
      tweet[:time_diff] = time_diff if time_diff < 86400
      tweet[:distance] = distance(last_tweet.geo.latitude, last_tweet.geo.longitude, raw_tweet.geo.latitude, raw_tweet.geo.longitude)
      if tweet[:time_diff] and tweet[:time_diff] > 0 and tweet[:distance] >= 0.001
        speed = (tweet[:distance] * 3600 / tweet[:time_diff]).to_i
        tweet[:speed] = speed if speed > 0
        tweet[:time_diff] = nil if speed > 1000	# This will cause it to not be displayed in view
      end
    end
		
    return tweet
  end
  
  def distance(lat1, lng1, lat2, lng2)
    r = 6371
    dLat = (lat1 - lat2) * Math::PI / 180
    dLng = (lng1 - lng2) * Math::PI / 180
    a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math::PI / 180) * Math.cos(lat2 * Math::PI / 180) * 
    Math.sin(dLng/2) * Math.sin(dLng/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    r * c
  end
  
  def display_error(error_message, invalid_from_date = false, invalid_to_date = false, invalid_user = false, reset_form = false, this_user = false)
    @error_message = error_message
    @invalid_from_date = invalid_from_date
    @invalid_to_date = invalid_to_date
    @invalid_user = invalid_user
    @reset_form = reset_form
    @this_user = this_user
    render :add_error
  end
  
end