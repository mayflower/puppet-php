# frozen_string_literal: true

require 'rspec'
require 'spec_helper'

describe 'php::fpm::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      describe 'works without params' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('php::globals') }
        it { is_expected.to contain_class('php::params') }
      end

      describe 'creates config file' do
        let(:params) do
          {
            inifile: '/etc/php5/conf.d/unique-name.ini',
            settings: {
              'apc.enabled' => 1
            }
          }
        end

        it do
          is_expected.to contain_class('php::fpm::config').with(
            inifile: '/etc/php5/conf.d/unique-name.ini',
            settings: {
              'apc.enabled' => 1
            }
          )
        end

        it do
          is_expected.to contain_php__config('fpm').with(
            file: '/etc/php5/conf.d/unique-name.ini',
            config: {
              'apc.enabled' => 1
            }
          )
        end
      end

      describe 'manages a log directory' do
        context 'with dedicated path' do
          let(:params) do
            {
              error_log: '/var/log/php/fpm.log',
            }
          end

          it do
            is_expected.to contain_file('/var/log/php')
          end
        end

        context 'without dedicated path' do
          let(:params) do
            {
              error_log: '/var/log/php-fpm.log',
            }
          end

          it do
            is_expected.not_to contain_file('/var/log')
          end
        end

        context 'without syslog logging' do
          let(:params) do
            {
              error_log: 'syslog',
            }
          end

          it do
            is_expected.not_to contain_file('syslog')
          end
        end
      end

      describe 'manages a runtime directory' do
        context 'with dedicated path' do
          let(:params) do
            {
              pid_file: '/var/run/php/fpm.pid',
            }
          end

          it do
            is_expected.to contain_file('/var/run/php')
          end
        end

        context 'without dedicated path' do
          let(:params) do
            {
              pid_file: '/var/run/fpm.pid',
            }
          end

          it do
            is_expected.not_to contain_file('/var/run')
          end
        end
      end
    end
  end
end
