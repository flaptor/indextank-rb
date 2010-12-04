require File.expand_path('../../../spec_helper', __FILE__)

describe IndexTank::Document do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:document) { IndexTank::Client.new("http://:xxxx@dstqe.api.indextank.com").indexes('new-index').document('document1') }
  let(:path_prefix) { '/v1/indexes/new-index/docs/' }

  before { stub_setup_connection }

  describe "document management" do
    describe "#add" do
      subject { document.add(:text => 'some text') }

      context "document was indexed" do
        before do
          stubs.put(path_prefix) { [200, {}, ''] }
        end

        it { subject.should be_true }
      end

      context "index was initializing" do
        before do
          stubs.put(path_prefix) { [409, {}, ''] }
        end

        it { subject.should be_false }
      end

      context "invalid or missing argument" do
        before do
          stubs.put(path_prefix) { [400, {}, ''] }
        end

        it { subject.should be_false }
      end

      context "no index existed for the given name" do
        before do
          stubs.put(path_prefix) { [404, {}, ''] }
        end

        it { subject.should be_false }
      end
    end

    describe "#delete" do
      subject { document.delete }

      context "document was deleted" do
        before do
          stubs.delete(path_prefix) { [200, {}, ''] }
        end

        it { should be_true }
      end

      context "index is initializing" do
        before do
          stubs.delete(path_prefix) { [409, {}, ''] }
        end

        it { subject.should be_false }
      end

      context "invalid or missing argument" do
        before do
          stubs.delete(path_prefix) { [400, {}, ''] }
        end

        it { subject.should be_false }
      end

      context "no index existed for the given name" do
        before do
          stubs.delete(path_prefix) { [404, {}, ''] }
        end

        it { subject.should be_false }
      end
    end
  end

  describe "#update_variables" do
    let(:new_variables) do
      {
        0 => 'new_rating',
        1 => 'new_reputation',
        2 => 'new_visits'
      }
    end

    subject { document.update_variables(new_variables) }

    context "variables indexed" do
      before do
        stubs.put("#{path_prefix}variables") { [200, {}, ''] }
      end

      it { should be_true }
    end

    context "index is initializing" do
      before do
        stubs.put("#{path_prefix}variables") { [409, {}, ''] }
      end

      it { subject.should be_false }
    end

    context "invalid or missing argument" do
      before do
        stubs.put("#{path_prefix}variables") { [400, {}, ''] }
      end

      it { subject.should be_false }
    end

    context "no index existed for the given name" do
      before do
        stubs.put("#{path_prefix}variables") { [404, {}, ''] }
      end

      it { subject.should be_false }
    end
  end
end
