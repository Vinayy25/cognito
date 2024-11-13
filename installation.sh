#!/bin/bash

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install necessary services
echo "Installing necessary services..."

# Install nginx
echo "Installing nginx..."
sudo apt-get install -y nginx

# Configure Nginx
echo "Configuring Nginx..."
sudo bash -c 'cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 80;
    server_name cognito.fun www.cognito.fun;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# Test and reload Nginx
echo "Testing and reloading Nginx..."
sudo nginx -t && sudo systemctl reload nginx

# Install Git
echo "Installing Git..."
sudo apt-get install -y git

# Install Python 3 and pip
echo "Installing Python 3 and pip..."
sudo apt-get install -y python3 python3-pip

# Install Ngrok
echo "Installing Ngrok..."
# Assuming you have a method to install Ngrok, as it might require manual download

# Install Redis
echo "Installing Redis..."
sudo apt-get install -y redis-server

# Start and enable Redis
echo "Starting and enabling Redis..."
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Verify Redis installation
echo "Verifying Redis installation..."
if redis-cli ping | grep -q "PONG"; then
    echo "Redis is running correctly."
else
    echo "Redis is not running correctly. Please check the installation."
    exit 1
fi

# Install Flutter SDK
echo "Installing Flutter SDK..."
# Assuming you have a method to install Flutter, as it might require manual setup

# Install tmux
echo "Installing tmux..."
sudo apt-get install -y tmux

# Start and enable nginx
echo "Starting and enabling nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Python packages from requirements.txt
echo "Installing Python packages from requirements.txt..."
pip3 install -r requirements.txt

# Install Uvicorn
echo "Installing Uvicorn..."
pip3 install uvicorn

# Start a tmux session and run the server
echo "Starting a tmux session and running the server..."
tmux new -d -s my_session 'cd cognito && sh start.sh'

echo "All necessary services have been installed and started successfully."
