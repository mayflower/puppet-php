# frozen_string_literal: true

require 'spec_helper'

describe 'php::composer', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end
      let(:pre_condition) { 'class {"php": composer => false}' }

      describe 'works without params' do
        it { is_expected.to compile.with_all_deps }
      end

      describe 'when called with no parameters' do
        it { is_expected.to contain_file('/usr/local/bin/composer') }
      end
    end
  end
end
