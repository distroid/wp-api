# frozen_string_literal: true

describe WP::API do
  context 'raw HTTP request' do
    let(:response) { HTTParty.get('http://wp.example.com/wp-json/wp/v2/users/1').body }
    let(:file) { support_file('users/1.json') }
    subject { parse_json(response) }

    it { should eq parse_json(file) }
  end

  context '/wp-json/wp/v2/user/:user' do
    let(:client) { WP::API['wp.example.com'] }

    subject { client.user(1) }

    it 'should be a user' do
      expect(subject).to be_a WP::API::User
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
  end
end
