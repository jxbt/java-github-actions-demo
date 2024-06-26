#!/bin/bash

# Define the directories
APP_DIR="$HOME/javavulny"
BUILD_DIR="$HOME/app"

# Step 1: Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Step 2: Set Up PostgreSQL
echo "Setting up PostgreSQL..."
sudo -u postgres psql << EOF
CREATE DATABASE postgresql;
CREATE USER postgresql WITH PASSWORD 'postgresql';
ALTER ROLE postgresql SET client_encoding TO 'utf8';
ALTER ROLE postgresql SET default_transaction_isolation TO 'read committed';
ALTER ROLE postgresql SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE postgresql TO postgresql;
EOF

# Step 3: Install OpenJDK 11 Slim
echo "Installing OpenJDK 11 Slim..."
sudo apt install -y openjdk-11-jdk-headless

# Step 4: Set Environment Variable
echo "Setting environment variable..."
export SPRING_PROFILES_ACTIVE=postgresql

# Step 5: Set Up Your Application
echo "Setting up application directories..."
mkdir -p "$APP_DIR" "$BUILD_DIR"
echo "Copying application files..."
cp -r ./* "$APP_DIR/"

# Step 6: Modify Configuration
echo "Modifying PostgreSQL configuration..."
sed -i 's/localhost:5432/db:5432/' "$APP_DIR/src/main/resources/application.yaml"

# Step 7: Build Your Application
echo "Building application..."
cd "$APP_DIR"
./gradlew --no-daemon clean build --stacktrace
cp build/libs/java-spring-vuly-0.2.0.jar "$BUILD_DIR/"
rm -Rf build/ "$APP_DIR" /root/.gradle/

# Step 8: Run Your Application in the Background
echo "Running application in the background..."
cd "$BUILD_DIR"
nohup java -Djava.security.egd=file:/dev/./urandom -jar java-spring-vuly-0.2.0.jar > app.log 2>&1 &

echo "Application is running in the background. Check app.log for output."
