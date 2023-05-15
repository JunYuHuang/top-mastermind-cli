# Mastermind Console Game

![Gameplay Demo of playing as the code breaker](/assets/mastermind-demo-breaker.gif)

This is a 1-round console implementation of the classic board game 'Mastermind' that allows you to play as the code breaker or as the code maker against the computer bot that will assume the other opposing role.

Game parameters:
* The secret code is a sequence of integers in the range \[1, 6]
* The secret code is of length 4
* The secret code may have duplicate integers or choices.
* Code breaker has up to 12 tries to guess the secret code
* If the computer bot is the code breaker, it uses a random brute force strategy that involves a bit of cheating to guess your secret code.

## Quick Start

### Requirements

- Ruby 3.1.4
- rspec (optional; only for running tests)
### How to run

```bash
ruby index.rb
```

### How to test

```bash
# if not installed already
gem install rspec

cd specs
rspec index_spec.rb
```

## Skills Demonstrated

- OOP Design
- Unit and Integration Testing
- Input validation
- Handling edge cases

## Bonus Demo Recording: Playing as the Code Maker

![Gameplay Demo of playing as the code maker](/assets/mastermind-demo-maker.gif)
