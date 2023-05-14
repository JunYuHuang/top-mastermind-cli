require 'set'
require 'io/console'

class Game
  def initialize(player_maker_class, player_breaker_class)
    # config
    @choices = Set.new([1, 2, 3, 4, 5, 6])
    @code_length = 4
    @max_guesses = 12

    # state
    @players = [
      player_maker_class.new(self, :maker),
      player_breaker_class.new(self, :breaker)
    ]
    @guesses = []
    @secret_code = []
    @responses = []
  end

  attr_reader(:choices)
  attr_reader(:code_length)
  attr_reader(:max_guesses)
  attr_reader(:players)
  attr_accessor(:guesses)
  attr_accessor(:secret_code)
  attr_accessor(:responses)

  def play
    # TODO
  end

  def get_player_breaker
    res = @players.select { |player| player.role == :breaker }
    res[0]
  end

  def get_player_maker
    res = @players.select { |player| player.role == :maker }
    res[0]
  end

  def is_secret_code_set?
    return @secret_code.size > 0
  end

  def is_valid_guess?(guess)
    return false if guess.class != String
    return false if guess.size != @code_length

    guess = guess.split("")
    return false if guess.size != @code_length
    guess.each do |piece|
      return false if !@choices.include?(piece.to_i)
    end

    true
  end

  # TODO - has bugs handling certain cases
  def get_response(guess)
    res = { :correct => 0, :misplaced => 0 }

    correct_indices = Set.new
    guess.each_with_index do |value, i|
      if value == @secret_code[i]
        res[:correct] += 1
        correct_indices.add(i)
      end
    end

    misplaced_choices = Set.new
    @secret_code.each_with_index do |value, i|
      next if correct_indices.include?(i)
      misplaced_choices.add(value)
    end

    puts("correct_indices: #{correct_indices.to_a}")
    puts("misplaced_choices: #{misplaced_choices.to_a}")

    guess.each_with_index do |value, i|
      next if correct_indices.include?(i)
      res[:misplaced] += 1 if misplaced_choices.include?(value)
    end

    res
  end

  # converts string `guess` to int array so it can be
  # easily compared against @secret_code
  def parse_guess(guess)
    res = []
    guess.each_char do |char|
      res.push(char.to_i)
    end
    res
  end

  def did_maker_win?
    @guesses.size > @max_guesses
  end

  def did_breaker_win?(code)
    code == @secret_code
  end

  def update_game(guess, response)
    @guesses.push(guess)
    @responses.push(response)
  end

  def clear_console
    $stdout.clear_screen
  end

  def print_board
    res = []
    table_header = ["Try  Guess      OK  x\n"]
    res.push(table_header)

    @max_guesses.times do |i|
      row = []
      tries_cell = "#{i + 1}" + " " * (5 - (i + 1).to_s.size)
      row.push(tries_cell)

      is_in_bounds = i < @guesses.size
      if is_in_bounds
        guess = []
        @guesses[i].each_with_index do |el, i|
          is_last_pos = i == @guesses[i].size - 1
          guess.push(is_last_pos ? el : "#{el} ")
        end
        row.push(guess.join)
        row.push(" " * 4)

        row.push(" " + @responses[i][:correct].to_s)
        row.push("  " + @responses[i][:misplaced].to_s)
      end

      row.push("\n")
      res.push(row.join)
    end

    res.push("\n")
    puts(res.join)
  end

  def print_breaker_prompt(is_valid_input, invalid_input)
    res = [
      "The secret code is a #{@code_length}-length sequence\n",
      "of any combination of the below choices\n",
      "that may contain duplicates\n",
      "\n",
      "Possible choices: #{@choices.to_a}\n",
      "Guess attempts left: #{@max_guesses - @guesses.size}\n",
      "#{is_valid_input ? '' : "'#{invalid_input}' is not a valid guess. Try again.\n"}",
      "Enter your guess (no spaces):"
    ]
    puts(res.join)
  end

  def print_breaker_won
    puts("\nGame ended: Code Breaker(#{get_player_breaker.to_s}) won!")
  end

  def print_maker_won
    puts("\nGame ended: Code Maker(#{get_player_maker.to_s}) won!")
  end
end

class Player
  def initialize(game, role)
    @game = game
    @role = role
  end

  attr_accessor(:game)
  attr_accessor(:role)
end

class HumanPlayer < Player
  @@name = 'Human'

  def to_s
    @@name
  end

  def get_guess
    is_valid = true
    last_input = nil
    while true
      @game.clear_console
      @game.print_board
      @game.print_breaker_prompt(is_valid, last_input)
      guess = gets.chomp
      if @game.is_valid_guess?(guess)
        return @game.parse_guess(guess)
      end
      is_valid = false
      last_input = guess
    end
  end
end

class ComputerPlayer < Player
  @@name = 'Computer'

  def to_s
    @@name
  end

  def get_code
    choices = @game.choices.to_a
    res = []
    prng = Random.new
    @game.code_length.times do |i|
      random_pos = prng.rand(0..choices.size - 1)
      res.push(choices[random_pos])
    end

    res
  end
end
