require File.expand_path('../../../spec_helper', __FILE__)

describe IndexTank::Client do
  before do
    @stubs = Faraday::Adapter::Test::Stubs.new
    stub_setup_connection
    @client = IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com")
  end

  context "indexes" do
    context "with a param" do
      it "should return a single index object" do
        @client.indexes('crawled-index').should be_an_instance_of(IndexTank::Index)
      end
    end

    context "without a param" do
      before do
        @stubs.get('/v1/indexes') { [200, {}, '{"crawled-index": {"started": true, "code": "dk4se", "creation_time": "2010-07-23T18:52:28", "size": 987}}'] }
      end

      it "should return a hash of indexes" do
        indexes = @client.indexes

        indexes.should be_an_instance_of(Hash)
        indexes['crawled-index'].should be_an_instance_of(IndexTank::Index)
      end
    end
  end
end
