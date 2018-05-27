# frozen_string_literal: true

require 'spec_helper'

describe UserFilter do
  describe 'users empty' do
    user_list = UserFilter.new('')

    context 'match?' do
      it { expect(user_list.match?('abcang')).to be_falsey }
      it { expect(user_list.match?('ABCanG1015')).to be_falsey }
    end
  end

  describe 'users are not empty' do
    user_list = UserFilter.new('abcang ABCanG1015')

    context 'match?' do
      it { expect(user_list.match?('ABCanG')).to be_truthy }
      it { expect(user_list.match?('abcang')).to be_truthy }
      it { expect(user_list.match?('ABCanG1015')).to be_truthy }
      it { expect(user_list.match?('abcang1015')).to be_truthy }
      it { expect(user_list.match?('abcang_dummy')).to be_falsey }
    end
  end
end
