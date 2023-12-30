#!/usr/bin/env bash

OS=$(cat /etc/*release | grep ^NAME)
PKG_MAN=""
MOTD=""
USERS=""
MTU=""
LOG_LEVEL=""
LOG_DRIVER=""


# Find the operating system (Ubuntu, Arch or CentOS)
if [[ $OS == *Ubuntu* ]]; then
    PKG_MAN="apt"
    echo "Ubuntu"
    echo "Package manager: $PKG_MAN"
elif [[ $OS == *Arch* ]]; then
    PKG_MAN="pacman"
    echo "Arch"
    echo "Package manager: $PKG_MAN"
elif [[ $OS == *Cent* ]]; then
    PKG_MAN="dnf"
    echo "CentOS"
    echo "Package manager: $PKG_MAN"
else echo "No distribution found"
fi

# Install docker and docker-compose
if [[ $PKG_MAN == "apt" ]]; then    # UBUNTU
    echo "Removing old versions of docker..."
    sudo apt-get remove -y docker docker-engine docker.io containerd runc
    # Set up the repository to allow apt to install docker
    echo "Setting up repository..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    echo "Installing docker and docker-compose..."
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo "Docker and docker-compose installed"
elif [[ $PKG_MAN == "pacman" ]]; then   # ARCH
    # Update the Pacman database
    sudo pacman -Syy --noconfirm
    echo "Installing docker and docker-compose..."
    sudo pacman -S --noconfirm docker docker-compose
    echo "Docker and docker-compose installed"
elif [[ $PKG_MAN == "dnf" ]]; then  # CENTOS
    # Install dnf in case it's not installed (older systems use yum)
    sudo yum install -y dnf dnf-plugins-core
    echo "Removing old versions of docker..."
    sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate \
                  docker-logrotate docker-engine
    echo "Setting up repository..."
    sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
    echo "Installing docker and docker-compose..."
    sudo dnf install --refresh -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl start docker
    echo "Docker and docker-compose installed"
else echo "No package manager found"
fi

# Parsing the command line arguments
while [ "$1" != "" ]; do    # Loop if first argument is not empty (i.e. there are arguments)
  case $1 in
    --motd ) shift  # This shifts to the next argument if the first argument is --motd
    MOTD=$1        # Set the MOTD to the "second" argument
    ;;
    --mtu ) shift   # Parse the MTU if the first argument is --mtu
    MTU=$1
    ;;
    --log-level ) shift  # Parse the log level if the first argument is --log-level
    LOG_LEVEL=$1
    ;;
    --log-driver ) shift # Parse the log driver if the first argument is --log-driver
    LOG_DRIVER=$1
    ;;
    * ) USERS="$USERS $1"   # Parse the rest of the arguments as users
    ;;
  esac 
  shift  # Shift to next argument
done

# If the MOTD is set, update in /etc/motd
if [ -n "$MOTD" ]; then
  echo "$MOTD" | sudo tee /etc/motd > /dev/null
  sudo chmod 644 /etc/motd
fi

# If the list of users is set, create the users and add them to the docker group
if [ -n "$USERS" ]; then
  for USER in $USERS; do
    sudo useradd "$USER"
    sudo usermod -aG docker "$USER"
  done
fi

# If the MTU value is set, update the Docker Daemon configuration
if [ -n "$MTU" ]; then
  sudo sed -i '/mtu/d' /etc/docker/daemon.json  # Removes existing mtu line
  sudo echo '{"mtu": '$MTU'}' | sudo tee -a /etc/docker/daemon.json > /dev/null
  sudo service docker restart
fi

# If the log level is set, update the Docker Daemon configuration
if [ -n "$LOG_LEVEL" ]; then
    if [[ "$LOG_LEVEL" =~ ^(debug|info|warn|error|fatal)$ ]]; then # Check if the log level is valid
        sudo sed -i '/log-level/d' /etc/docker/daemon.json  # Removes existing log-level line
        sudo echo '{"log-level": "'$LOG_LEVEL'"}' | sudo tee -a /etc/docker/daemon.json > /dev/null
        sudo service docker restart
    else
        echo "Error: Invalid log level specified"
    fi
fi

# If the log driver is set, update the Docker Daemon configuration
if [ -n "$LOG_DRIVER" ]; then
    if [[ "$LOG_DRIVER" =~ ^(none|local|json-file|syslog|journald|gelf|fluentd|awslogs|splunk|etwlogs|gcplogs|logentries)$ ]]; then # Check if the log level is valid
        sudo sed -i '/log-driver/d' /etc/docker/daemon.json  # Removes existing log-driver line
        sudo echo '{"log-driver": "'$LOG_DRIVER'"}' | sudo tee -a /etc/docker/daemon.json > /dev/null
        sudo service docker restart
    else
        echo "Error: Invalid log driver specified"
    fi
  
fi