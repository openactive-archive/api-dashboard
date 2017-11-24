module DashboardHelpers
  
  def licence_image(url)
    if url.include?('https://creativecommons.org/licenses/')
      image_name = url.gsub('https://creativecommons.org/licenses/', '').split('/').first
    else
      image_name = 'licence'
    end
    return '<img class="licence-image" src="/images/'+ image_name +'.png">'
  end

  def availability_indicator(availability,url)
    if availability[url].nil?
      '<span class="yellow-light"></span>Unknown'
    elsif availability[url]
      '<span class="green-light"></span>Up'
    else
      '<span class="red-light"></span>Down'
    end
  end

end