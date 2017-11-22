module DashboardHelpers
  def licence_image(url)
    if url.include?('https://creativecommons.org/licenses/')
      image_name = url.gsub('https://creativecommons.org/licenses/', '').split('/').first
    else
      image_name = 'licence'
    end
    return '<img class="licence-image" src="/images/'+ image_name +'.png">'
  end
end