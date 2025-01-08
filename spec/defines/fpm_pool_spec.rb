# frozen_string_literal: true

require 'spec_helper'

describe 'php::fpm::pool' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end
      let(:pre_condition) { 'include php' }

      case facts[:os]['name']
      when 'Debian'
        context 'plain config' do
          let(:title) { 'unique-name' }
          let(:params) { {} }

          case facts[:os]['release']['major']
          when '12'
            it { is_expected.to contain_file('/etc/php/8.2/fpm/pool.d/unique-name.conf') }
          when '11'
            it { is_expected.to contain_file('/etc/php/7.4/fpm/pool.d/unique-name.conf') }
          when '10'
            it { is_expected.to contain_file('/etc/php/7.3/fpm/pool.d/unique-name.conf') }
          else
            it { is_expected.to contain_file('/etc/php5/fpm/pool.d/unique-name.conf') }
          end
        end
      when 'Ubuntu'
        context 'plain config' do
          let(:title) { 'unique-name' }
          let(:params) { {} }

          case facts[:os]['release']['major']
          when '24.04'
            it { is_expected.to contain_file('/etc/php/8.3/fpm/pool.d/unique-name.conf') }
          when '22.04'
            it { is_expected.to contain_file('/etc/php/8.1/fpm/pool.d/unique-name.conf') }
          when '20.04'
            it { is_expected.to contain_file('/etc/php/7.4/fpm/pool.d/unique-name.conf') }
          when '18.04'
            it { is_expected.to contain_file('/etc/php/7.2/fpm/pool.d/unique-name.conf') }
          else
            it { is_expected.to contain_file('/etc/php5/fpm/pool.d/unique-name.conf') }
          end
        end
      end
    end
  end
end
