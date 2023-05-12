# Planning Notes

## Basic Game Rules / Mechanics

- 2 players where
  - one is code breaker
  - other is code maker
- zero sum game
  - at the end of the game, either breaker or maker wins
  - tie is not possible
- played in rounds with breaker and maker switching roles / side per rounds
- only maker gets points in every round
- player with most points wins after all rounds are played
- code is a permutation of the available set of coloured pegs of a fixed length
  - code can have duplicate colours
- each round starts with maker's turn who must set the secret code

## MVP Requirements

- 1 human player game vs computer player
- 1 round only, no points tracked
- represent colours as integers in range \[1, bound]
- either breaker or maker wins at end of game / round
- code maker role is "passive" once they submit the code
  - game takes care of algorithm for giving feedback to code breaker
    - returns answer based on comparing breaker's guesses against maker's code
    - prevents "cheating" from maker who can lie about feedback
- scenario 1: human = breaker, computer = maker
  - computer set / creates code
  - get input from human as guesses to try to correctly guess the computer's code
- scenario 2: human = maker, computer = breaker
  - human sets / creates code
  - computer runs algorithm to try to guess the code
- game config / constraints
  - guess range for code breaker: \[0, 12]
  - length of code set by code maker: 4
  - set of code components: 6-coloured pegs
    - colours: red, blue, green, yellow, purple, orange
  - can code have duplicate colours: yes
- initial version
  - human is breaker and computer is maker, no choice
- refactored version
  - human chooses to be maker or breaker
  - computer does not choose role directly
  - if computer is code breaker, need algorithm to guess correct code
    - initial algorithm: random
    - if have time, implement backtracking-based algorithm
- console UI "screens"
  - if human player is code maker, prompt for the code
  - display game board as string in console when
    - after code maker sets the code
    - game is waiting for breaker to input a guess
    - after the game is over and either the breaker or maker wins

## Game Logic

- while game is not over
  - if secret code has not been set
    - prompt code maker to enter the code
    - while code entered by code maker is invalid
      - prompt again for a new code
  - display board
  - if code breaker has exceeded the max guess limit (e.g. turn 13 if max guesses is 12)
    - game is over and code maker won
    - display board and winner message
    - break out of / return from outer (game) loop
  - display board and display prompt for user input
  - while true
    - prompt code breaker for input for their guess
    - if guess is invalid, continue loop
    - break out of / return from this inner loop
  - if code breaker's guess matches the secret code,
    - game is over and code breaker won
    - display board and winner message
    - break out of / return from outer (game) loop
  - else code breaker's guess is at most partially correct so provide them with feedback
    - get the number of correctly guessed elements and the number of misplaced elements
    - update the game state with the feedback for the code breaker's guess

## Expanded Game Logic, Data Structures, etc.

- TODO

## UI Design

### Screen Design 1

```
Last Guess and Feedback:
6 1 4 2

✅ 2
❌ 0

The secret code is a 4-length sequence
of any combination of the below choices
that may contain duplicates.

Possible choices: 1, 2, 3, 4, 5, 6
Guesses left: 11
Enter your guess (no spaces):
```

### Screen Design 2

```
[#] 1  2  3  4  5  6  7  8  9  10 11 12

    6  6  6  6  6  6  6  6  6  6  6  6
    1  1  1  1  1  1  1  1  1  1  1  1
    4  4  4  4  4  4  4  4  4  4  4  4
    2  2  2  2  2  2  2  2  2  2  2  2

[x] 2  2  2  2  2  2  2  2  2  2  2  2
[?] 0  0  0  0  0  0  0  0  0  0  0  0

The secret code is a 4-length sequence
of any combination of the below choices
that may contain duplicates.

Possible choices: 1, 2, 3, 4, 5, 6
Guesses left: 11
Enter your guess (no spaces):
```

### Screen Design 3

```
Turn  Guess      OK  x
1     1 2 3 4     0  0
2     1 2 3 4     0  0
3     1 2 3 4     0  0
4     1 2 3 4     0  0
5     1 2 3 4     0  0
6     1 2 3 4     0  0
7     1 2 3 4     0  0
8     1 2 3 4     0  0
9     1 2 3 4     0  0
10    1 2 3 4     0  0
11    1 2 3 4     0  0
12    1 2 3 4     0  0

The secret code is a 4-length sequence
of any combination of the below choices
that may contain duplicates.

Possible choices: 1, 2, 3, 4, 5, 6
Guesses left: 11
Enter your guess (no spaces):
```
