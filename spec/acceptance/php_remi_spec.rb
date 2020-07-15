require 'spec_helper_acceptance'

describe 'php with remi repo' do
  context 'default parameters' do
    it 'works with defaults' do
      pp = <<-EOS
      class { 'php::globals':
        rhscl_mode => 'remi',
      }
      -> class { 'php':
        manage_repos => true,
      }
      EOS
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    packagename = 'php56-php-fpm'
    describe package(packagename) do
      it { is_expected.to be_installed }
    end

    describe service(packagename) do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end
end
