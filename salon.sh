#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

MAIN_MENU() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo "I could not find that service. What would you like today?"
    MAIN_MENU
    return
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    echo "I could not find that service. What would you like today?"
    MAIN_MENU
    return
  fi
  
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  SAFE_PHONE=${CUSTOMER_PHONE//\'/\'\'}

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$SAFE_PHONE'")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$SAFE_PHONE'")

  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    SAFE_NAME=${CUSTOMER_NAME//\'/\'\'}

    $PSQL "INSERT INTO customers(phone, name) VALUES('$SAFE_PHONE', '$SAFE_NAME')" > /dev/null
    
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$SAFE_PHONE'")
  fi

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME


  SAFE_TIME=${SERVICE_TIME//\'/\'\'}
  
  if $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SAFE_TIME')" > /dev/null
  then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
  echo "Sorry, your appointment could not be scheduled."
fi
}

MAIN_MENU