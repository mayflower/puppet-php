# frozen_string_literal: true

require 'spec_helper'

describe 'php::fpm', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end
      let(:pre_condition) { 'class {"php": fpm => false}' }

      describe 'works without params' do
        it { is_expected.to compile.with_all_deps }
      end

      describe 'when called with no parameters' do
        # rubocop:disable RSpec/RepeatedExample
        case facts[:os]['family']
        when 'Debian'
          case facts[:os]['release']['major']
          when '18.04'
            it { is_expected.to contain_package('php7.2-fpm').with_ensure('present') }
            it { is_expected.to contain_service('php7.2-fpm').with_ensure('running') }
          when '22.04'
            it { is_expected.to contain_package('php8.1-fpm').with_ensure('present') }
            it { is_expected.to contain_service('php8.1-fpm').with_ensure('running') }
          when '24.04'
            it { is_expected.to contain_package('php8.3-fpm').with_ensure('present') }
            it { is_expected.to contain_service('php8.3-fpm').with_ensure('running') }
          when '20.04', '11'
            it { is_expected.to contain_package('php7.4-fpm').with_ensure('present') }
            it { is_expected.to contain_service('php7.4-fpm').with_ensure('running') }
          when '10'
            it { is_expected.to contain_package('php7.3-fpm').with_ensure('present') }
            it { is_expected.to contain_service('php7.3-fpm').with_ensure('running') }
          end
        when 'Suse'
          it { is_expected.to contain_package('php5-fpm').with_ensure('present') }
          it { is_expected.to contain_service('php-fpm').with_ensure('running') }
        when 'FreeBSD'
          it { is_expected.not_to contain_package('php56-') }
          it { is_expected.not_to contain_package('php5-fpm') }
          it { is_expected.not_to contain_package('php-fpm') }
          it { is_expected.to contain_service('php_fpm').with_ensure('running') }
        else
          it { is_expected.to contain_package('php-fpm').with_ensure('present') }
          it { is_expected.to contain_service('php-fpm').with_ensure('running') }
        end
        # rubocop:enable RSpec/RepeatedExample
        it { is_expected.to contain_class('php::fpm::config').that_notifies('Class[php::fpm::service]') }
        it { is_expected.to contain_class('php::fpm::service') }
      end
    end
  end
end
