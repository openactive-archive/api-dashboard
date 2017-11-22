require 'spec_helper'
require_relative '../../dashboard_helpers'

describe DashboardHelpers do

  let(:dummy_class) do
    class DummyClass
      include DashboardHelpers
    end
    DummyClass.new
  end

  it "builds an image tag with appropriate cc image as source" do
    expect(dummy_class.licence_image("https://creativecommons.org/licenses/by/4.0/")).to eql('<img class="licence-image" src="/images/by.png">')
    expect(dummy_class.licence_image("https://creativecommons.org/licenses/by-nc/4.0/")).to eql('<img class="licence-image" src="/images/by-nc.png">')
    expect(dummy_class.licence_image("https://creativecommons.org/licenses/by-nd/4.0/")).to eql('<img class="licence-image" src="/images/by-nd.png">')
  end

  it "builds an image tag with default image as source if not a cc licence" do
    expect(dummy_class.licence_image("https://myothersite.org/licenses/mylicence/")).to eql('<img class="licence-image" src="/images/licence.png">')
  end

end