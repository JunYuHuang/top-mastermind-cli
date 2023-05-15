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
    - implement counting-based algorithm
- console UI "screens"
  - if human player is code maker, prompt for the code
  - display game board as string in console when
    - after code maker sets the code
    - game is waiting for breaker to input a guess
    - after the game is over and either the breaker or maker wins

## Game Logic

- get player role choice (breaker or maker) from human player
- while player choice is invalid
  - prompt again for role choice
- set player roles correctly
  - if human player chose role 'breaker',
    - computer player should have role 'maker
  - else
    - human = 'maker', computer = 'breaker'
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
  - swap_player_roles!()
    - if human player is 'breaker',
      - sets human player's role to 'maker' and computer player's role to 'breaker'
    - else
      - sets human player's role to 'breaker' and computer player's role to 'maker'
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
  - get_code()
    - TODO

- `ComputerPlayer` class that inherits from `Player` class
  - @@`NAME` = 'Computer';
  - to_s()
    - returns @@`NAME`
  - get_code
    - `options`: gets copy of @`game`.choices as an array
    - initialise empty int array `res`
    - randomly pick and push @`game`.code_length code pieces to `res` to form the secret code
      - use built-in `Random` class and its `rand()` method
    - return `res`
  - get_guess(strategy = :random)
    - TODO: uses a particular strategy or algorithm to try to guess the secret code
    - strategy methods to implement
      - random brute force (just use `get_code` method)
      - random but verify and keep correct guess pieces (to implement)
      - random but cheat and keep choices that match in the secret code at the right position
      - Donald Knuth's strategy?
- also possible: wrap all classes above inside a `Mastermind` module

## Computer Player's Code Guessing Strategy Algorithm / Pseudocode

- naive random but counts correct guess parts strategy
- variables
  - `ordered_choices`: @`choices` but converted to an ASC sorted array (i.e. [ 1, 2, 3, 4, 5, 6 ])
  - `count`: hashmap that maps each unique choice (an int) to an int that counts its number of occurrences in the secret code
  - `wrong_positions`: hashmap that maps each unique choice (an int) to a list of ints that each represent the confirmed wrong positions for that choice
  - `right_positions`: hashmap that maps each unique choice (an int) to a list of ints that each represent the confirmed correct position for that choice
  - `OK`: non-negative int that represents how many parts of the guess are in the code and are in the right position
  - `x`: non-negative int that represents how many parts of the gues are in the code but in the wrong position
- keep trying a guess of all of a single choice (e.g. `1111`)
  - note the choice's number of occurrences in `choice_to_count`
    - it's 0 if it is not part of the code, else some int > 0
  - if the choice is part of the code, stop
  - else keep trying
- if found a choice that is in the code,
  - stop the prev strat of brute forcing a code consisting of only a single choice
  - determine the correct position for the choice that is in the code but whose position is unknown
    - choose the next choice that may be part of the code (if in `choice_to_count`, its value > 0)
    - for the next guess, replace one of the positions in the prev guess with this next choice
- evaluate the feedback from the next guess (e.g. `1112`)
  - if `OK` is 0 and `x` is 0:
    - e.g. code = 3521, guess = 1112
    - TODO


### Examples

#### Example 1

```
code = 1125

Try Guess OK x
1   1111   2 0
2   1112   2 1
3   2111   1 1
4   1211   1 2
5   1121   3 0

count = {
  1 : 2,
  2 : 1
}

right_positions = {
  1 : [0, 1],
  2 : [2]
}

wrong_positions = {
  1 : [0, 2, 1, 3],
  2 : [3, 0, 1, 2],
}
```

try #1 findings
- code has two 1's but don't know their correct positions
- for future guesses (try #2+)
  - always keep two 1's somewhere in the guess
  - determine the correct positions for the two 1's
- for next guess (try #2)
  - change a position in try #1's guess to the next value that:
    - may be in code but we haven't ruled out yet by deduction
    - try the value in `ordered_choices` e.g. 2

try #2 findings
- code also has at least one 2 but don't know its correct position
- pos 3 is not the correct position for the 2
  - note this by pushing 3 to the list `wrong_positions[2]`
- code's remaining unique choice / piece
  - cannot be a 1
  - can be a 2, 3, 4, 5, or 6
- for future guesses (try #3+)
  - always keep two 1's and one 2 in the guess
  - determine the correct positions for the two 1's
  - determine the correct position for the 2
- for next guess (try #3)
  - swap the 2's position in the guess while keeping the two 1's

try #3 findings
- code has two 1's and one 2 but dont know all their correct positions
- `OK` is 1 less compared to from try #2 so we know:
  - pos 0 is the correct position for one of two 1's
    - note this by pushing 0 to the list `right_positions\[1]`
  - pos 0 is not the correct position for the 2
    - note this by pushing 2 to the list `wrong_positions[2]`
- for future guesses (try #4+)
  - always keep two 1's and one 2 in the guess
  - determine the correct positions for the two 1's
  - determine the correct position for the 2
- for next guess (try #4)
  - keep the two 1's
    - one of the 1's should be at the confirmed correct pos 0
  - pick a new position for the 2 that hasn't been tried yet (not pos 0 and not pos 3)

try #4 findings
- `OK` stayed the same but `x` increased by 1 (to 2) the same so we know
  - the 2 is not in the correct pos
    - note this down in `wrong_positions[2]`
    - see below: confirm 2's correct pos is 2
  - the 1 that is not at pos 0 (at pos 2 or 3) is not in the correct pos
  - last 1's correct pos cannot be 0 or 2
    - so it must be 1 or 3
- if any `wrong_positions[choice].size` == @`code_length` - 1
  - know by elimination that correct pos for `choice` is whatever choice that is NOT in `wrong_positions[choice]`
  - confirm 2's correct pos is 2
- for future guesses (try #4+)
  - always keep two 1's and one 2 in the guess
  - determine correct pos for remaining 1
- for next guess (try #4)
  - place the 2 at its confirmed correct pos 2
  - keep the two 1's
    - place one 1 at its confirmed correct pos 0

try #5 findings
- `OK` and `x` counts stayed the same so we know

## UI Design

### Screen Design

```
Try    Guess      OK  x
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
