# frozen_string_literal: true

describe WP::API do
  context 'raw HTTP request' do
    let(:response) { HTTParty.get('http://wp.example.com/wp-json/wp/v2/posts').body }
    let(:file) { support_file('posts.json') }
    subject { parse_json(response) }

    it { should eq parse_json(file) }
  end

  context '/wp-json/wp/v2/posts' do
    let(:client) { WP::API['wp.example.com'] }

    subject { client.posts }

    it 'should have size of 2' do
      expect(subject.size).to eq 2
    end

    it 'should have correct IDs' do
      expect(subject.collect(&:id)).to match_array [1, 2]
    end

    it 'should have authors' do
      expect(subject.collect(&:author).size).to eq 2
    end

    context 'first post' do
      subject do
        client.posts.find { |p| p.id == 1 }
      end

      it 'should have boolean methods' do
        expect(subject.sticky).to eq true
        expect(subject.sticky?).to eq true
      end

      it('should have a title') { expect(subject.title['rendered']).to eq 'First post' }

      context 'author' do
        let(:author) { subject.author(client) }

        it 'should be converted to user class' do
          expect(author).to be_a WP::API::User
        end
      end

      context 'categories' do
        let(:categories) { subject.categories(client) }

        it 'return list of ids' do
          expect(categories.size).to eq 1
          expect(categories.first).to eq 1
        end
      end

      context 'link headers' do
        its(:next) { should == '/wp-json/wp/v2/posts?page=2' }
        its(:prev) { should be_nil }
        its('items.size') { should eq 2 }
      end
    end
  end
end
