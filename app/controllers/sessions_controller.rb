class SessionsController < ApplicationController
  
  skip_before_filter :check_session
  rescue_from ActionController::InvalidAuthenticityToken, :with => :error
    
  def create
	session[:original_uri] = request.referer
    oauth_session = Session.new(authenticated_sessions_url)
    session[:session] = oauth_session
	redirect_to oauth_session.authorize_url
  end
  
  def authenticated
    if session[:session]
      oauth_session = session[:session]
	  oauth_session.get_access_token(params[:oauth_verifier])
	  uri = session[:original_uri] if session[:original_uri]
	  reset_session
	  session[:session] = oauth_session
		
	  if uri
	    uri = "#{uri}maps" if uri.match(/\/$/)
	  end
	  redirect_to(uri || maps_path)
	  
	else
	  redirect_to maps_path
	end
	
  end
  
  def signout
    reset_session
    
    if request.referrer
  		redirect_to request.referer
    else
      redirect_to '/'
    end
 end
  
  def error
    render :action => :error
  end

end