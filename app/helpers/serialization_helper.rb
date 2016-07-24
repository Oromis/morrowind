include ActionView::Helpers::NumberHelper

module SerializationHelper
  def decimal_number(num)
    res = number_to_human(num, units: {thousand: 'k'})
    if res
      res = res.to_str
    end
    res
  end
end
