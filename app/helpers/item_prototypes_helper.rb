module ItemPrototypesHelper
  def prop_tag(icon, value, options = {})
    classes = options[:class] || 'prop'
    condition = options[:condition] || value
    ("<span class=\"#{classes}\" ng-if=\"!!#{condition}\">" +
        "{{ #{value} | num }}" +
        "<img src=\"#{image_url(icon)}\"
            alt=\"#{ options[:alt] || '' }\"
            title=\"#{ options[:title] || options[:alt] || '' }\"/>" +
        "</span>").html_safe
  end

  def prop_input(icon, value, options = {})
    ("<span class=\"prop-input\" #{ options[:show] ? "ng-show='#{options[:show]}'" : '' }>" +
        "<img src=\"#{image_url(icon)}\"
           alt=\"#{ options[:alt] || '' }\"
           title=\"#{ options[:title] || options[:alt] || '' }\"/> " +
        "<input class=\"form-control #{options[:class]}\" type=\"text\" " +
            "ng-model=\"#{value}\" ng-model-options=\"#{options[:options] || '{}'}\" " +
            "placeholder=\"#{ options[:title] || options[:alt] || '' }\" " +
            "number-input=\"true\" />" +
        '</span>').html_safe
  end

  def prop_tag_server(icon, value, options = {})
    classes = options[:class] || 'prop'
    if value
      ("<span class=\"#{classes}\">" +
          "#{value}" +
          "<img src=\"#{image_url(icon)}\"
              alt=\"#{ options[:alt] || '' }\"
              title=\"#{ options[:title] || options[:alt] || '' }\" />" +
          "</span>").html_safe
    else
      ""
    end
  end
end
