require 'datasets_cache'

describe DatasetsCache do

  describe ".update" do
    it "it stores result of request" do
      expect(DatasetsCache.update).to eql("OK")
    end
  end

  describe ".all" do
    it "retrieves a collection of datasets" do
      expect(DatasetsCache.all.class).to eql(Array)
    end
  end

end