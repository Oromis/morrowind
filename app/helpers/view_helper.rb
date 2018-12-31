module ViewHelper
  def link_mode
    if request.path =~ /^\/characters\/\d+/
      '_blank'
    end
  end
end
