module ApplicationHelper
  # Hey yolo!
  def full_title(page_title = '')
    base_title = "Morrowind PnP"
    if page_title.empty? 
      base_title
    else
      page_title + ' | ' + base_title
    end
  end

  def link_if_permitted(url, role, options = {}, &block)
    if current_user.has_role?(role)
      link_to url, options do
        block.call
      end
    else
      content_tag :div, options do
        block.call
      end
    end
  end
end
