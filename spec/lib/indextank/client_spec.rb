require File.expand_path('../../../spec_helper', __FILE__)

describe IndexTank::Client do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:client) { IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com") }

  before { stub_setup_connection }

  describe "indexes" do
    context "with a param" do
      subject { client.indexes('crawled-index') }

      it "should return a single index object" do
        should be_an_instance_of(IndexTank::Index)
      end
    end

    context "without a param" do
      subject { client.indexes }

      before do
        stubs.get('/v1/indexes') { [200, {}, '{"crawled-index": {"started": true, "code": "dk4se", "creation_time": "2010-07-23T18:52:28", "size": 987}}'] }
      end

      it "should return a hash of indexes" do
        indexes = subject

        indexes.should be_an_instance_of(Hash)
        indexes['crawled-index'].should be_an_instance_of(IndexTank::Index)
      end
    end
  end
end
