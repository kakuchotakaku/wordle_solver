# frozen_string_literal: true

class WordleSolver
  def initialize
    @wordlist_all = File.readlines("./wordlist_all.txt", chomp: true)
    @wordlist_hidden = File.readlines("./wordlist_hidden.txt", chomp: true)
    @letters = ("a".."z").to_a
  end

  def solve
    while !final_answer?
      guessed_word = calc_max_weight_word
      p guessed_word
      STDOUT.flush
      input = gets.chomp.downcase

      reject_words_with_input(guessed_word, input)
    end
    puts "解答は: #{@wordlist_all.first}"
  end

  def letters_with_weight
    @letters_with_weight ||= @wordlist_all.each_with_object({}) do |word, hash|
      new_hash = word.chars.uniq.tally
      hash.merge!(new_hash) { |_key, old_value, new_value| old_value + new_value }
    end
  end

  def calc_max_weight_word
    letters_with_weight.filter! { |letter, _weight| @letters.include?(letter) }
    @wordlist_all.max_by do |word|
      word.chars.uniq.sum { |letter| letters_with_weight[letter] }
    end
  end

  def reject_words_with_input(guessed_word, input)
    actions = guessed_word.chars.zip(input.chars)
    actions.each_with_index do |(letter, action), index|
      case action
      when "b" # black
        @letters.delete(letter)
        @wordlist_all.reject! { |word| word.include?(letter) }
        @wordlist_hidden.reject! { |word| word.include?(letter) }
      when "g" # green
        @wordlist_all.reject! { |word| word[index] != letter }
        @wordlist_hidden.reject! { |word| word[index] != letter }
      when "y" # yellow
        @wordlist_all.reject! { |word| !word.include?(letter) || word[index] == letter }
        @wordlist_hidden.reject! { |word| !word.include?(letter) || word[index] == letter }
      end
    end
  end

  def final_answer?
    number_of_answer_waitlist = 0
    @wordlist_all.each do |word|
      return false if number_of_answer_waitlist > 1
      number_of_answer_waitlist += 1 if @wordlist_hidden.include?(word)
    end
    true
  end
end

WordleSolver.new.solve







#  def auto_solve
  # @results = Hash.new { 0 }
  # @wordlist_hidden.each do |word|
  #   WordleSolver.new.auto_solver(word)
  # end
  # p @results.sort.to_h
  # end

  # def auto_solver(word)
  # guesses = 0
  # while !final_answer?
  #   guesses += 1
  #   guessed_word = calc_max_weight_word
  #   p word
  #   p guessed_word
  #   input = guessed_word.chars.map.with_index do |char, index|
  #       if word[index] == char
  #         "g"
  #       elsif word.include?(char)
  #         "y"
  #       else
  #         "_"
  #       end
  #     end
  #   p input.join

  #   reject_words_with_input(guessed_word, input.join)
  # end
  # @results[guesses] += 1
  # end