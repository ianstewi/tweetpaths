# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def format_log_time(time)
	time += session[:session].utc_offset - time.utc_offset
	time.strftime('%d/%m/%Y %H:%M:%S')
  end
  
  def image_url(source)
    abs_path = image_path(source)
    unless abs_path =~ /^http/
      abs_path = "#{request.protocol}#{request.host_with_port}#{abs_path}"
    end
   abs_path
  end
  
end
