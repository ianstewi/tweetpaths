class Tweet
    
  def self.user_timeline(client, user)
	client.user_timeline(user, :count => 75)
  end
  
end