# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'php with default settings' do
  context 'default parameters' do
    it 'works with defaults' do
      pp = 'include php'
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    packagename = case default[:platform]
                  when %r{ubuntu-20.04}, %r{debian-11}
                    'php7.4-fpm'
                  when %r{ubuntu-22.04}
                    'php8.1-fpm'
                  when %r{ubuntu-24.04}
                    'php8.3-fpm'
                  when %r{ubuntu-18.04}
                    'php7.2-fpm'
                  when %r{debian-10}
                    'php7.3-fpm'
                  when %r{debian-12}
                    'php8.2-fpm'
                  else
                    'php-fpm'
                  end
    describe package(packagename) do
      it { is_expected.to be_installed }
    end

    describe service(packagename) do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end

  context 'default parameters with extensions' do
    case default[:platform]
    when %r{ubuntu-24.04}, %r{ubuntu-22.04}, %r{ubuntu-20.04}, %r{ubuntu-18.04}
      it 'works with defaults' do
        case default[:platform]
        when %r{ubuntu-24.04}
          simplexmlpackagename = 'php8.3-xml'
        when %r{ubuntu-22.04}
          simplexmlpackagename = 'php8.1-xml'
        when %r{ubuntu-20.04}
          simplexmlpackagename = 'php7.4-xml'
        when %r{ubuntu-18.04}
          simplexmlpackagename = 'php7.2-xml'
        end
        pp = <<-EOS
        class{ 'php':
          extensions => {
            'intl'     => {},
            'gd'       => {},
            'net-url'  => {
              package_prefix => 'php-',
            },
            'simplexml'  => {
              package_name => '#{simplexmlpackagename}',
            }
          }
        }
        EOS
        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end
    else
      it 'works with defaults' do
        pp = <<-EOS
        class{ 'php':
          extensions => {
            'intl'     => {},
            'gd'       => {}
          }
        }
        EOS
        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end
    end

    packagename = case default[:platform]
                  when %r{ubuntu-20.04}, %r{debian-11}
                    'php7.4-fpm'
                  when %r{ubuntu-22.04}
                    'php8.1-fpm'
                  when %r{ubuntu-24.04}
                    'php8.3-fpm'
                  when %r{ubuntu-18.04}
                    'php7.2-fpm'
                  when %r{debian-10}
                    'php7.3-fpm'
                  when %r{debian-12}
                    'php8.2-fpm'
                  else
                    'php-fpm'
                  end
    describe package(packagename) do
      it { is_expected.to be_installed }
    end

    describe service(packagename) do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end
end
