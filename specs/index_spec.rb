require_relative 'spec_helper'
require_relative '../classes/index'

RSpec.describe 'Game' do
  describe 'initialize()' do
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
      expect(res).to eq(expected)
    end
  end

  # TODO
end
