# frozen_string_literal: true

describe WP::API do
  context 'raw HTTP request' do
    let(:response) { HTTParty.get('http://wp.example.com/wp-json/wp/v2/categories/1').body }
    let(:file) { support_file('categories/1.json') }
    subject { parse_json(response) }

    it { should eq parse_json(file) }
  end

  context '/wp-json/wp/v2/categories/:category' do
    let(:client) { WP::API['wp.example.com'] }

    subject { client.category(1) }

    it 'should be a category' do
      expect(subject).to be_a WP::API::Category
    end

    it 'should have an attributes hash' do
      expect(subject.attributes).to be_a Hash
    end

    it 'should have a headers hash' do
      expect(subject.headers).to be_a Hash
    end

    it 'should have correct IDs' do
      expect(subject.id).to eq 1
    end

    it 'should have correct name' do
      expect(subject['name']).to eq 'Test'
    end

    it 'list of attributes' do
      expect(subject.attributes.keys).to match_array(
        %w[id count description link name slug taxonomy parent meta _links]
      )
    end
  end
end
