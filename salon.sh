#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU() {
  #when calling M_M again, with an arg:
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  #get the available services from db
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  #if there are no services
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo -e "\nThere are no available services"
  else
    #display the services
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED
    #if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then 
      #send to main menu
      MAIN_MENU "That is not a valid service number."
    else
      #check if service id exists
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_NAME ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        #get customer name and check if customer exists in db
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        #if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          #get new customer name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          #insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        fi
        FORMATTED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
        FORMATTED_SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/ |/"/')
        echo -e "\nWhat time would you like your $FORMATTED_SERVICE_NAME, $FORMATTED_CUSTOMER_NAME?"
        read SERVICE_TIME
        #get customer id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$FORMATTED_CUSTOMER_NAME'")
        FORMATTED_CUSTOMER_ID=$(echo $CUSTOMER_ID | sed -r 's/^ *| *$//g')
        # echo -e "\nthe customer id is: $FORMATTED_CUSTOMER_ID"
        # echo -e "\nthe service id is: $SERVICE_ID_SELECTED"
        #insert customer, service and time in appointments table
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($FORMATTED_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $FORMATTED_SERVICE_NAME at $SERVICE_TIME, $FORMATTED_CUSTOMER_NAME."
      fi
    fi
  fi
}
MAIN_MENU
