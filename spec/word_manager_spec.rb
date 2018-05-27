# frozen_string_literal: true

require 'spec_helper'

describe WordManager do
  describe 'has exclude words' do
    manager = WordManager.new('ABCanG abcang1015 -@abcang1015')

    context 'has parsed words' do
      it { expect(manager.target).to match_array(%w(ABCanG abcang1015)) }
      it { expect(manager.exclude).to match_array(%w(@abcang1015)) }
    end

    context 'supports uppercase and lowercase' do
      it { expect(manager.match?('ABCanG')).to be_truthy }
      it { expect(manager.match?('abcang')).to be_truthy }
    end

    context 'match?' do
      it { expect(manager.match?('hello')).to be_falsey }
      it { expect(manager.match?('hello abcang1015')).to be_truthy }
      it { expect(manager.match?('hello @abcang1015')).to be_falsey }
      it { expect(manager.match?('hello abcang @abcang1015')).to be_falsey }
    end

    context 'match_target?' do
      it { expect(manager.match_target?('hello')).to be_falsey }
      it { expect(manager.match_target?('hello abcang')).to be_truthy }
      it { expect(manager.match_target?('hello abcang1015')).to be_truthy }
      it { expect(manager.match_target?('hello @abcang1015')).to be_truthy }
      it { expect(manager.match_target?('hello abcang @abcang1015')).to be_truthy }
    end

    context 'match_exclude?' do
      it { expect(manager.match_exclude?('hello')).to be_falsey }
      it { expect(manager.match_exclude?('hello abcang')).to be_falsey }
      it { expect(manager.match_exclude?('hello abcang1015')).to be_falsey }
      it { expect(manager.match_exclude?('hello @abcang1015')).to be_truthy }
      it { expect(manager.match_exclude?('hello abcang @abcang1015')).to be_truthy }
    end
  end
end

describe 'does not have exclude words' do
  manager = WordManager.new('abcang abcang1015')

  it 'has parsed words' do
    expect(manager.target).to match_array(%w(abcang abcang1015))
    expect(manager.exclude).to match_array([])
  end

  context 'match?' do
    it { expect(manager.match?('hello')).to be_falsey }
    it { expect(manager.match?('hello abcang')).to be_truthy }
    it { expect(manager.match?('hello abcang1015')).to be_truthy }
    it { expect(manager.match?('hello @abcang1015')).to be_truthy }
  end

  context 'match_target?' do
    it { expect(manager.match_target?('hello')).to be_falsey }
    it { expect(manager.match_target?('hello abcang')).to be_truthy }
    it { expect(manager.match_target?('hello abcang1015')).to be_truthy }
    it { expect(manager.match_target?('hello @abcang1015')).to be_truthy }
  end

  context 'match_exclude?' do
    it { expect(manager.match_exclude?('hello')).to be_falsey }
    it { expect(manager.match_exclude?('hello abcang')).to be_falsey }
    it { expect(manager.match_exclude?('hello abcang1015')).to be_falsey }
    it { expect(manager.match_exclude?('hello @abcang1015')).to be_falsey }
  end
end
