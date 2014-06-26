require 'spec_helper'

describe Mixpannenkoek::Base do
  class Mixpannenkoek::TestQuery < Mixpannenkoek::Base
    set_api_key 'an_api_key'
    set_api_secret 'an_api_secret'
    set_endpoint 'funnels'
  end

  let(:date_range) { Date.parse('01-01-2014')..Date.parse('05-01-2014') }

  describe '#where' do
    subject { Mixpannenkoek::TestQuery.where(date: date_range).where(subject_name: 'Subject ABC').request_parameters[1] }
    it 'sets :where' do
      expect(subject).to include({ where: 'properties["subject_name"] == "Subject ABC"' })
    end

    context 'called twice' do
      subject { Mixpannenkoek::TestQuery.where(date: date_range).where(subject_name: 'Subject ABC').where(training_name: 'Training XYZ').request_parameters[1] }
      it 'sets multiple :where conditions' do
        expect(subject).to include({ where: 'properties["subject_name"] == "Subject ABC" and properties["training_name"] == "Training XYZ"' })
      end
    end

    context 'called with value: []' do
      subject { Mixpannenkoek::TestQuery.where(date: date_range).where(subject_name: ['Subject ABC', 'Subject XYZ']).request_parameters[1] }
      it 'sets multiple :where conditions' do
        expect(subject).to include({ where: '(properties["subject_name"] == "Subject ABC" or properties["subject_name"] == "Subject XYZ")' })
      end
    end

    context 'where(date: range)' do
      subject { Mixpannenkoek::TestQuery.where(date: date_range).request_parameters[1] }

      it 'does not automatically set the interval' do
        expect(subject.keys).not_to include(:interval)
      end

      it 'sets :from_date' do
        expect(subject).to include({ from_date: '2014-01-01' })
      end

      it 'sets :to_date' do
        expect(subject).to include({ to_date: '2014-01-05' })
      end

      context 'date strings' do
        let(:date_range) { '2014-01-01'..'2014-01-31' }
        it 'sets :from_date' do
          expect(subject).to include({ from_date: '2014-01-01' })
        end

        it 'sets :to_date' do
          expect(subject).to include({ to_date: '2014-01-31' })
        end
      end
    end
  end

  describe '#where_not' do
    subject { Mixpannenkoek::TestQuery.where(date: date_range).where_not(subject_name: 'Subject ABC').request_parameters[1] }
    it 'sets :where' do
      expect(subject).to include({ where: 'properties["subject_name"] != "Subject ABC"' })
    end

    context 'called twice' do
      subject { Mixpannenkoek::TestQuery.where(date: date_range).where_not(subject_name: 'Subject ABC').where_not(training_name: 'Training XYZ').request_parameters[1] }
      it 'sets multiple :where conditions' do
        expect(subject).to include({ where: 'properties["subject_name"] != "Subject ABC" and properties["training_name"] != "Training XYZ"' })
      end
    end

    context 'called with value: []' do
      subject { Mixpannenkoek::TestQuery.where(date: date_range).where_not(subject_name: ['Subject ABC', 'Subject XYZ']).request_parameters[1] }
      it 'sets multiple :where conditions' do
        expect(subject).to include({ where: '(properties["subject_name"] != "Subject ABC" and properties["subject_name"] != "Subject XYZ")' })
      end
    end
  end

  describe '#group' do
    subject { Mixpannenkoek::TestQuery.where(date: date_range).group('subject_name').request_parameters[1] }
    it 'sets :on' do
      expect(subject).to include({ on: 'properties["subject_name"]' })
    end

    context 'called twice' do
      subject { Mixpannenkoek::TestQuery.where(date: date_range).group('subject_name').group('training_name').request_parameters[1] }
      it 'takes the value from the last call' do
        expect(subject).to include({ on: 'properties["training_name"]' })
      end
    end
  end

  describe '#set' do
    subject { Mixpannenkoek::TestQuery.set(funnel_id: 12345).where(date: date_range).request_parameters[1] }
    it { expect(subject).to include({ funnel_id: 12345 }) }

    context 'called twice' do
      subject { Mixpannenkoek::TestQuery.set(funnel_id: 12345).set(event: 'click').where(date: date_range).request_parameters[1] }
      it { should include({ funnel_id: 12345 }) }
      it { should include({ event: 'click' }) }
    end
  end

  describe '#query' do
    context 'without date range' do
      subject { Mixpannenkoek::TestQuery.group('subject_name').to_hash }
      it 'raises Mixpannenkoek::Query::MissingRange' do
        expect { subject }.to raise_error Mixpannenkoek::Query::MissingRange
      end
    end

    context 'missing api_key' do
      subject { Mixpannenkoek::TestQuery.where(date: date_range).to_hash }
      before { allow(Mixpannenkoek::TestQuery).to receive(:api_key) { nil } }
      it 'raises Mixpannenkoek::Query::MissingConfiguration' do
        expect { subject }.to raise_error Mixpannenkoek::Query::MissingConfiguration, 'The mixpanel api_key has not been configured'
      end
    end

    context 'missing api_secret' do
      subject { Mixpannenkoek::TestQuery.where(date: date_range).to_hash }
      before { allow(Mixpannenkoek::TestQuery).to receive(:api_secret) { nil } }
      it 'raises Mixpannenkoek::Query::MissingConfiguration' do
        expect { subject }.to raise_error Mixpannenkoek::Query::MissingConfiguration, 'The mixpanel api_secret has not been configured'
      end
    end
  end

  describe '#results' do
    subject { Mixpannenkoek::TestQuery.where(date: date_range).results }

    let(:response_data) { JSON.parse(File.open("#{File.dirname(__FILE__)}/../../fixtures/funnel_response_data.json").read) }
    before { allow_any_instance_of(Mixpanel::Client).to receive(:request).and_return(response_data) }

    it 'returns a Mixpannenkoek::Results::Base object' do
      expect(subject).to be_a Mixpannenkoek::Results::Base
    end
  end

  describe '#method_missing' do
    before { allow_any_instance_of(Mixpanel::Client).to receive(:request).and_return({ "data" => { "2014-01-01" => [{ 'count' => '1' }, { 'count' => '4' }] } }) }
    it 'delegates all calls to #results.send(*args)' do
      expect(Mixpannenkoek::TestQuery.where(date: date_range).keys).to eq ['2014-01-01']
    end

    it 'delegates blocks' do
      expect(Mixpannenkoek::TestQuery.where(date: date_range).values[0].map { |hash| hash['count'] }).to eq ['1','4']
    end
  end

  describe '.default_scope' do
    class Mixpannenkoek::DefaultScopeQuery < Mixpannenkoek::TestQuery
      default_scope { where(subject_name: 'Subject XYZ') }
    end

    subject { Mixpannenkoek::DefaultScopeQuery.where(date: date_range).request_parameters[1] }
    it 'applies the default scope' do
      expect(subject).to include({ where: 'properties["subject_name"] == "Subject XYZ"' })
    end
  end
end
