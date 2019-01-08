module CharacterHelper
  def character_property(icon, text, model, options = {})
    classes = 'char-property'
    classes += ' char-property-small' if options[:small]
    classes += ' char-property-embedded' if options[:embedded]
    ( "<div class=\"#{ classes }\">" +
        '<div class="property-icon">' +
          image_tag(icon, alt: options[:alt] || text) +
        '</div>' +
        "<div class=\"property-value\"  title=\"{{ #{model} | num:5 }}\"" +
          (options[:editable] ? "data-editable=\"true\" data-model=\"#{model}\" data-number=\"true\"" : '') +
          ">{{ #{model} | num }}</div>" +
        "<div class=\"property-key\" title=\"#{text}\">#{text}</div>" +
      '</div>').html_safe
  end

  def character_property_dynamic(icon, text, model, options = {})
    classes = 'char-property'
    classes += ' char-property-small' if options[:small]
    classes += ' char-property-embedded' if options[:embedded]
    unless model.is_a?(Array)
      model = [model]
    end
    html = "<div class=\"#{ classes }\">" +
        '<div class="property-icon">' +
        "<img ng-src=\"{{ #{icon} }}\" />" +
        '</div>'
    model.reverse_each do |m|
      html += "<div class=\"property-value\" title=\"{{ #{m} | num:5 }}\"" +
          (options[:editable] ? "data-editable=\"true\" data-model=\"#{m}\" data-number=\"true\"" : '') +
          ">{{ #{m} | num }}</div>"
    end

    html += "<div class=\"property-key\" title=\"{{ #{text} }}\">{{ #{text} }}</div>" +
        '</div>'
    html.html_safe
  end

  def character_property_minimal(icon, model, options = {})
    text = options[:alt] || options[:title]
    value = options[:raw_model] ? model : "{{ #{model} | num }}"
    condition = options[:condition] || model
    ( '<div class="char-property-minimal"' +
        (options[:unconditional] ? '' : " ng-if=\"#{ condition }\"") +
        (text ? " title=\"#{ text }\"" : '') +
        '>' +
        '<div class="property-icon">' +
          image_tag(icon, alt: text) +
        '</div>' +
        "<div class=\"property-value\" " +
          (options[:editable] ? "data-editable=\"true\" data-model=\"#{model}\" data-number=\"true\"" : '') +
          (options[:on_confirm] ? "on-confirm=\"#{options[:on_confirm]}\"" : '') +
          (options[:value_as_html] ? "ng-bind-html=\"#{value}\"" : '') +
        ">#{options[:value_as_html] ? '' : value} #{options[:unit]}</div>" +
      '</div>').html_safe
  end
end
