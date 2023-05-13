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
    @feedback = []
  end

  attr_reader(:choices)
  attr_reader(:code_length)
  attr_reader(:max_guesses)
  attr_reader(:players)
  attr_accessor(:guesses)
  attr_accessor(:secret_code)
  attr_accessor(:feedback)

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

  def get_feedback(guess)
    # TODO
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
    # TODO
  end
end

class ComputerPlayer < Player
  @@name = 'Computer'

  def to_s
    @@name
  end

  def make_code
    # TODO
  end
end
