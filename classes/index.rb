require 'set'

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
    @secret_code_count = {}
    @responses = []
  end

  attr_reader(:choices)
  attr_reader(:code_length)
  attr_accessor(:max_guesses)
  attr_reader(:players)
  attr_accessor(:guesses)
  attr_accessor(:secret_code_count)
  attr_accessor(:secret_code)
  attr_accessor(:responses)

  def play
    while true
      if !is_secret_code_set?
        @secret_code = get_player_maker.get_code
        @secret_code_count = count_secret_code
      end
      if did_maker_win?
        clear_console
        print_board
        print_maker_won
        print_secret_code
        return
      end
      guess = get_player_breaker.get_guess
      update_game(guess, get_response(guess))
      if did_breaker_win?(guess)
        clear_console
        print_board
        print_breaker_won
        print_secret_code
        return
      end
    end
  end

  def get_human_player
    res = @players.select { |player| player.to_s == "Human" }
    res[0]
  end

  def get_player_breaker
    res = @players.select { |player| player.role == :breaker }
    res[0]
  end

  def get_player_maker
    res = @players.select { |player| player.role == :maker }
    res[0]
  end

  def is_valid_role?(role)
    return false if role.class != String
    role = role.downcase
    role == "breaker" || role == "maker"
  end

  def swap_player_roles!
    old_breaker = get_player_breaker
    old_maker = get_player_maker
    old_breaker.role = :maker
    old_maker.role = :breaker
    nil
  end

  def is_secret_code_set?
    return @secret_code.size > 0
  end

  def count_secret_code
    return nil if @secret_code.size != @code_length
    res = {}
    @secret_code.each do |choice|
      res[choice] = res.fetch(choice, 0) + 1
    end
    res
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

  def get_response(guess)
    count_copy = @secret_code_count.size == 0 ? count_secret_code : {}.replace(@secret_code_count)
    res = { :correct => 0, :misplaced => 0 }

    correct_indices = Set.new
    guess.each_with_index do |value, i|
      if value == @secret_code[i]
        res[:correct] += 1
        correct_indices.add(i)
        count_copy[value] -= 1
      end
    end

    guess.each_with_index do |value, i|
      next if correct_indices.include?(i)
      if count_copy.fetch(value, 0) > 0
        res[:misplaced] += 1
        count_copy[value] -= 1
      end
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
    @guesses.size >= @max_guesses
  end

  def did_breaker_win?(code)
    code == @secret_code
  end

  def update_game(guess, response)
    @guesses.push(guess)
    @responses.push(response)
  end

  def clear_console
    if RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
      system('cls')
    else
      system('clear')
    end
  end

  def print_board
    res = []
    table_header = ["Try  Guess      OK  x\n"]
    res.push(table_header)

    @max_guesses.times do |row_pos|
      row = []
      tries_cell = "#{row_pos + 1}" + " " * (5 - (row_pos + 1).to_s.size)
      row.push(tries_cell)

      is_in_bounds = row_pos < @guesses.size
      if is_in_bounds
        guess = []
        @guesses[row_pos].each_with_index do |el, i|
          is_last_pos = i == @code_length - 1
          guess.push(is_last_pos ? el : "#{el} ")
        end
        row.push(guess.join)
        row.push(" " * 4)

        row.push(" " + @responses[row_pos][:correct].to_s)
        row.push("  " + @responses[row_pos][:misplaced].to_s)
      end

      row.push("\n")
      res.push(row.join)
    end

    res.push("\n")
    puts(res.join)
  end

  def print_breaker_prompt(is_valid_input, invalid_input)
    choices = @choices.to_a.to_s.slice(1, @choices.to_a.to_s.size - 2)
    res = [
      "The secret code is a #{@code_length}-sized sequence\n",
      "of any combination of the below choices\n",
      "that may contain duplicates\n",
      "\n",
      "Possible choices: #{choices}\n",
      "Guess attempts left: #{@max_guesses - @guesses.size}\n",
      "#{is_valid_input ? '' : "'#{invalid_input}' is not a valid guess. Try again.\n"}",
      "Enter your guess (no spaces):"
    ]
    puts(res.join)
  end

  def print_maker_prompt(is_valid_input, invalid_input)
    choices = @choices.to_a.to_s.slice(1, @choices.to_a.to_s.size - 2)
    res = [
      "Set a #{@code_length}-sized secret code sequence\n",
      "of any combination of the below choices\n",
      "that may contain duplicates\n",
      "\n",
      "Possible choices: #{choices}\n",
      "#{is_valid_input ? '' : "'#{invalid_input}' is not a valid secret code. Try again.\n"}",
      "Enter your secret code (no spaces):"
    ]
    puts(res.join)
  end

  def print_breaker_won
    puts("Game ended: #{get_player_breaker.to_s}(Code Breaker) won!\n")
  end

  def print_maker_won
    puts("Game ended: #{get_player_maker.to_s}(Code Maker) won!\n")
  end

  def print_secret_code
    code = @secret_code.map { |char| char }
    puts("#{get_player_maker.to_s}(Code Maker)'s secret code was #{code.join}\n")
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

  def get_code
    is_valid = true
    last_input = nil
    while true
      @game.clear_console
      @game.print_maker_prompt(is_valid, last_input)
      code = gets.chomp
      if @game.is_valid_guess?(code)
        return @game.parse_guess(code)
      end
      is_valid = false
      last_input = code
    end
  end
end

class ComputerPlayer < Player
  @@name = 'Computer'

  def initialize(game, role)
    super(game, role)
    @correct_guess_positions = {}
  end

  attr_accessor(:correct_guess_positions)

  def to_s
    @@name
  end

  def get_code
    res = []
    @game.code_length.times do |i|
      res.push(get_random_choice)
    end

    res
  end

  # uses a random brute force + cheating strategy
  # to guess the secret code
  def get_guess
    guess = get_code
    guess.each_index do |i|
      if guess[i] == @game.secret_code[i]
        @correct_guess_positions[i] = guess[i]
      end
    end

    @correct_guess_positions.each do |pos, val|
      guess[pos] = val
    end

    guess
  end

  def get_random_choice
    choices = @game.choices.to_a
    random_pos = Random.new.rand(0..choices.size - 1)
    choices[random_pos]
  end
end
