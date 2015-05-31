# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
#  include ExceptionNotifiable
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :check_session, :check_browser
  layout :determine_layout
  
  protected
  
  def check_session
    if session[:session]
	  unless session[:session].screen_name
	    reset_session
	  end
	end

	if session[:session] and session[:session].location
	  @location = session[:session].location
	else
	  @location = ''
	end
	
	if session[:session] and session[:session].screen_name
	  @signed_in = true
	  @screen_name = session[:session].screen_name
	else
	  @signed_in = false
	  @screen_name = ''
	end
  end
  
  def check_browser
    if request.user_agent and (request.user_agent.match(/Mobile\//) or request.user_agent.match(/Android/))
	  @mobile = true
	end
  end
  
  def determine_layout
    if @mobile
	  'mobile_application'
	else
	  'application'
	end
  end
    
  def client_ip
  	if request.env['HTTP_X_FORWARDED_FOR']
  		request.env['HTTP_X_FORWARDED_FOR']
  	elsif request.remote_addr
  		request.remote_addr
  	else
  		''
  	end
  end
  
end
