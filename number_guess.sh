#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=random_game -t --no-align -c"

RANDOM_NUMBER=$((RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

USERINFO=$($PSQL "SELECT name, num_games, num_guesses FROM users WHERE name='$USERNAME'")

if [[ -z $USERINFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name, num_games, num_guesses) VALUES('$USERNAME', 0, 0)")
  NUM_GAMES=0
  NUM_GUESSES=0
else
  IFS="|" read NAME NUM_GAMES NUM_GUESSES <<< "$USERINFO"
  NAME=$(echo "$NAME" | xargs)
  NUM_GAMES=$(echo "$NUM_GAMES" | xargs)
  NUM_GUESSES=$(echo "$NUM_GUESSES" | xargs)

  echo "Welcome back, $NAME! You have played $NUM_GAMES games, and your best game took $NUM_GUESSES guesses."
fi

NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read NUMBER_GUESSED

while [[ ! $NUMBER_GUESSED =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read NUMBER_GUESSED
done

NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

while [[ $NUMBER_GUESSED -ne $RANDOM_NUMBER ]]
do
  if [[ $NUMBER_GUESSED -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi

  read NUMBER_GUESSED

  while [[ ! $NUMBER_GUESSED =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read NUMBER_GUESSED
  done

  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

NEW_NUM_GAMES=$((NUM_GAMES + 1))

if [[ $NUM_GUESSES -eq 0 || $NUMBER_OF_GUESSES -lt $NUM_GUESSES ]]
then
  UPDATE_RESULT=$($PSQL "UPDATE users SET num_games=$NEW_NUM_GAMES, num_guesses=$NUMBER_OF_GUESSES WHERE name='$USERNAME'")
else
  UPDATE_RESULT=$($PSQL "UPDATE users SET num_games=$NEW_NUM_GAMES WHERE name='$USERNAME'")
fi