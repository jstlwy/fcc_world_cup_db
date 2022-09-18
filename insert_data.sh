#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Delete all current data and reset sequences
TRUNCATE_RESULT=$($PSQL "TRUNCATE teams,games RESTART IDENTITY")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip first line
  if [[ $YEAR = year ]]; then
    continue
  fi

  # Insert both winning and opponent teams into DB
  # if not already present and get IDs

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
  if [[ -z $WINNER_ID ]]; then
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
  fi

  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
  if [[ -z $OPPONENT_ID ]]; then
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
  fi

  # Now that the winner and opponent IDs have been acquired,
  # insert the data for this game
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]; then
    echo "Inserted game: $YEAR $ROUND, $WINNER beat $OPPONENT $WINNER_GOALS to $OPPONENT_GOALS"
  fi
done

