#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

# set the random number
NUMBER=$(( $RANDOM % 1000 + 1 ))
ATTEMPTS=1

# get player username
echo Enter your username:
read USERNAME

# get player data
PLAYER_DATA=$($PSQL "SELECT * FROM player_data WHERE username='$USERNAME'")
# if player not in the database
if [[ -z $PLAYER_DATA ]]
then
  # welcome new player
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # add player to the database
  INSERT_PLAYER_RESULT=$($PSQL "INSERT INTO player_data(username) VALUES('$USERNAME')")
  # set initial variables values
  BEST=""
  PLAYED=0
# else player in the database
else
  # get variable values
  BEST=$(echo $($PSQL "SELECT best_game FROM player_data WHERE username='$USERNAME'") | sed -r 's/ *//')
  PLAYED=$(echo $($PSQL "SELECT games_played FROM player_data WHERE username='$USERNAME'") | sed -r 's/ *//')
   # welcome player
  echo "Welcome back, $USERNAME! You have played $PLAYED games, and your best game took $BEST guesses."
fi

# ask player for the first guess
echo "Guess the secret number between 1 and 1000:"
read GUESS

# run loop until player guesses the number
while [[ 1 ]]
do
  # if input is not an int
  if [[ ! $GUESS =~ ^[0-9]{1,}$ ]]
  then
    # ask for correct input
    echo "That is not an integer, guess again:"
    read GUESS
    # increase attempts
    ATTEMPTS=$(( $ATTEMPTS + 1 ))
  # else if guess is lower than number
  elif [[ $NUMBER > $GUESS ]]
  then
    # print hint 
    echo "It's higher than that, guess again:"
    read GUESS
    # increase attempts
    ATTEMPTS=$(( $ATTEMPTS + 1 ))
  # else if guess is higher than number
  elif [[ $NUMBER < $GUESS ]]
  then
    # print hint
    echo "It's lower than that, guess again:"
    read GUESS
    # increase attempts
    ATTEMPTS=$(( $ATTEMPTS + 1 ))
  # else correct guess
  else
    # print message
    echo "You guessed it in $ATTEMPTS tries. The secret number was $NUMBER. Nice job!"
    # increase number of games played
    PLAYED=$(( $PLAYED + 1 ))
    # if number of attempts is lower than current best or best is null
    if [[ $ATTEMPTS -lt $BEST ]] || [[ -z $BEST ]]
    then
      # update best_game value
      UPDATE_BEST_RESPONSE=$($PSQL "UPDATE player_data SET best_game=$ATTEMPTS WHERE username='$USERNAME'")
    fi
    # update games_played value
    UPDATE_GAMES_RESPONSE=$($PSQL "UPDATE player_data SET games_played=$PLAYED WHERE username='$USERNAME'")
    # break the loop
    break
  fi
done
