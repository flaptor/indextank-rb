require File.expand_path('../../../spec_helper', __FILE__)

describe IndexTank::Function do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:function) { IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com").indexes('new-index').functions(0, '-age') }
  let(:path_prefix) { '/v1/indexes/new-index/functions/0' }

  before { stub_setup_connection do |builder| builder.use IndexTank::DocumentResponseMiddleware; end}

  describe "function management" do
    describe "#add" do
      subject { function.add }

      context "no definition specified" do
        let(:function) { IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com").indexes('new-index').functions(0) }
        it "should raise an exception" do
          expect { subject }.to raise_error(IndexTank::MissingFunctionDefinition)
        end
      end

      context "function saved" do
        before do
          stubs.put(path_prefix) { [200, {}, ''] }
        end

        it { should be_true }
      end

      context "index is initializing" do
        before do
          stubs.put(path_prefix) { [409, {}, ''] }
        end

        it "should raise an exception" do
          expect {subject}.to raise_error(IndexTank::IndexInitializing)
        end
      end

      context "invalid or missing argument" do
        before do
          stubs.put(path_prefix) { [400, {}, ''] }
        end

        it "should raise an exception" do
          expect {subject}.to raise_error(IndexTank::InvalidArgument)
        end
      end

      context "no index existed for the given name" do
        before do
          stubs.put(path_prefix) { [404, {}, ''] }
        end

        it "should raise an exception" do
          expect {subject}.to raise_error(IndexTank::NonExistentIndex)
        end
      end
    end

    describe "#delete" do
      subject { function.delete }

      context "function deleted" do
        before do
          stubs.delete(path_prefix) { [200, {}, ''] }
        end

        it { should be_true }
      end

      context "index is initializing" do
        before do
          stubs.delete(path_prefix) { [409, {}, ''] }
        end

        it "should raise an exception" do
          expect {subject}.to raise_error(IndexTank::IndexInitializing)
        end
      end

      context "invalid or missing argument" do
        before do
          stubs.delete(path_prefix) { [400, {}, ''] }
        end

        it "should raise an exception" do
          expect {subject}.to raise_error(IndexTank::InvalidArgument)
        end
      end

      context "no index existed for the given name" do
        before do
          stubs.delete(path_prefix) { [404, {}, ''] }
        end

        it "should raise an exception" do
          expect {subject}.to raise_error(IndexTank::NonExistentIndex)
        end
      end
    end
  end
end
