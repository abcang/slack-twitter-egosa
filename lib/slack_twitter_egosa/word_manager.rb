# frozen_string_literal: true

class WordManager
  attr_reader :target, :exclude

  def initialize(words_text)
    @target = []
    @exclude = []

    words_text.to_s.dup.force_encoding('utf-8').split(' ').each do |word|
      if word.start_with?('-')
        exclude << word[1..-1]
      else
        target << word
      end
    end
  end

  def query
    [
      target.join(' OR '),
      exclude.map { |word| "-#{word}" }.join(' ')
    ].join(' ')
  end

  def match?(text)
    match_target?(text) && unmatch_exclude?(text)
  end

  def unmatch?(text)
    !match?(text)
  end

  def match_target?(text)
    !target.empty? && (text =~ /#{target.join('|')}/i ? true : false)
  end

  def unmatch_target?(text)
    !match_target?(text)
  end

  def match_exclude?(text)
    !exclude.empty? && (text =~ /#{exclude.join('|')}/i ? true : false)
  end

  def unmatch_exclude?(text)
    !match_exclude?(text)
  end
end
