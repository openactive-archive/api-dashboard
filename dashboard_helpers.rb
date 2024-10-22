module DashboardHelpers
  
  def licence_image(url)
    if url.include?('https://creativecommons.org/licenses/')
      image_name = url.gsub('https://creativecommons.org/licenses/', '').split('/').first
    else
      image_name = 'licence'
    end
    return '<img class="licence-image" alt="'+ image_name +'" src="/images/'+ image_name +'.png">'
  end

  def availability_indicator(availability,url)
    if availability[url].nil?
      '<span title="Unknown" class="gray-light"></span> Unknown'
    elsif availability[url]
      '<span class="green-light"></span>Up'
    else
      '<span class="red-light"></span>Down'
    end
  end

  def yesno_indicator(indicator)
    if indicator.nil?
      '<span title="Unknown" class="gray-light"></span>'
    elsif indicator
      '<span class="green-light"></span>Yes'
    else
      '<span class="red-light"></span>No'
    end
  end

end