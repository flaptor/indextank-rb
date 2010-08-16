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
    shared_examples_for "metadata" do
      it "should return the code" do
        @index.code.should == 'dsyaj'
      end

      it "should update and return the running" do
        # delete any preceding stubs if they exist.
        @stubs.match(:get, @path_prefix, nil)
        @stubs.get(@path_prefix) { [200, {}, '{"started": true, "code": "dsyaj", "creation_time": "2010-08-14T13:01:48.454624", "size": 0}'] }
        @index.running?.should be_true
      end

      it "should return the size" do
        @index.size.should == 0
      end

      it "should return the creation_time" do
        @index.creation_time.should == "2010-08-14T13:01:48.454624"
      end
    end

    context "pass in metadata" do
      before do
        @metadata = {
          'code'          => "dsyaj",
          'started'       => false,
          'size'          => 0,
          'creation_time' => '2010-08-14T13:01:48.454624'
        }
        @index = IndexTank::Index.new("http://api.indextank.com#{@path_prefix}", @metadata)
      end

      it_should_behave_like "metadata"
    end

    context "metadata is not passed in" do
      before do
        @index = IndexTank::Client.new("http://:uiTPmHg2JTjSMD@dstqe.api.indextank.com").indexes('new-index')
        @stubs.get(@path_prefix) { [200, {}, '{"started": false, "code": "dsyaj", "creation_time": "2010-08-14T13:01:48.454624", "size": 0}'] }
      end

      it_should_behave_like "metadata"
    end
  end
end

