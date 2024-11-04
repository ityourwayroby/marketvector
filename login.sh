#!/bin/bash

# Database connection parameters
DB_NAME="test_database"
DB_USER="root"
DB_PASS="admin1234"
DB_HOST="192.168.56.102"  # IP of the database-server
DB_PORT="3306"

# Maximum number of attempts
MAX_ATTEMPTS=3

# Time to wait before allowing another login attempt (in seconds)
LOCKOUT_TIME=300

# Initialize attempt counter
attempt=1

while [ $attempt -le $MAX_ATTEMPTS ]; do
    # Prompt for user credentials
    echo "Login Attempt #$attempt"
    read -p "Enter your email: " EMAIL

    # Prompt for password without showing it on the screen
    echo "Enter your password:"
    read -s -p "Password: " PASSWORD
    echo

    # Authenticate user
    AUTH_RESULT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -N -B -e "
    SELECT COUNT(*)
    FROM users
    WHERE email = '$EMAIL' AND password = '$PASSWORD';
    ")

    # Trim leading and trailing whitespaces from the result
    AUTH_RESULT=$(echo "$AUTH_RESULT" | xargs)

    if [ "$AUTH_RESULT" -eq 1 ]; then
        echo "Login successful!"
        exit 0
    else
        if [ $attempt -lt $MAX_ATTEMPTS ]; then
            echo "Invalid email or password. Please try again."
        else
            echo "Your login has been locked. Try again in 5 minutes."
            sleep $LOCKOUT_TIME
        fi
    fi

    attempt=$((attempt + 1))
done
