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
  - game takes care of algorithm for giving response to code breaker
    - returns answer based on comparing breaker's guesses against maker's code
    - prevents "cheating" from maker who can lie about response
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
  - else code breaker's guess is at most partially correct so provide them with response
    - get the number of correctly guessed elements and the number of misplaced elements
    - update the game state with the response for the code breaker's guess

## Expanded Game Logic, Data Structures, etc.

- `Game` class
  - constructor(player_maker_class, player_breaker_class)
    - @`code_length`: int set to 4
    - @`choices`: set of ints in \[1, 6] that represent the colours red, green, blue, purple, yellow, orange
    - @`max_guesses`: int set to 12
    - @`players`: array of size 2 that holds instances of the players
    - @`secret_code`: int array of size @`code_length` initially set to an empty array
    - @`guesses`: empty 2D int array that stores each guess the code breaker makes per try as an int array
      - 0 <= `guesses.length` <= @`max_guesses`
      - `guesses[i].length` = @`code_length`
    - @`responses`: empty array of hashes that stores the response for each guess submitted by the code breaker
      - `response.length` == @`guesses.length`
      - `response[i]` is a hashmap of 2 keys `:correct` and `misplaced`
        - each key stores an int represent the count of each completely matching (`:correct`) or matching but in wrong order (`:misplaced`) piece / part of the code breaker's code guess
  - play()
    - while true
      - if not `is_secret_code_set?`
        - @`secret_code` = `get_player_maker`.make_code
      - if `did_maker_win?`
        - `clear_console`
        - `print_board`
        - `print_maker_won`
        - return
      - guess = `get_player_breaker`.get_guess
      - if `did_breaker_win(guess)?`
        - `clear_console`
        - `print_board`
        - `print_breaker_won`
        - return
      - update_game(
          guess,
          `get_response(guess)`
        )
  - get_player_breaker()
    - returns the element in @`players` that has the @`role` property of `:breaker`
  - get_player_maker()
    - returns the element in @`players` that has the @`role` property of `:maker`
  - is_secret_code_set?()
    - returns true if @`secret_code` has been set by the code maker else false
  - is_valid_guess?(guess)
    - returns true or false based on if `guess` is a @`code_length`-sized string composed only of any elements in `choices`
    - uses @`choices` to check
  - get_response(guess)
    - assumes `guess` is an int array
    - compares `guess` against @`secret_code` and returns a hashmap of 2 keys (`:correct`, `:misplaced`) that each map to a non-negative int
    - initialise variables
      - hashmap `res` with keys `:correct` and `:misplaced` but mapped to 0
      - empty set `correct_indices`
    - loop thru each el in `guess` by index `i`
      - if `guess[i]` == @`secret_code[i]`,
        - `res[:correct]`++
        - `correct_indices`.add(i)
    - `misplaced_choices` = new set from @`secret_code` but with all elements whose indices are in `correct_indices` filtered out
    - loop thru each el in `guess` by index `i`
      - if `i` is in `correct_indices`, continue
      - if `guess[i]` is in `misplaced_choices`,
        - `res[:misplaced]`++
    - return `res`
  - parse_guess(guess)
    - assumes `guess` is a valid code string
    - returns `guess` but converted as an int array
  - did_maker_win?()
    - returns true if length of @`guesses` > @`max_guesses` else false
  - did_breaker_win?(code)
    - assumes `code` is an int array
    - returns true if `code` matches @`secret_code` exactly else false
  - update_game(guess, response)
    - pushes `parse_guess(guess)` to @`guesses`
    - pushes `response` to @`responses`
  - clear_console()
    - clears the terminal's / conmsole's current output
  - print_board()
    - prints the following 4 x 13 (col x row) table in the terminal / console output:
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
    ```
  - print_breaker_prompt()
    - prints the following in the terminal / console output:
    ```
    The secret code is a 4-lengthed sequence
    of any combination of the below choices
    that may contain duplicates.

    Possible choices: 1, 2, 3, 4, 5, 6
    Guesses attempts left: 11
    Enter your guess (no spaces):
    ```
  - print_invalid_input_message(input)
    - prints `"input" is not a valid guess. Try again.` to the console output

  - print_breaker_won()
    - prints `Game ended: #{get_player_breaker.to_s} won!`
  - print_maker_won()
    - prints `Game ended: #{get_player_maker.to_s} won!`

- `Player` class
  - constructor(game, role)
    - @`game`: ref to instance of `Game` class
    - @`role`: symbol that is either `:maker` or `:breaker`

- `HumanPlayer` class that inherits from `Player` class
  - @@`NAME` = 'Human';
  - to_s()
    - returns @@`NAME`
  - get_guess()
    - while true
      - @`game`.clear_console
      - @`game`.print_board
      - @`game`.print_breaker_prompt
      - input = get input from console read
      - if @`game`.is_valid_guess(input)
        - return @`game`.parse_guess(input)
      - @`game`.print_invalid_input_message

- `ComputerPlayer` class that inherits from `Player` class
  - @@`NAME` = 'Computer';
  - to_s()
    - returns @@`NAME`
  - make_code(game)
    - `options`: gets copy of @`game`.choices as an array
    - initialise empty int array `res`
    - randomly pick and push @`game`.code_length code pieces to `res` to form the secret code
      - use built-in `Random` class and its `rand()` method
    - return `res`

- also possible: wrap all classes above inside a `Mastermind` module

## UI Design

### Screen Design

```
Tries  Guess      OK  x
1      1 2 3 4     0  0
2      1 2 3 4     0  0
3      1 2 3 4     0  0
4      1 2 3 4     0  0
5      1 2 3 4     0  0
6      1 2 3 4     0  0
7      1 2 3 4     0  0
8      1 2 3 4     0  0
9      1 2 3 4     0  0
10     1 2 3 4     0  0
11     1 2 3 4     0  0
12     1 2 3 4     0  0

The secret code is a 4-length sequence
of any combination of the below choices
that may contain duplicates.

Possible choices: 1, 2, 3, 4, 5, 6
Guesses attempts left: 11
Enter your guess (no spaces):
```
