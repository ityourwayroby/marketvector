#!/bin/bash

# Database connection parameters
DB_NAME="test_database"           # Replace with your actual database name
DB_USER="postgres"                # Replace with your actual database username
DB_PASS="admin12345$"             # Replace with your actual database password
DB_HOST="test-database.cfouo2oco23b.us-east-1.rds.amazonaws.com" # RDS endpoint
DB_PORT="5432"                    # Default PostgreSQL port

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
        
        # Insert user information into the database
        INSERT_RESULT=$(PGPASSWORD=$DB_PASS psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -p "$DB_PORT" -t -c "
        INSERT INTO users (email, first_name, last_name, password)
        VALUES ('$EMAIL', '$FIRST_NAME', '$LAST_NAME', '$PASSWORD');
        ")

        if [ $? -eq 0 ]; then
            echo "User registered successfully!"
        else
            echo "Failed to register user. Please try again."
        fi

        exit 0
    else
        echo "Passwords do not match. Please try again."
        attempt=$((attempt + 1))
    fi
done

echo "Too many attempts. Please try again later."
