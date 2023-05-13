require_relative 'spec_helper'
require_relative '../classes/index'

RSpec.describe 'Game' do
  describe 'initialize' do
    it "works" do
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
    it "works" do
      game = Game.new(ComputerPlayer, HumanPlayer)
      expect(game.get_player_breaker.to_s).to eq("Human")
    end
  end

  describe 'get_player_maker' do
    it "works" do
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
end
