require File.expand_path('../../../spec_helper', __FILE__)

describe IndexTank::Index do
  before do
    @stubs = Faraday::Adapter::Test::Stubs.new
    stub_setup_connection
    @index = IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com").indexes('new-index')
    @path_prefix = '/v1/indexes/new-index/'
  end

  describe "index management" do
    describe "add an index" do
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

    describe "delete an index" do
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

  describe "#exists?" do
    context "when an index exists" do
      before do
        @stubs.get(@path_prefix) { [200, {}, '{"started": false, "code": "dsyaj", "creation_time": "2010-08-14T13:01:48.454624", "size": 0}'] }
      end

      it "should return true" do
        @index.exists?.should be_true
      end
    end

    context "when an index doesn't exist" do
      before do
        @stubs.get(@path_prefix) { [404, {}, ''] }
      end

      it "should return false" do
        @index.exists?.should be_false
      end
    end
  end

  describe "#search" do
    context "search is successful" do
      before do
        @stubs.get("/search") { [200, {}, '{"matches": 4, "search_time": "0.022", "results": [{"docid": "http://cnn.com/HEALTH"}, {"docid": "http://www.cnn.com/HEALTH/"}, {"docid": "http://cnn.com/HEALTH/?hpt=Sbin"}, {"docid": "http://cnn.com/HEALTH/"}]}'] }
      end

      it "should have the number of matches" do
        @index.search('foo')['matches'].should == 4
      end

      it "should a list of docs" do
        results = @index.search('foo')['results']

        %w(http://cnn.com/HEALTH
           http://www.cnn.com/HEALTH/
           http://cnn.com/HEALTH/?hpt=Sbin
           http://cnn.com/HEALTH/).each_with_index do |docid, index|
          results[index]['docid'].should == docid
        end
      end
    end

    context "index is initializing", :pending => true do
      before do
        @stubs.get("/search") { [409, {}, ''] }
      end

      it "should return an empty body"
    end

    context "index is invalid/missing argument", :pending => true do
      before do
        @stubs.get("/search") { [400, {}, ''] }
      end

      it "should return a descriptive error message"
    end

    context "no index existed for the given name", :pending => true do
      before do
        @stubs.get("/search") { [404, {}, ''] }
      end

      it "should return a descriptive error message"
    end
  end

  describe "#promote" do
    context "when the document is promoted" do
      before do
        @stubs.get("/promote") { [200, {}, ''] }
      end

      it "should return true" do
        @index.promote(4, 'foo').should be_true
      end
    end

    context "when the index is initializing" do
      before do
        @stubs.get("/promote") { [409, {}, ''] }
      end

      it "should return false" do
        @index.promote(4, 'foo').should be_false
      end
    end

    context "when invalid or missing argument" do
      before do
        @stubs.get("/promote") { [400, {}, ''] }
      end

      it "should return false" do
        @index.promote(4, 'foo').should be_false
      end
    end

    context "when no index exists for the given name" do
      before do
        @stubs.get("/promote") { [404, {}, ''] }
      end

      it "should return false" do
        @index.promote(4, 'foo').should be_false
      end
    end
  end

  describe "#document" do
    it "should create a document object" do
      @index.document('foo').should be_an_instance_of(IndexTank::Document)
    end
  end

  describe "#function" do
    context "with no params" do
      before do
        @stubs.get("/functions") { [200, {}, '{"0": "0-A", "1": "-age", "2": "relevance"}'] }
      end

      it "should return an array of functions" do
        @index.functions.should == [
          IndexTank::Function.new("#{@path_prefix}functions", 0, '0-A'),
          IndexTank::Function.new("#{@path_prefix}functions", 1, '-age'),
          IndexTank::Function.new("#{@path_prefix}functions", 2, 'relevance')
        ]
      end
    end

    context "with a function name and definition" do
      it "should return an instance of Function" do
        @index.functions(0, '-age').should be_an_instance_of(IndexTank::Function)
      end
    end

    context "with a function name" do
      it "should return an instance of Function" do
        @index.functions(0).should be_an_instance_of(IndexTank::Function)
      end
    end
  end
end

