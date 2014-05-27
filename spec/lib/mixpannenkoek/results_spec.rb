require 'spec_helper'

describe Mixpannenkoek::Results do
  describe '.new' do
    subject { Mixpannenkoek::Results.new(endpoint,  {}) }

    context 'any endpoint' do
      let(:endpoint) { 'endpoint' }
      it { expect(subject).to be_a Mixpannenkoek::Results::Base }
    end

    context 'funnels endoint' do
      let(:endpoint) { 'funnels' }
      it { expect(subject).to be_a Mixpannenkoek::Results::Funnels }
    end
  end
end
