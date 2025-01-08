# frozen_string_literal: true

require 'spec_helper'

describe 'php::extension' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end
      let(:pre_condition) { 'include php' }

      unless facts[:os]['family'] == 'Suse' || facts[:os]['family'] == 'FreeBSD' # FIXME: something is wrong on these
        etcdir =  case facts[:os]['name']
                  when 'Debian'
                    case facts[:os]['release']['major']
                    when '12'
                      '/etc/php/8.2/mods-available'
                    when '11'
                      '/etc/php/7.4/mods-available'
                    when '10'
                      '/etc/php/7.3/mods-available'
                    else
                      '/etc/php5/mods-available'
                    end
                  when 'Ubuntu'
                    case facts[:os]['release']['major']
                    when '24.04'
                      '/etc/php/8.3/mods-available'
                    when '22.04'
                      '/etc/php/8.1/mods-available'
                    when '20.04'
                      '/etc/php/7.4/mods-available'
                    when '18.04'
                      '/etc/php/7.2/mods-available'
                    else
                      '/etc/php5/mods-available'
                    end
                  when 'Archlinux'
                    '/etc/php/conf.d'
                  else
                    '/etc/php.d'
                  end

        context 'installation from repository' do
          let(:title) { 'json' }
          let(:params) do
            {
              package_prefix: 'php5-',
              settings: {
                'test' => 'foo'
              }
            }
          end

          it { is_expected.to contain_package('php5-json') }

          it do
            is_expected.to contain_php__config('json').with(
              file: "#{etcdir}/json.ini",
              config: {
                'extension' => 'json.so',
                'test' => 'foo'
              }
            )
          end
        end

        context 'configure extension without installing a package' do
          let(:title) { 'json' }
          let(:params) do
            {
              provider: 'none',
              settings: {
                'test' => 'foo'
              }
            }
          end

          it do
            is_expected.to contain_php__config('json').with(
              file: "#{etcdir}/json.ini",
              require: nil,
              config: {
                'extension' => 'json.so',
                'test' => 'foo'
              }
            )
          end
        end

        context 'add settings prefix if requested' do
          let(:title) { 'json' }
          let(:params) do
            {
              name: 'json',
              settings_prefix: true,
              settings: {
                'test' => 'foo'
              }
            }
          end

          it do
            is_expected.to contain_php__config('json').with(
              config: {
                'extension' => 'json.so',
                'json.test' => 'foo'
              }
            )
          end
        end

        context 'use specific settings prefix if requested' do
          let(:title) { 'json' }
          let(:params) do
            {
              name: 'json',
              settings_prefix: 'bar',
              settings: {
                'test' => 'foo'
              }
            }
          end

          it do
            is_expected.to contain_php__config('json').with(
              config: {
                'extension' => 'json.so',
                'bar.test' => 'foo'
              }
            )
          end
        end

        context 'extensions can be configured as zend' do
          let(:title) { 'xdebug' }
          let(:params) do
            {
              zend: true
            }
          end

          it { is_expected.to contain_php__config('xdebug').with_config('zend_extension' => 'xdebug.so') }
        end

        if facts[:os]['family'] != 'Archlinux'
          context 'pecl extensions support so_name' do
            let(:title) { 'zendopcache' }
            let(:params) do
              {
                provider: 'pecl',
                zend: true,
                so_name: 'opcache'
              }
            end

            it do
              is_expected.to contain_php__config('zendopcache').with(
                file: "#{etcdir}/opcache.ini",
                config: {
                  'zend_extension' => 'opcache.so'
                }
              )
            end
          end
        end

        if facts[:os]['family'] != 'Archlinux'
          context 'add ini file prefix if requested' do
            let(:title) { 'zendopcache' }
            let(:params) do
              {
                provider: 'pecl',
                zend: true,
                ini_prefix: '10-',
                so_name: 'opcache'
              }
            end

            it do
              is_expected.to contain_php__config('zendopcache').with(
                file: "#{etcdir}/10-opcache.ini",
                config: {
                  'zend_extension' => 'opcache.so'
                }
              )
            end
          end
        end

        if facts[:os]['family'] != 'Archlinux'
          context 'pecl extensions support php_api_version' do
            let(:title) { 'xdebug' }
            let(:params) do
              {
                provider: 'pecl',
                zend: true,
                php_api_version: '20100525'
              }
            end

            it { is_expected.to contain_php__config('xdebug').with_config('zend_extension' => '/usr/lib/php5/20100525/xdebug.so') }
          end
        end

        if facts[:os]['family'] == 'Debian'
          context 'on Debian family' do
            context 'zend extensions call ext_tool_enable' do
              let(:title) { 'xdebug' }
              let(:params) do
                {
                  zend: true
                }
              end

              it { is_expected.to contain_exec('ext_tool_enable_xdebug') }
            end
          end
        end

        case facts[:os]['name']
        when 'Debian'
          context 'on Debian' do
            let(:title) { 'xdebug' }

            it { is_expected.to contain_php__config('xdebug').with_file("#{etcdir}/xdebug.ini") }

            # NOTE: to consider: As of PHP 5.2.0, the JSON extension is bundled and compiled into PHP by default
            # http://php.net/manual/en/json.installation.php
            context 'pecl installation' do
              let(:title) { 'json' }
              let(:params) do
                {
                  provider: 'pecl',
                  header_packages: ['libmemcached-dev'],
                  name: 'nice_name',
                  settings: {
                    'test' => 'foo'
                  }
                }
              end

              it { is_expected.to contain_package('json') }
              it { is_expected.to contain_package('libmemcached-dev') }
              it { is_expected.to contain_package('build-essential') }

              it do
                is_expected.to contain_php__config('json').with(
                  file: "#{etcdir}/nice_name.ini",
                  config: {
                    'extension' => 'nice_name.so',
                    'test' => 'foo'
                  }
                )
              end
            end
          end
        when 'Ubuntu'
          context 'on Ubuntu' do
            context 'do not setup mysql.ini' do
              let(:title) { 'mysql' }
              let(:params) do
                {
                  name: 'mysql'
                }
              end

              it do
                is_expected.to contain_file("#{etcdir}/mysql.ini").with(ensure: 'absent')
              end
            end
          end
        end
      end
    end
  end
end
