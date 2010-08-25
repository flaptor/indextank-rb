require File.expand_path('../../../spec_helper', __FILE__)

describe IndexTank::Index do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:index) { IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com").indexes('new-index') }
  let(:path_prefix) { '/v1/indexes/new-index/' }

  before { stub_setup_connection }

  describe "index management" do
    describe "add an index" do
      subject { index.add }
      # after do
      #   @index.delete
      # end

      context "the index does not exist" do
        before do
          stubs.put(path_prefix) { [201, {}, '{"started": false, "code": "dsyaj", "creation_time": "2010-08-14T13:01:48.454624", "size": 0}'] }
        end

        it { should be_true }
      end

      context "when an index already exists" do
        before do
          # @index.add
          stubs.put(path_prefix) { [204, {}, ''] }
        end

        it "should raise an exception" do
          expect { subject }.to raise_error(IndexTank::IndexAlreadyExists)
        end
      end

      context "when the user has too many indexes" do
        before do
          stubs.put(path_prefix) { [409, {}, ''] }
        end

        it "should raise an exception" do
          expect { subject }.to raise_error(IndexTank::TooManyIndexes)
        end
      end
    end

    describe "delete an index" do
      subject { index.delete }

      context "the index exists" do
        before do
          # @index.add
          stubs.delete(path_prefix) { [200, {}, ''] }
        end

        it { should be_true }
      end

      context "the index does not exist" do
        before do
          stubs.delete(path_prefix) { [204, {}, ''] }
        end

        it { subject.should be_false }
      end
    end
  end

  context "when examining the metadata" do
    subject { index }

    shared_examples_for "metadata" do
      it "should return the code" do
        subject.code.should == 'dsyaj'
      end

      it "should update and return the running" do
        # delete any preceding stubs if they exist.
        stubs.match(:get, path_prefix, nil)
        stubs.get(path_prefix) { [200, {}, '{"started": true, "code": "dsyaj", "creation_time": "2010-08-14T13:01:48.454624", "size": 0}'] }
        subject.running?.should be_true
      end

      it "should return the size" do
        subject.size.should == 0
      end

      it "should return the creation_time" do
        subject.creation_time.should == "2010-08-14T13:01:48.454624"
      end
    end

    context "pass in metadata" do
      let(:metadata) do
        {
          'code'          => "dsyaj",
          'started'       => false,
          'size'          => 0,
          'creation_time' => '2010-08-14T13:01:48.454624'
        }
      end
      let(:index) { IndexTank::Index.new("http://api.indextank.com#{path_prefix}", metadata) }

      it_should_behave_like "metadata"
    end

    context "metadata is not passed in" do
      let(:index) { IndexTank::Client.new("http://:uiTPmHg2JTjSMD@dstqe.api.indextank.com").indexes('new-index') }

      before do
        stubs.get(path_prefix) { [200, {}, '{"started": false, "code": "dsyaj", "creation_time": "2010-08-14T13:01:48.454624", "size": 0}'] }
      end

      it_should_behave_like "metadata"
    end
  end

  describe "#exists?" do
    subject { index.exists? }

    context "when an index exists" do
      before do
        stubs.get(path_prefix) { [200, {}, '{"started": false, "code": "dsyaj", "creation_time": "2010-08-14T13:01:48.454624", "size": 0}'] }
      end

      it { should be_true }
    end

    context "when an index doesn't exist" do
      before do
        stubs.get(path_prefix) { [404, {}, ''] }
      end

      # rspec2 bug, implicit subject is calling subject twice
      it { subject.should be_false }
    end
  end

  describe "#search" do
    subject { index.search('foo') }

    context "search is successful" do
      before do
        stubs.get("#{path_prefix}search?q=foo&start=0&len=10") { [200, {}, '{"matches": 4, "search_time": "0.022", "results": [{"docid": "http://cnn.com/HEALTH"}, {"docid": "http://www.cnn.com/HEALTH/"}, {"docid": "http://cnn.com/HEALTH/?hpt=Sbin"}, {"docid": "http://cnn.com/HEALTH/"}]}'] }
      end

      it "should have the number of matches" do
        subject['matches'].should == 4
      end

      it "should a list of docs" do
        results = subject['results']

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
        stubs.get("#{path_prefix}search") { [409, {}, ''] }
      end

      it "should return an empty body"
    end

    context "index is invalid/missing argument", :pending => true do
      before do
        stubs.get("#{path_prefix}search") { [400, {}, ''] }
      end

      it "should return a descriptive error message"
    end

    context "no index existed for the given name", :pending => true do
      before do
        stubs.get("#{path_prefix}search") { [404, {}, ''] }
      end

      it "should return a descriptive error message"
    end
  end

  describe "#promote" do
    subject { index.promote(4, 'foo') }

    context "when the document is promoted" do
      before do
        stubs.get("#{path_prefix}promote?docid=4&query=foo") { [200, {}, ''] }
      end

      it { should be_true }
    end

    context "when the index is initializing" do
      before do
        stubs.get("#{path_prefix}promote?docid=4&query=foo") { [409, {}, ''] }
      end

      it { subject.should be_false }
    end

    context "when invalid or missing argument" do
      before do
        stubs.get("#{path_prefix}promote?docid=4&query=foo") { [400, {}, ''] }
      end

      it { subject.should be_false }
    end

    context "when no index exists for the given name" do
      before do
        stubs.get("#{path_prefix}promote?docid=4&query=foo") { [404, {}, ''] }
      end

      it { subject.should be_false }
    end
  end

  describe "#document" do
    subject { index.document('foo') }

    it "should create a document object" do
      should be_an_instance_of(IndexTank::Document)
    end
  end

  describe "#function" do
    context "with no params" do
      subject { index.functions }

      before do
        stubs.get("#{path_prefix}functions") { [200, {}, '{"0": "0-A", "1": "-age", "2": "relevance"}'] }
      end

      it "should return an array of functions" do
        should == [
          IndexTank::Function.new("#{path_prefix}functions", 0, '0-A'),
          IndexTank::Function.new("#{path_prefix}functions", 1, '-age'),
          IndexTank::Function.new("#{path_prefix}functions", 2, 'relevance')
        ]
      end
    end

    context "with a function name and definition" do
      subject { index.functions(0, '-age') }

      it "should return an instance of Function" do
        should be_an_instance_of(IndexTank::Function)
      end
    end

    context "with a function name" do
      subject { index.functions(0) }

      it "should return an instance of Function" do
        should be_an_instance_of(IndexTank::Function)
      end
    end
  end
end

