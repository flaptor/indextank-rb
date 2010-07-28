require File.expand_path('../../../spec_helper', __FILE__)

describe IndexTank::Client do
  before do
    @client = IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com")
  end

  context "indexes" do
    context "with a param" do
      it "should return a single index object" do
        @client.indexes('crawled-index').should be_an_instance_of(IndexTank::Index)
      end
    end

    context "without a param" do
      it "should return a hash of indexes" do
        indexes = @client.indexes

        indexes.should be_an_instance_of(Hash)
        indexes['crawled-index'].should be_an_instance_of(IndexTank::Index)
      end
    end
  end
end
