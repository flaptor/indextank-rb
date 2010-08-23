require File.expand_path('../../../spec_helper', __FILE__)

describe IndexTank::Function do
  before do
    @stubs = Faraday::Adapter::Test::Stubs.new
    stub_setup_connection
    @function = IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com").indexes('new-index').functions(0, '-age')
    @path_prefix = '/v1/indexes/new-index/functions/0/'
  end

  describe "function management" do
    describe "#add" do
      context "no definition specified" do
        before do
          @function = IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com").indexes('new-index').functions(0)
        end

        it "should raise an exception" do
          lambda { @function.add }.should raise_error(IndexTank::MissingFunctionDefinition)
        end
      end

      context "function saved" do
        before do
          @stubs.put(@path_prefix) { [200, {}, ''] }
        end

        it "should return true" do
          @function.add.should be_true
        end
      end

      context "index is initializing" do
        before do
          @stubs.put(@path_prefix) { [409, {}, ''] }
        end

        it "should return false" do
          @function.add.should be_false
        end
      end

      context "invalid or missing argument" do
        before do
          @stubs.put(@path_prefix) { [400, {}, ''] }
        end

        it "should return false" do
          @function.add.should be_false
        end
      end

      context "no index existed for the given name" do
        before do
          @stubs.put(@path_prefix) { [404, {}, ''] }
        end

        it "should return false" do
          @function.add.should be_false
        end
      end
    end

    describe "#delete" do
      context "function deleted" do
        before do
          @stubs.delete(@path_prefix) { [200, {}, ''] }
        end

        it "should return true" do
          @function.delete.should be_true
        end
      end

      context "index is initializing" do
        before do
          @stubs.delete(@path_prefix) { [409, {}, ''] }
        end

        it "should return false" do
          @function.delete.should be_false
        end
      end

      context "invalid or missing argument" do
        before do
          @stubs.delete(@path_prefix) { [400, {}, ''] }
        end

        it "should return false" do
          @function.delete.should be_false
        end
      end

      context "no index existed for the given name" do
        before do
          @stubs.delete(@path_prefix) { [404, {}, ''] }
        end

        it "should return false" do
          @function.delete.should be_false
        end
      end
    end
  end
end
