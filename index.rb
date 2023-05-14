require_relative 'classes/index'

game = Game.new(ComputerPlayer, HumanPlayer)
game.play
