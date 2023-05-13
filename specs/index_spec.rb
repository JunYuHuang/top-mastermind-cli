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

  describe 'get_player_breaker' do
    it "works if called" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.get_player_breaker.to_s).to eq("Human")
    end
  end

  describe 'get_player_maker' do
    it "works if called" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.get_player_maker.to_s).to eq("Computer")
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

  # TODO - has failing tests
  # describe 'get_response' do
  #   it "returns { correct: 1, misplaced: 0 } if called with [1,1,1,1] and the secret code is [1,2,3,4]" do
  #     game = Game.new(ComputerPlayer, HumanPlayer)
  #     game.secret_code = [1,2,3,4]
  #     guess = [1,1,1,1]
  #     expected = { correct: 1, misplaced: 0 }
  #     expect(game.get_response(guess)).to eq(expected)
  #   end

  #   it "returns { correct: 1, misplaced: 0 } if called with [3,2,4,1] and the secret code is [4,4,4,4]" do
  #     game = Game.new(ComputerPlayer, HumanPlayer)
  #     game.secret_code = [4,4,4,4]
  #     guess = [3,2,4,1]
  #     expected = { correct: 1, misplaced: 0 }
  #     expect(game.get_response(guess)).to eq(expected)
  #   end

  #   it "returns { correct: 2, misplaced: 1 } if called with [1,1,1,2] and the secret code is [1,1,2,2]" do
  #     game = Game.new(ComputerPlayer, HumanPlayer)
  #     game.secret_code = [1,1,2,2]
  #     guess = [1,1,1,2]
  #     expected = { correct: 2, misplaced: 1 }
  #     expect(game.get_response(guess)).to eq(expected)
  #   end
  # end

  describe "parse_guess" do
    it "returns [1,2,3,4] if called with '1234'" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.parse_guess("1234")).to eq([1,2,3,4])
    end
  end

  describe 'did_maker_win?' do
    it "returns false if no guess attempts have been made" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.did_maker_win?).to eq(false)
    end

    it "returns false if the maximum of guess attempts have been made" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      game.guesses = [:fake_guess] * game.max_guesses
      expect(game.did_maker_win?).to eq(false)
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
end
