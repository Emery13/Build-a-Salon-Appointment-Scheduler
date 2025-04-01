#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Expert Coaching Services ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to Expert Coaching Services. What would you like to do?" 

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # display available services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # get customer input for service they want to use
  read SERVICE_ID_SELECTED

  # get the max service id
  MAX_SERVICE_ID=$($PSQL "SELECT MAX(service_id) FROM services")  

  # check if input is a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send back to main menu stating the service doesn't exist
    MAIN_MENU "This input is invalid."
  # compare SERVICE_ID_SELECTED to MAX_SERVICE_ID to see if it exists
  elif [[ SERVICE_ID_SELECTED -gt MAX_SERVICE_ID ]]
  then
    # send back to main menu stating the service doesn't exist
    MAIN_MENU "This service doesn't exist."
  else
    # send to MAKE_APPOINTMENT
    MAKE_APPOINTMENT $SERVICE_ID_SELECTED
  fi
}

MAKE_APPOINTMENT() {
  # ask for customer data
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # check if phone number exists in database
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if the phone number doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # ask for customer's name
    echo -e "\nI don't have a record for that phone number, what's your name??"
    read CUSTOMER_NAME

    # insert customer into customers table
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  # if customer already exists
  else
    # get name from database
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi 

  # ask customer for session time
  echo -e "\nWhat time would you like your coaching session, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # retrieve customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  # insert into appointments table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")
  
  # get service name from service id
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $1")
  
  # output confirmation message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
