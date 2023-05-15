require_relative 'spec_helper'
require_relative '../classes/index'

RSpec.describe 'Game' do
  describe 'initialize' do
    it "works if called" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expected = {
        :maker => "Computer",
        :breaker => "Human",
        :choices_count => 6
      }
      maker = game.players.select { |player| player.role == :maker }
      breaker = game.players.select { |player| player.role == :breaker }
      res = {
        :maker => maker[0].to_s,
        :breaker => breaker[0].to_s,
        :choices_count => game.choices.size
      }
      expect(expected).to eq(res)
    end
  end

  describe "get_human_player" do
    it "works if called and human player is breaker" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      human = game.get_human_player
      expect(human.to_s).to eq("Human")
      expect(human.role).to eq(:breaker)
    end

    it "works if called and human player is maker" do
      game = Game.new(HumanPlayer, ComputerPlayer)
      human = game.get_human_player
      expect(human.to_s).to eq("Human")
      expect(human.role).to eq(:maker)
    end
  end

  describe 'get_player_breaker' do
    it "works if called and user is breaker" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.get_player_breaker.to_s).to eq("Human")
    end

    it "works if called and computer is breaker" do
      game = Game.new(HumanPlayer, ComputerPlayer)
      expect(game.get_player_breaker.to_s).to eq("Computer")
    end
  end

  describe 'get_player_maker' do
    it "works if called and computer is maker" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.get_player_maker.to_s).to eq("Computer")
    end

    it "works if called and human is maker" do
      game = Game.new(HumanPlayer, ComputerPlayer)
      expect(game.get_player_maker.to_s).to eq("Human")
    end
  end

  describe 'is_valid_role?' do
    it "returns false if called with nil" do
      game = Game.new(HumanPlayer, ComputerPlayer)
      expect(game.is_valid_role?(nil)).to eq(false)
    end

    it "returns false if called with ''" do
      game = Game.new(HumanPlayer, ComputerPlayer)
      expect(game.is_valid_role?('')).to eq(false)
    end

    it "returns true if called with 'BREAKER'" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.is_valid_role?('BREAKER')).to eq(true)
    end

    it "returns true if called with 'maker'" do
      game = Game.new(HumanPlayer, ComputerPlayer)
      expect(game.is_valid_role?('maker')).to eq(true)
    end
  end

  describe "swap_player_roles!" do
    it "works if called and computer is initially maker and human is initially breaker" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      old_maker = game.players[0]
      old_breaker = game.players[1]
      expect(old_maker.role).to eq(:maker)
      expect(old_breaker.role).to eq(:breaker)

      game.swap_player_roles!
      expect(old_maker.role).to eq(:breaker)
      expect(old_breaker.role).to eq(:maker)
    end

    it "works if called and human is initially maker and computer is initially breaker" do
      game = Game.new(HumanPlayer, ComputerPlayer)
      old_maker = game.players[0]
      old_breaker = game.players[1]
      expect(old_maker.role).to eq(:maker)
      expect(old_breaker.role).to eq(:breaker)

      game.swap_player_roles!
      expect(old_maker.role).to eq(:breaker)
      expect(old_breaker.role).to eq(:maker)
    end
  end

  describe 'is_secret_code_set?' do
    it "returns true if it is set" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [1, 2, 3, 4]
      expect(game.is_secret_code_set?).to eq(true)
    end

    it "returns false if it is not set" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.is_secret_code_set?).to eq(false)
    end
  end

  describe "count_code_count" do
    it "returns nil if called if called and secret code's size is not correct" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      res = game.count_secret_code
      expected = nil
      expect(res).to eq(expected)
    end

    it "returns { 1 => 1, 2 => 1, 3 => 1, 4 => 1 } if called and secret code is 1234" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [1, 2, 3, 4]
      res = game.count_secret_code
      expected = { 1 => 1, 2 => 1, 3 => 1, 4 => 1 }
      expect(res).to eq(expected)
    end

    it "returns { 1 => 2, 2 => 1, 5 => 1 } if called and secret code is 1125" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [1, 1, 2, 5]
      res = game.count_secret_code
      expected = { 1 => 2, 2 => 1, 5 => 1 }
      expect(res).to eq(expected)
    end
  end

  describe 'is_valid_guess?' do
    it "returns false if called with an empty string" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.is_valid_guess?('')).to eq(false)
    end

    it "returns false if called with nil" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.is_valid_guess?(nil)).to eq(false)
    end

    it "returns false if called with a string of incorrect size" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.is_valid_guess?('123')).to eq(false)
    end

    it "returns false if called with a string with invalid choices / characters" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.is_valid_guess?('1@24')).to eq(false)
    end

    it "returns true if called with a valid string" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.is_valid_guess?('1234')).to eq(true)
    end
  end

  describe 'get_response' do
    it "returns { correct: 1, misplaced: 0 } if called with [1,1,1,1] and the secret code is [1,2,3,4]" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [1,2,3,4]
      game.secret_code_count = game.count_secret_code
      guess = [1,1,1,1]
      expected = { correct: 1, misplaced: 0 }
      expect(game.get_response(guess)).to eq(expected)
    end

    it "returns { correct: 0, misplaced: 0 } if called with [3,2,4,1] and the secret code is [5,5,5,5]" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [5,5,5,5]
      guess = [3,2,4,1]
      expected = { correct: 0, misplaced: 0 }
      expect(game.get_response(guess)).to eq(expected)
    end

    it "returns { correct: 0, misplaced: 1 } if called with [5,1,5,5] and the secret code is [1,2,2,2]" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [5,1,5,5]
      guess = [1,2,2,2]
      expected = { correct: 0, misplaced: 1 }
      expect(game.get_response(guess)).to eq(expected)
    end

    it "returns { correct: 1, misplaced: 1 } if called with [5,2,3,5] and the secret code is [2,2,2,3]" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [5,2,3,5]
      guess = [2,2,2,3]
      expected = { correct: 1, misplaced: 1 }
      expect(game.get_response(guess)).to eq(expected)
    end

    it "returns { correct: 3, misplaced: 0 } if called with [1,1,1,2] and the secret code is [1,1,2,2]" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [1,1,2,2]
      guess = [1,1,1,2]
      expected = { correct: 3, misplaced: 0 }
      expect(game.get_response(guess)).to eq(expected)
    end

    it "returns { correct: 1, misplaced: 2 } if called with [1,2,1,1] and the secret code is [1,1,2,5]" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [1,1,2,5]
      guess = [1,2,1,1]
      expected = { correct: 1, misplaced: 2 }
      expect(game.get_response(guess)).to eq(expected)
    end
  end

  describe "parse_guess" do
    it "returns [1,2,3,4] if called with '1234'" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.parse_guess("1234")).to eq([1,2,3,4])
    end
  end

  describe "parse_role" do
    it "returns nil if called with 'asa'" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.parse_role('asa')).to eq(nil)
    end

    it "returns :breaker if called with 'BREAker'" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.parse_role('BREAker')).to eq(:breaker)
    end

    it "returns :maker if called with 'maker'" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.parse_role('maker')).to eq(:maker)
    end
  end

  describe 'did_maker_win?' do
    it "returns false if no guess attempts have been made" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.did_maker_win?).to eq(false)
    end

    it "returns true if the maximum of guess attempts have been made" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.guesses = [:fake_guess] * game.max_guesses
      expect(game.did_maker_win?).to eq(true)
    end

    it "returns true if the maximum of guess attempts has been exceeded by 1" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.guesses = [:fake_guess] * (game.max_guesses + 1)
      expect(game.did_maker_win?).to eq(true)
    end
  end

  describe 'did_breaker_win?' do
    it "returns false if called with [1,3,1,1] and the secret code is [1,1,3,1]" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [1,1,3,1]
      expect(game.did_breaker_win?([1,3,1,1])).to eq(false)
    end

    it "returns true if called with [1,1,3,1] and the secret code is [1,1,3,1]" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.secret_code = [1,1,3,1]
      expect(game.did_breaker_win?([1,1,3,1])).to eq(true)
    end
  end

  describe 'update_game' do
    it "works if called" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      initial_state = [game.guesses.size, game.guesses.size]
      expect(initial_state).to eq([0, 0])

      game.update_game(:dummy_guess, :dummy_response)
      final_state = [game.guesses.size, game.guesses.size]
      expect(final_state).to eq([1, 1])
    end
  end
end

RSpec.describe 'ComputerPlayer' do
  describe 'get_code' do
    it "works if called" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      cpu_player = game.get_player_maker
      expect(cpu_player.role).to eq(:maker)
      expect(cpu_player.to_s).to eq("Computer")

      code = cpu_player.get_code
      expect(code.size).to eq(game.code_length)
      code.each do |el|
        expect(game.choices.include?(el)).to eq(true)
      end
    end
  end

  describe 'get_guess' do
    it "works if called" do
      game = Game.new(HumanPlayer, ComputerPlayer)
      game.secret_code = [1, 2, 3, 4]
      cpu_player = game.get_player_breaker
      expect(cpu_player.role).to eq(:breaker)
      expect(cpu_player.to_s).to eq("Computer")

      guess = cpu_player.get_guess
      while guess != game.secret_code
        guess = cpu_player.get_guess
      end
      expect(guess).to eq(game.secret_code)
    end
  end
end
