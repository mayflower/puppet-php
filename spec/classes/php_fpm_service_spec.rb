# frozen_string_literal: true

require 'spec_helper'

describe 'php::fpm::service', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      let(:pre_condition) { 'class {"php": fpm => true}' }

      describe 'works without default' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('php::cli') }
        it { is_expected.to contain_class('php::composer::auto_update') }
        it { is_expected.to contain_class('php::composer') }
        it { is_expected.to contain_class('php::dev') }
        it { is_expected.to contain_class('php::fpm::config') }
        it { is_expected.to contain_class('php::fpm') }
        it { is_expected.to contain_class('php::packages') }
        it { is_expected.to contain_class('php::globals') }
        it { is_expected.to contain_class('php::params') }

        it { is_expected.to contain_class('php::pear') } if facts[:osfamily] != 'Archlinux'
      end

      describe 'when called with no parameters' do
        case facts[:os]['family']
        when 'Debian'
          case facts[:os]['release']['major']
          when '18.04'
            it { is_expected.to contain_service('php7.2-fpm').with_ensure('running') }
          when '22.04'
            it { is_expected.to contain_service('php8.1-fpm').with_ensure('running') }
          when '24.04'
            it { is_expected.to contain_service('php8.3-fpm').with_ensure('running') }
          when '10'
            it { is_expected.to contain_service('php7.3-fpm').with_ensure('running') }
          when '20.04', '11'
            it { is_expected.to contain_service('php7.4-fpm').with_ensure('running') }
          end
        when 'FreeBSD'
          it { is_expected.to contain_service('php_fpm').with_ensure('running') }
        when 'Suse'
          it { is_expected.to contain_service('php-fpm').with_ensure('running') }
        end
      end
    end
  end
end
