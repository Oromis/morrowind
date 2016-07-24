module RacesHelper
  def value_to_sign_class(val)
    case
      when val > 0
        'positive'
      when val < 0
        'negative'
      else
        ''
    end
  end

  def signed_number(num)
    num != 0 ? ('%+d' % num) : ('%d' % num)
  end
end
