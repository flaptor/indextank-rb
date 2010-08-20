require File.expand_path('../../../spec_helper', __FILE__)

describe IndexTank::Document do
  before do
    @stubs = Faraday::Adapter::Test::Stubs.new
    stub_setup_connection
    @document = IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com").indexes('new-index').document('document1')
    @path_prefix = '/v1/indexes/new-index/docs/'
  end

  describe "document management" do
    describe "#add" do
      context "document was indexed" do
        before do
          @stubs.put(@path_prefix) { [200, {}, ''] }
        end

        it "should return true" do
          @document.add(:text => 'some text').should be_true
        end
      end

      context "index was initializing" do
        before do
          @stubs.put(@path_prefix) { [409, {}, ''] }
        end

        it "should return false" do
          @document.add(:text => 'some text').should be_false
        end
      end

      context "invalid or missing argument" do
        before do
          @stubs.put(@path_prefix) { [400, {}, ''] }
        end

        it "should return false" do
          @document.add(:text => 'some text').should be_false
        end
      end

      context "no index existed for the given name" do
        before do
          @stubs.put(@path_prefix) { [404, {}, ''] }
        end

        it "should return false" do
          @document.add(:text => 'some text').should be_false
        end
      end
    end

    describe "#delete" do
      context "document was deleted" do
        before do
          @stubs.delete(@path_prefix) { [200, {}, ''] }
        end

        it "should return true" do
          @document.delete.should be_true
        end
      end

      context "index is initializing" do
        before do
          @stubs.delete(@path_prefix) { [409, {}, ''] }
        end

        it "should return false" do
          @document.delete.should be_false
        end
      end

      context "invalid or missing argument" do
        before do
          @stubs.delete(@path_prefix) { [400, {}, ''] }
        end

        it "should return false" do
          @document.delete.should be_false
        end
      end

      context "no index existed for the given name" do
        before do
          @stubs.delete(@path_prefix) { [404, {}, ''] }
        end

        it "should return false" do
          @document.delete.should be_false
        end
      end
    end
  end

  describe "#update_variables" do
    before do
      @new_variables = {
        0 => 'new_rating',
        1 => 'new_reputation',
        2 => 'new_visits'
      }
    end

    context "variables indexed" do
      before do
        @stubs.put("#{@path_prefix}variables") { [200, {}, ''] }
      end

      it "should return true" do
        @document.update_variables(@new_variables).should be_true
      end
    end

    context "index is initializing" do
      before do
        @stubs.put("#{@path_prefix}variables") { [409, {}, ''] }
      end

      it "should return false" do
        @document.update_variables(@new_variables).should be_false
      end
    end

    context "invalid or missing argument" do
      before do
        @stubs.put("#{@path_prefix}variables") { [400, {}, ''] }
      end

      it "should return false" do
        @document.update_variables(@new_variables).should be_false
      end
    end

    context "no index existed for the given name" do
      before do
        @stubs.put("#{@path_prefix}variables") { [404, {}, ''] }
      end

      it "should return false" do
        @document.update_variables(@new_variables).should be_false
      end
    end
  end
end
