# frozen_string_literal: true

require 'spec_helper'

describe 'php', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      php_cli_package = case facts[:os]['name']
                        when 'Debian'
                          case facts[:os]['release']['major']
                          when '12'
                            'php8.2-cli'
                          when '11'
                            'php7.4-cli'
                          when '10'
                            'php7.3-cli'
                          else
                            'php5-cli'
                          end
                        when 'Ubuntu'
                          case facts[:os]['release']['major']
                          when '24.04'
                            'php8.3-cli'
                          when '22.04'
                            'php8.1-cli'
                          when '20.04'
                            'php7.4-cli'
                          when '18.04'
                            'php7.2-cli'
                          else
                            'php5-cli'
                          end
                        end
      php_fpm_package = case facts[:os]['name']
                        when 'Debian'
                          case facts[:os]['release']['major']
                          when '12'
                            'php8.2-fpm'
                          when '11'
                            'php7.4-fpm'
                          when '10'
                            'php7.3-fpm'
                          else
                            'php5-fpm'
                          end
                        when 'Ubuntu'
                          case facts[:os]['release']['major']
                          when '24.04'
                            'php8.3-fpm'
                          when '22.04'
                            'php8.1-fpm'
                          when '20.04'
                            'php7.4-fpm'
                          when '18.04'
                            'php7.2-fpm'
                          else
                            'php5-fpm'
                          end
                        end
      php_dev_package = case facts[:os]['name']
                        when 'Debian'
                          case facts[:os]['release']['major']
                          when '12'
                            'php8.2-dev'
                          when '11'
                            'php7.4-dev'
                          when '10'
                            'php7.3-dev'
                          else
                            'php5-dev'
                          end
                        when 'Ubuntu'
                          case facts[:os]['release']['major']
                          when '24.04'
                            'php8.3-dev'
                          when '22.04'
                            'php8.1-dev'
                          when '20.04'
                            'php7.4-dev'
                          when '18.04'
                            'php7.2-dev'
                          else
                            'php5-dev'
                          end
                        end
      describe 'works without params' do
        it { is_expected.to compile.with_all_deps }
      end

      describe 'when called with no parameters' do
        case facts[:os]['family']
        when 'Suse', 'RedHat', 'CentOS'
          it { is_expected.to contain_class('php::global') }
        end

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.not_to contain_class('php::global') }
          it { is_expected.to contain_class('php::fpm') }
          it { is_expected.to contain_package('php-pear').with_ensure('present') }
          it { is_expected.to contain_class('php::composer') }
          it { is_expected.to contain_package(php_cli_package).with_ensure('present') }
          it { is_expected.to contain_package(php_fpm_package).with_ensure('present') }
          it { is_expected.to contain_package(php_dev_package).with_ensure('present') }
        when 'Suse'
          it { is_expected.to contain_package('php5').with_ensure('present') }
          it { is_expected.to contain_package('php5-devel').with_ensure('present') }
          it { is_expected.to contain_package('php5-pear').with_ensure('present') }
          it { is_expected.not_to contain_package('php5-cli') }
          it { is_expected.not_to contain_package('php5-dev') }
          it { is_expected.not_to contain_package('php-pear') }
        when 'RedHat', 'CentOS'
          it { is_expected.to contain_package('php-cli').with_ensure('present') }
          it { is_expected.to contain_package('php-common').with_ensure('present') }
        end
      end

      describe 'when called with extensions' do
        let(:params) { { extensions: { xml: {} } } }

        it { is_expected.to contain_php__extension('xml').with_ensure('present') }
      end

      describe 'when called with ensure absent and extensions' do
        extensions = { xml: {} }
        let(:params) { { ensure: 'absent', extensions: extensions } }

        it { is_expected.to contain_php__extension('xml').with_ensure('absent') }

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.to contain_package(php_cli_package).with_ensure('absent') }
          it { is_expected.to contain_package(php_fpm_package).with_ensure('absent') }
          it { is_expected.to contain_package(php_dev_package).with_ensure('absent') }
        when 'Suse'
          it { is_expected.to contain_package('php5').with_ensure('absent') }
          it { is_expected.to contain_package('php5-devel').with_ensure('absent') }
        when 'RedHat', 'CentOS'
          it { is_expected.to contain_package('php-cli').with_ensure('absent') }
          it { is_expected.to contain_package('php-common').with_ensure('absent') }
        end
      end

      describe 'when called with package_prefix parameter' do
        package_prefix = 'myphp-'
        let(:params) { { package_prefix: package_prefix } }

        case facts[:os]['family']
        when 'Suse', 'RedHat', 'CentOS'
          it { is_expected.to contain_class('php::global') }
        end

        case facts[:os]['family']
        when 'Debian', 'RedHat', 'CentOS'
          it { is_expected.to contain_package("#{package_prefix}cli").with_ensure('present') }
        end

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.not_to contain_class('php::global') }
          it { is_expected.to contain_class('php::fpm') }
          it { is_expected.to contain_class('php::composer') }
          it { is_expected.to contain_package('php-pear').with_ensure('present') }
          it { is_expected.to contain_package("#{package_prefix}dev").with_ensure('present') }
          it { is_expected.to contain_package("#{package_prefix}fpm").with_ensure('present') }
        when 'Suse'
          it { is_expected.to contain_package('php5').with_ensure('present') }
          it { is_expected.to contain_package("#{package_prefix}devel").with_ensure('present') }
          it { is_expected.to contain_package("#{package_prefix}pear").with_ensure('present') }
          it { is_expected.not_to contain_package("#{package_prefix}cli").with_ensure('present') }
          it { is_expected.not_to contain_package("#{package_prefix}dev") }
          it { is_expected.not_to contain_package('php-pear') }
        when 'RedHat', 'CentOS'
          it { is_expected.to contain_package("#{package_prefix}common").with_ensure('present') }
        end
      end

      describe 'when called with fpm_user parameter' do
        let(:params) { { fpm_user: 'nginx' } }

        it { is_expected.to contain_class('php::fpm').with(user: 'nginx') }
        it { is_expected.to contain_php__fpm__pool('www').with(user: 'nginx') }

        dstfile = case facts[:os]['family']
                  when 'Debian'
                    case facts[:os]['name']
                    when 'Debian'
                      case facts[:os]['release']['major']
                      when '12'
                        '/etc/php/8.2/fpm/pool.d/www.conf'
                      when '11'
                        '/etc/php/7.4/fpm/pool.d/www.conf'
                      when '10'
                        '/etc/php/7.3/fpm/pool.d/www.conf'
                      else
                        '/etc/php5/fpm/pool.d/www.conf'
                      end
                    when 'Ubuntu'
                      case facts[:os]['release']['major']
                      when '24.04'
                        '/etc/php/8.3/fpm/pool.d/www.conf'
                      when '22.04'
                        '/etc/php/8.1/fpm/pool.d/www.conf'
                      when '20.04'
                        '/etc/php/7.4/fpm/pool.d/www.conf'
                      when '18.04'
                        '/etc/php/7.2/fpm/pool.d/www.conf'
                      else
                        '/etc/php5/fpm/pool.d/www.conf'
                      end
                    end
                  when 'Archlinux'
                    '/etc/php/php-fpm.d/www.conf'
                  when 'Suse'
                    '/etc/php5/fpm/pool.d/www.conf'
                  when 'RedHat'
                    '/etc/php-fpm.d/www.conf'
                  when 'FreeBSD'
                    '/usr/local/etc/php-fpm.d/www.conf'
                  end

        it { is_expected.to contain_file(dstfile).with_content(%r{user = nginx}) }
      end

      describe 'when called with fpm_group parameter' do
        let(:params) { { fpm_group: 'nginx' } }

        it { is_expected.to contain_class('php::fpm').with(group: 'nginx') }
        it { is_expected.to contain_php__fpm__pool('www').with(group: 'nginx') }

        dstfile = case facts[:os]['family']
                  when 'Debian'
                    case facts[:os]['name']
                    when 'Debian'
                      case facts[:os]['release']['major']
                      when '12'
                        '/etc/php/8.2/fpm/pool.d/www.conf'
                      when '11'
                        '/etc/php/7.4/fpm/pool.d/www.conf'
                      when '10'
                        '/etc/php/7.3/fpm/pool.d/www.conf'
                      else
                        '/etc/php5/fpm/pool.d/www.conf'
                      end
                    when 'Ubuntu'
                      case facts[:os]['release']['major']
                      when '24.04'
                        '/etc/php/8.3/fpm/pool.d/www.conf'
                      when '22.04'
                        '/etc/php/8.1/fpm/pool.d/www.conf'
                      when '20.04'
                        '/etc/php/7.4/fpm/pool.d/www.conf'
                      when '18.04'
                        '/etc/php/7.2/fpm/pool.d/www.conf'
                      else
                        '/etc/php5/fpm/pool.d/www.conf'
                      end
                    end
                  when 'Archlinux'
                    '/etc/php/php-fpm.d/www.conf'
                  when 'Suse'
                    '/etc/php5/fpm/pool.d/www.conf'
                  when 'RedHat'
                    '/etc/php-fpm.d/www.conf'
                  when 'FreeBSD'
                    '/usr/local/etc/php-fpm.d/www.conf'
                  end

        it { is_expected.to contain_file(dstfile).with_content(%r{group = nginx}) }
      end

      describe 'when called with fpm_log_dir_mode parameter' do
        let(:params) { { fpm_log_dir_mode: '0770' } }

        dstfile = '/var/log/php-fpm/'

        it { is_expected.to contain_file(dstfile).with_mode('0770') }
      end

      describe 'when configured with a pool with apparmor_hat parameter' do
        let(:params) { { fpm_pools: { 'www' => { 'apparmor_hat' => 'www' } } } }

        it { is_expected.to contain_php__fpm__pool('www').with(apparmor_hat: 'www') }

        dstfile = case facts[:os]['family']
                  when 'Debian'
                    case facts[:os]['name']
                    when 'Debian'
                      case facts[:os]['release']['major']
                      when '12'
                        '/etc/php/8.2/fpm/pool.d/www.conf'
                      when '11'
                        '/etc/php/7.4/fpm/pool.d/www.conf'
                      when '10'
                        '/etc/php/7.3/fpm/pool.d/www.conf'
                      else
                        '/etc/php5/fpm/pool.d/www.conf'
                      end
                    when 'Ubuntu'
                      case facts[:os]['release']['major']
                      when '24.04'
                        '/etc/php/8.3/fpm/pool.d/www.conf'
                      when '22.04'
                        '/etc/php/8.1/fpm/pool.d/www.conf'
                      when '20.04'
                        '/etc/php/7.4/fpm/pool.d/www.conf'
                      when '18.04'
                        '/etc/php/7.2/fpm/pool.d/www.conf'
                      else
                        '/etc/php5/fpm/pool.d/www.conf'
                      end
                    end
                  when 'Archlinux'
                    '/etc/php/php-fpm.d/www.conf'
                  when 'Suse'
                    '/etc/php5/fpm/pool.d/www.conf'
                  when 'RedHat'
                    '/etc/php-fpm.d/www.conf'
                  when 'FreeBSD'
                    '/usr/local/etc/php-fpm.d/www.conf'
                  end

        it { is_expected.to contain_file(dstfile).with_content(%r{apparmor_hat = www}) }
      end

      describe 'when fpm is disabled' do
        let(:params) { { fpm: false } }

        it { is_expected.not_to contain_class('php::fpm') }
      end

      describe 'when composer is disabled' do
        let(:params) { { composer: false } }

        it { is_expected.not_to contain_class('php::composer') }
      end

      if facts[:os]['family'] == 'RedHat' || facts[:os]['family'] == 'CentOS' || facts[:os]['name'] == 'Ubuntu' || (facts[:os]['name'] == 'Debian' && facts[:os]['release']['major'].to_i < 12)
        describe 'when called with flavor zend' do
          zendphp_cli_package = case facts[:os]['name']
                                when 'Debian', 'Ubuntu'
                                  'php8.1-zend-cli'
                                when 'RedHat', 'CentOS'
                                  'php81zend-php-cli'
                                end
          zendphp_fpm_package = case facts[:os]['name']
                                when 'Debian', 'Ubuntu'
                                  'php8.1-zend-fpm'
                                when 'RedHat', 'CentOS'
                                  'php81zend-php-fpm'
                                end

          let(:pre_condition) do
            "class {'php::globals':
                      php_version => '8.1',
                      flavor      => 'zend'
            }"
          end

          it { is_expected.to contain_class('zend_common::repo') }
          it { is_expected.to contain_package(zendphp_cli_package).with_ensure('present') }
          it { is_expected.to contain_package(zendphp_fpm_package).with_ensure('present') }
        end
      end

      if facts[:os]['family'] == 'RedHat' || facts[:os]['family'] == 'CentOS'
        describe 'when called with valid settings parameter types' do
          let(:params) do
            {
              'settings' =>
              {
                'PHP/memory_limit' => '300M',
                'PHP/safe_mode_include_dir' => :undef,
                'PHP/error_reporting' => '',
                'PHP/max_execution_time' => 60
              }
            }
          end

          it { is_expected.to contain_php__config__setting('/etc/php.ini: PHP/memory_limit').with_value('300M') }
          it { is_expected.to contain_ini_setting('/etc/php.ini: PHP/safe_mode_include_dir').with_ensure('absent') }
          it { is_expected.to contain_php__config__setting('/etc/php.ini: PHP/error_reporting').with_value('') }
          it { is_expected.to contain_php__config__setting('/etc/php.ini: PHP/max_execution_time').with_value(60) }
        end

        describe 'when called with cli_settings parameter' do
          let(:params) do
            {
              'settings' => { 'PHP/memory_limit' => '300M' },
              'cli_settings' => { 'PHP/memory_limit' => '1000M' }
            }
          end

          it { is_expected.to contain_php__config__setting('/etc/php.ini: PHP/memory_limit').with_value('300M') }
          it { is_expected.to contain_php__config__setting('/etc/php-fpm.ini: PHP/memory_limit').with_value('300M') }
          it { is_expected.to contain_php__config__setting('/etc/php-cli.ini: PHP/memory_limit').with_value('1000M') }
        end

        describe 'when called with global option for rhscl_mode' do
          describe 'when called with mode "remi"' do
            scl_php_version = 'php56'
            rhscl_mode = 'remi'
            let(:pre_condition) do
              "class {'php::globals':
                        php_version => '#{scl_php_version}',
                        rhscl_mode => '#{rhscl_mode}'
              }"
            end
            let(:params) do
              { settings: { 'Date/date.timezone' => 'Europe/Berlin' } }
            end

            it { is_expected.to contain_class('php::global') }
            it { is_expected.to contain_package("#{scl_php_version}-php-cli").with_ensure('present') }
            it { is_expected.to contain_package("#{scl_php_version}-php-common").with_ensure('present') }
            it { is_expected.to contain_php__config('global').with(file: "/etc/opt/#{rhscl_mode}/#{scl_php_version}/php.ini") }
            it { is_expected.not_to contain_php__config('cli') }

            # see: https://github.com/voxpupuli/puppet-php/blob/master/lib/puppet/parser/functions/to_hash_settings.rb
            it { is_expected.to contain_php__config__setting("/etc/opt/#{rhscl_mode}/#{scl_php_version}/php.ini: Date/date.timezone").with_value('Europe/Berlin') }
          end

          describe 'when called with mode "rhscl"' do
            scl_php_version = 'rh-php56'
            rhscl_mode = 'rhscl'
            let(:pre_condition) do
              "class {'php::globals':
                        php_version => '#{scl_php_version}',
                        rhscl_mode => '#{rhscl_mode}'
              }"
            end
            let(:params) do
              { settings: { 'Date/date.timezone' => 'Europe/Berlin' } }
            end

            it { is_expected.to contain_class('php::global') }
            it { is_expected.to contain_package("#{scl_php_version}-php-cli").with_ensure('present') }
            it { is_expected.to contain_package("#{scl_php_version}-php-common").with_ensure('present') }
            it { is_expected.to contain_php__config('global').with(file: "/etc/opt/rh/#{scl_php_version}/php.ini") }
            it { is_expected.to contain_php__config('cli').with(file: "/etc/opt/rh/#{scl_php_version}/php-cli.ini") }
            it { is_expected.to contain_php__config__setting("/etc/opt/rh/#{scl_php_version}/php.ini: Date/date.timezone").with_value('Europe/Berlin') }
          end
        end
      end

      describe 'when called with pool_purge => true and fpm_pools => {}' do
        let(:params) { { pool_purge: true, fpm_pools: {} } }

        it { is_expected.to contain_class('php::fpm').with(pool_purge: true) }
        it { is_expected.not_to contain_php__fpm__pool('www') }
      end
    end
  end
end
