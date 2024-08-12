#!/bin/bash

# Database connection parameters
DB_NAME="test_database"
DB_USER="postgres"
DB_PASS="admin1234"
DB_HOST="localhost"
DB_PORT="5432"

# Prompt for user information
echo "Welcome To ItYourWay"
sleep 3
echo "Click here to Sign Up"
sleep 3
read -p "Enter your email: " EMAIL
read -p "Enter your first name: " FIRST_NAME
read -p "Enter your last name: " LAST_NAME

# Loop to allow up to 3 attempts for password matching
attempt=1
while [ $attempt -le 3 ]; do
    echo "Enter your password:"
    read -s -p "Password: " PASSWORD
    echo

    echo "Confirm your password:"
    read -s -p "Confirm Password: " CONFIRM_PASSWORD
    echo

    # Check if passwords match
    if [ "$PASSWORD" == "$CONFIRM_PASSWORD" ]; then
        echo "Passwords match."
        break
    else
        echo "Passwords do not match. Please try again."
        attempt=$((attempt + 1))
    fi

    # Check if max attempts are reached
    if [ $attempt -gt 3 ]; then
        echo "Maximum attempts reached. Exiting."
        exit 1
    fi
done

# Debugging output to verify input values
echo "Attempting to insert the following data:"
echo "Email: $EMAIL"
echo "First Name: $FIRST_NAME"
echo "Last Name: $LAST_NAME"
echo "Password: $PASSWORD"

# Insert the user information into the table
PGPASSWORD=$DB_PASS psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
INSERT INTO users (email, first_name, last_name, password)
VALUES ('$EMAIL', '$FIRST_NAME', '$LAST_NAME', '$PASSWORD');
" || { echo "Error inserting data"; exit 1; }

echo "Sign up successful!"

# Check the inserted data
PGPASSWORD=$DB_PASS psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT * FROM users;"
