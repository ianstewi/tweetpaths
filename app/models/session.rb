class Session

  attr_reader :authorize_url
  attr_reader :screen_name
  attr_reader :name
  attr_reader :profile_image_url
  attr_reader :id
  attr_reader :utc_offset
  attr_reader :location
  
  CONSUMER_TOKEN = 'Put your Twitter consumer token here'
  CONSUMER_SECRET = 'Put your Twitter consumer secret here'
  
  def initialize(callback_url)
    consumer = OAuth::Consumer.new(CONSUMER_TOKEN, CONSUMER_SECRET,
	    :site => 'https://api.twitter.com', :authorize_path => '/oauth/authenticate' )
	request_token = consumer.get_request_token( { :oauth_callback => callback_url } )
	@rt_token = request_token.token
	@rt_secret = request_token.secret
	@authorize_url = request_token.authorize_url
  end
  
  def get_access_token(oauth_verifier)
    # Return nil if we have no request token, e.g. if it's already been used
    return nil unless @rt_token
    
    consumer = OAuth::Consumer.new(CONSUMER_TOKEN, CONSUMER_SECRET,
	    :site => 'https://api.twitter.com', :authorize_path => '/oauth/authenticate' )
    request_token = OAuth::RequestToken.new(consumer, @rt_token, @rt_secret)
    begin
      @access_token = request_token.get_access_token( { :oauth_verifier => oauth_verifier } )
    rescue
      return nil
    end
    
    # The request token has been used, nil @rt_token and @rt_secret so we won't try to use it again
    @rt_token = nil
    @rt_secret = nil
        
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = CONSUMER_TOKEN
      config.consumer_secret     = CONSUMER_SECRET
      config.access_token        = @access_token.token
      config.access_token_secret = @access_token.secret
    end
	
	  begin
	    credentials = client.verify_credentials
	  rescue
	    return nil
	  end
	  
	  @screen_name = credentials.screen_name
	  @id = credentials.id
	  @name = credentials.name
	  @profile_image_url = credentials.profile_image_uri
	  @utc_offset = credentials.utc_offset.to_i
	  @location = credentials.location
  end
  
  def client
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = CONSUMER_TOKEN
      config.consumer_secret     = CONSUMER_SECRET
      config.access_token        = @access_token.token
      config.access_token_secret = @access_token.secret
    end
    return client
  end
end
