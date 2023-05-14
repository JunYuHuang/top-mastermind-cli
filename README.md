# Mastermind Console Game

![Gameplay Demo](/assets/mastermind-console-demo.gif)

This is a 1-round console implementation of the classic board game 'Mastermind' that allows you to play as the code breaker against the computer (who is the code maker).

Game parameters:
* The secret code is a sequence of integers in the range \[1, 6]
* Code breaker has up to 12 tries to guess the secret code

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
