require File.expand_path('../../../spec_helper', __FILE__)

describe IndexTank::Index do
  before do
    @stubs = Faraday::Adapter::Test::Stubs.new
    stub_setup_connection
    @index = IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com").indexes('new-index')
    @path_prefix = '/v1/indexes/new-index/'
  end

  context "index management" do
    context "add an index" do
      # after do
      #   @index.delete
      # end

      context "the index does not exist" do
        before do
          @stubs.put(@path_prefix) { [201, {}, '{"started": false, "code": "dsyaj", "creation_time": "2010-08-14T13:01:48.454624", "size": 0}'] }
        end

        it "should add the index" do
          @index.add.should be_true
        end
      end

      context "when an index already exists" do
        before do
          # @index.add
          @stubs.put(@path_prefix) { [204, {}, ''] }
        end

        it "should raise an exception" do
          lambda { @index.add }.should raise_error(IndexTank::IndexAlreadyExists)
        end
      end

      context "when the user has too many indexes" do
        before do
          @stubs.put(@path_prefix) { [409, {}, ''] }
        end

        it "should raise an exception" do
          lambda { @index.add }.should raise_error(IndexTank::TooManyIndexes)
        end
      end
    end

    context "delete an index" do
      context "the index exists" do
        before do
          # @index.add
          @stubs.delete(@path_prefix) { [200, {}, ''] }
        end

        it "should be a success" do
          @index.delete.status.should == 200
        end
      end

      context "the index does not exist" do
        before do
          @stubs.delete(@path_prefix) { [204, {}, ''] }
        end

        it "should have no content" do
          @index.delete.status.should == 204
        end
      end
    end
  end

  context "when examining the metadata" do
  end
end
