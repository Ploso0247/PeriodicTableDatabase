#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  INPUT=$1
  AT_NUM=$($PSQL "select * from elements where atomic_number = $INPUT" 2>/dev/null)
  SYMBOL=$($PSQL "select * from elements where symbol = '$INPUT'" 2>/dev/null)
  NAME=$($PSQL "select * from elements where name = '$INPUT'" 2>/dev/null)
  if [[ -n $AT_NUM ]]
  then
    IFS='|' read -r atomic_number symbol name <<< "$AT_NUM"
  elif [[ -n $SYMBOL ]]
  then
    IFS='|' read -r atomic_number symbol name <<< "$SYMBOL"
  elif [[ -n $NAME ]]
  then
    IFS='|' read -r atomic_number symbol name <<< "$NAME"
  else
    echo "I could not find that element in the database."
    exit
  fi
  ELEMENTDATA=$($PSQL "select melting_point_celsius, boiling_point_celsius, type_id, atomic_mass from properties where atomic_number = $atomic_number")
  IFS='|' read -r melting boiling type_id mass <<< "$ELEMENTDATA"
  TYPE=$($PSQL "select type from types where type_id = '$type_id'")
  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $TYPE, with a mass of $mass amu. $name has a melting point of $melting celsius and a boiling point of $boiling celsius."
fi
