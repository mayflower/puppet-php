# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'with RedHat', if: (fact('os.family') == 'RedHat') do
  context 'default parameters' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        include 'php::repo::redhat'
        PUPPET
      end
    end
    describe yumrepo('remi-php56') do
      it { is_expected.to exist }
    end
  end

  context 'with version 7.2' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'php::repo::redhat':
          yum_repo => 'remi_php72',
        }
        PUPPET
      end
    end
    describe yumrepo('remi-php72') do
      it { is_expected.to exist }
    end
  end
end
