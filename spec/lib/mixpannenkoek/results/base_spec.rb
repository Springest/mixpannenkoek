require 'spec_helper'

describe Mixpannenkoek::Results::Base do
  let(:response_data) { JSON.parse(File.open("#{File.dirname(__FILE__)}/../../../fixtures/funnel_response_data.json").read) }

  describe '#to_hash' do
    subject { described_class.new(response_data).to_hash }
    it 'returns the response data' do
      expect(subject).to eq response_data
    end
  end

  describe '#response_data' do
    subject { described_class.new(response_data).response_data }
    it 'returns the response data' do
      expect(subject).to eq response_data
    end
  end

  describe '#method_missing' do
    subject { described_class.new(response_data) }
    it 'delegates to to_hash' do
      expect(subject.keys).to eq ['data', 'meta']
    end
  end
end
