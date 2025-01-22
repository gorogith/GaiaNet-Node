#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to save node information
save_node_info() {
    local node_id=$1
    local device_id=$2
    
    cat > ~/gaianet/node_info.txt << EOL
Node Information (Saved at: $(date))
================================
Node ID: $node_id
Device ID: $device_id
Public URL: https://$node_id.gaia.domains

Important Commands:
- Start node: gaianet start
- Stop node: gaianet stop
- Check status: gaianet status
- View logs: gaianet logs
EOL

    print_success "Node information saved to ~/gaianet/node_info.txt"
}

# Function to check system requirements
check_requirements() {
    print_info "Checking system requirements..."
    
    # Check CPU architecture
    arch=$(uname -m)
    print_info "CPU Architecture: $arch"
    
    # Check available memory
    mem_total=$(free -h | awk '/^Mem:/{print $2}')
    mem_free=$(free -h | awk '/^Mem:/{print $4}')
    print_info "Total Memory: $mem_total"
    print_info "Free Memory: $mem_free"
    
    # Check disk space
    disk_space=$(df -h / | awk 'NR==2{print $4}')
    print_info "Available Disk Space: $disk_space"
}

# Get the current directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

<<<<<<< HEAD
=======
# Function to setup environment
setup_environment() {
    # Add gaianet paths
    export PATH="$PATH:$SCRIPT_DIR/gaianet/bin:$HOME/gaianet/bin:$SCRIPT_DIR/bin"
    
    # Add to .bashrc if not already present
    if ! grep -q "gaianet/bin" ~/.bashrc; then
        echo "export PATH=\$PATH:$SCRIPT_DIR/gaianet/bin:$HOME/gaianet/bin:$SCRIPT_DIR/bin" >> ~/.bashrc
    fi
    
    # Source bashrc
    source ~/.bashrc
}

>>>>>>> a3f898e (Initial commit)
# Install Gaia Node
install_node() {
    print_info "Starting Gaia node installation..."
    
    # Check requirements first
    check_requirements
    
<<<<<<< HEAD
    # Use current directory
    INSTALL_DIR="$PWD"
=======
    # Use home directory for VPS installation
    INSTALL_DIR="$HOME/gaianet"
    mkdir -p "$INSTALL_DIR"
>>>>>>> a3f898e (Initial commit)
    cd "$INSTALL_DIR"
    
    # Create a log file for installation
    INSTALL_LOG="$INSTALL_DIR/gaia_install.log"
    
    # Install required packages
    print_info "Installing required packages..."
    sudo apt-get update
<<<<<<< HEAD
    sudo apt-get install -y curl wget build-essential jq screen
    
    # Download and run Gaia installer, capture all output
    print_info "Downloading and running Gaia installer..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | tee "$INSTALL_LOG" | bash
    
    # Extract node information from the log immediately after installation
=======
    sudo apt-get install -y curl wget git build-essential jq screen lsof python3 python3-pip
    
    # Install Python packages
    pip3 install requests
    
    # Download and run Gaia installer
    print_info "Downloading and running Gaia installer..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | tee "$INSTALL_LOG" | bash
    
    # Extract node information from the log
>>>>>>> a3f898e (Initial commit)
    NODE_ID=$(grep -o "0x[a-fA-F0-9]\{40\}" "$INSTALL_LOG" | tail -n 1)
    DEVICE_ID=$(grep "device ID is" "$INSTALL_LOG" | grep -o "device-[a-zA-Z0-9]\{24\}")
    
    print_info "Node ID found: $NODE_ID"
    print_info "Device ID found: $DEVICE_ID"
    
    # Set up environment
    print_info "Setting up environment..."
    
<<<<<<< HEAD
    # Add gaianet binary path to current session
    export PATH="$PATH:$INSTALL_DIR/gaianet/bin"
    
    # Add to .bashrc if not already present
    if ! grep -q "$INSTALL_DIR/gaianet/bin" ~/.bashrc; then
        echo "export PATH=\$PATH:$INSTALL_DIR/gaianet/bin" >> ~/.bashrc
    fi
    
    # Source .bashrc
=======
    # Clean up existing PATH entries
    sed -i '/gaianet\/bin/d' ~/.bashrc
    
    # Add gaianet binary path
    echo "export PATH=\$PATH:$INSTALL_DIR/bin:$HOME/.local/bin" >> ~/.bashrc
>>>>>>> a3f898e (Initial commit)
    source ~/.bashrc
    
    # Verify gaianet is available
    if ! command -v gaianet &> /dev/null; then
<<<<<<< HEAD
        print_error "gaianet command not found. Adding it manually..."
        # Try alternative paths
        if [ -f "$INSTALL_DIR/bin/gaianet" ]; then
            export PATH="$PATH:$INSTALL_DIR/bin"
            echo "export PATH=\$PATH:$INSTALL_DIR/bin" >> ~/.bashrc
        elif [ -f "$HOME/gaianet/bin/gaianet" ]; then
            export PATH="$PATH:$HOME/gaianet/bin"
            echo "export PATH=\$PATH:$HOME/gaianet/bin" >> ~/.bashrc
        fi
    fi
    
    # Create info directory
    mkdir -p "$INSTALL_DIR/info"
    
    # Save node information immediately
    if [ ! -z "$NODE_ID" ] && [ ! -z "$DEVICE_ID" ]; then
        cat > "$INSTALL_DIR/info/node_details.txt" << EOL
=======
        print_error "gaianet command not found. Installing manually..."
        if [ -f "$INSTALL_DIR/bin/gaianet" ]; then
            sudo ln -sf "$INSTALL_DIR/bin/gaianet" /usr/local/bin/gaianet
        fi
    fi
    
    # Create config directory
    mkdir -p "$INSTALL_DIR/config"
    
    # Save node information
    if [ ! -z "$NODE_ID" ] && [ ! -z "$DEVICE_ID" ]; then
        cat > "$INSTALL_DIR/config/node_details.txt" << EOL
>>>>>>> a3f898e (Initial commit)
Node Information (Generated at: $(date))
=======================================
Node ID: $NODE_ID
Device ID: $DEVICE_ID
Installation Path: $INSTALL_DIR
Public URL: https://${NODE_ID}.gaia.domains

Important Commands:
-----------------
<<<<<<< HEAD
1. Start node in screen: $INSTALL_DIR/start_screens.sh
2. View node screen: screen -r gaia-node
3. View web interface screen: screen -r gaia-web
4. Check status: gaianet status
5. View logs: gaianet logs
6. Stop node: gaianet stop

Screen Commands:
--------------
- Detach from screen: Ctrl+A, then D
- List screens: screen -list
- Reattach to screen: screen -r [screen-name]
=======
1. Start node:    gaianet start
2. Stop node:     gaianet stop
3. Check status:  gaianet status
4. View logs:     gaianet logs

Screen Commands:
--------------
- View node screen: screen -r gaia-node
- Detach from screen: Press Ctrl+A, then D
- List screens: screen -list
- Kill screen: screen -S gaia-node -X quit
>>>>>>> a3f898e (Initial commit)
EOL
    fi
    
    # Initialize node
    print_info "Initializing Gaia node..."
    if command -v gaianet &> /dev/null; then
        gaianet init
        print_success "Node initialized successfully"
    else
<<<<<<< HEAD
        print_error "Failed to find gaianet command. Please run these commands manually:"
        echo "export PATH=\$PATH:$INSTALL_DIR/gaianet/bin"
        echo "source ~/.bashrc"
        echo "gaianet init"
        return 1
    fi
    
    # Create screen startup script
    cat > "$INSTALL_DIR/start_screens.sh" << EOL
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Source environment
source ~/.bashrc
export PATH=\$PATH:$INSTALL_DIR/gaianet/bin:$INSTALL_DIR/bin

echo -e "\${BLUE}Starting Gaia node in screen...\${NC}"

# Kill existing screens if they exist
screen -S gaia-node -X quit >/dev/null 2>&1
screen -S gaia-web -X quit >/dev/null 2>&1

# Start Gaia node in screen
screen -dmS gaia-node bash -c '
    source ~/.bashrc
    export PATH=\$PATH:$INSTALL_DIR/gaianet/bin:$INSTALL_DIR/bin
    cd "$INSTALL_DIR"
    gaianet start
'

echo -e "\${GREEN}Node screen session created\${NC}"
echo "Waiting for node to initialize..."
sleep 10

# Start web interface in screen
screen -dmS gaia-web bash -c '
    cd "$INSTALL_DIR"
    python3 app.py
'

echo -e "\${GREEN}Web interface screen session created\${NC}"
echo
echo "Screen sessions:"
screen -list | grep gaia
echo
echo "To attach to screens:"
echo "1. Node screen: screen -r gaia-node"
echo "2. Web interface: screen -r gaia-web"
echo "To detach from screen: Ctrl+A, then D"
EOL
    
    chmod +x "$INSTALL_DIR/start_screens.sh"
    
    print_success "Installation and initialization completed!"
    print_info "Detailed information saved to: $INSTALL_DIR/info/node_details.txt"
    print_info "To start node in screen: $INSTALL_DIR/start_screens.sh"
    
    # Display node information
    if [ ! -z "$NODE_ID" ] && [ ! -z "$DEVICE_ID" ]; then
        echo
        print_info "Node Information Summary:"
        echo "-----------------------------"
        echo "Node ID: $NODE_ID"
        echo "Device ID: $DEVICE_ID"
        echo "Public URL: https://${NODE_ID}.gaia.domains"
        echo
    else
        print_warning "Could not find node information in installation log"
        print_info "Please check $INSTALL_LOG for details"
    fi
=======
        print_error "Failed to find gaianet command"
        return 1
    fi
    
    print_success "Installation completed successfully!"
    print_info "Please run 'source ~/.bashrc' to update your environment"
}

# Start Gaia Node
start_node() {
    if ! command -v gaianet &> /dev/null; then
        print_error "Gaia node not found. Please install it first (Option 1)"
        return 1
    fi
    
    print_info "Starting Gaia node in screen session..."
    
    # Kill existing screen if exists
    screen -S gaia-node -X quit 2>/dev/null
    
    # Initialize node if needed
    if ! gaianet info &>/dev/null; then
        print_info "Initializing node..."
        gaianet init
    fi
    
    # Get base directory
    local BASE_DIR="$HOME/gaianet"
    
    # Create startup script
    STARTUP_SCRIPT="/tmp/gaia_startup.sh"
    cat > "$STARTUP_SCRIPT" << EOL
#!/bin/bash
source ~/.bashrc

while true; do
    echo "Starting Gaia node..."
    gaianet start --base "$BASE_DIR" --force-rag
    
    if [ \$? -ne 0 ]; then
        echo "Node failed to start, retrying in 5 seconds..."
    else
        echo "Node exited normally, restarting in 5 seconds..."
    fi
    sleep 5
done
EOL
    chmod +x "$STARTUP_SCRIPT"
    
    # Start in screen
    screen -dmS gaia-node bash -c "exec $STARTUP_SCRIPT"
    sleep 2
    
    if ! screen -list | grep -q "gaia-node"; then
        print_error "Failed to create screen session"
        rm -f "$STARTUP_SCRIPT"
        return 1
    fi
    
    # Wait for initialization
    print_info "Waiting for node to initialize..."
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if gaianet info &>/dev/null; then
            NODE_ID=$(gaianet info 2>/dev/null | grep "Node ID" | cut -d':' -f2 | tr -d ' ')
            if [ ! -z "$NODE_ID" ]; then
                print_success "Node started successfully"
                print_success "Node ID: $NODE_ID"
                print_success "Public URL: https://${NODE_ID}.gaia.domains"
                
                print_info "To view the node:"
                print_info "1. Attach to screen: screen -r gaia-node"
                print_info "2. Detach from screen: Press Ctrl+A, then D"
                print_info "3. View logs: gaianet logs"
                return 0
            fi
        fi
        print_info "Attempt $attempt of $max_attempts..."
        sleep 3
        attempt=$((attempt + 1))
    done
    
    print_error "Node failed to start properly"
    screen -S gaia-node -X quit 2>/dev/null
    rm -f "$STARTUP_SCRIPT"
    return 1
>>>>>>> a3f898e (Initial commit)
}

# Check node logs
check_logs() {
    print_info "Checking Gaia node logs..."
    
    # Create logs directory if it doesn't exist
    mkdir -p "$SCRIPT_DIR/logs"
    
    # Get different types of logs
    echo "=== Gaia Node Logs ===" > "$SCRIPT_DIR/logs/combined_logs.txt"
    gaianet logs >> "$SCRIPT_DIR/logs/combined_logs.txt"
    
    echo -e "\n=== System Resource Usage ===" >> "$SCRIPT_DIR/logs/combined_logs.txt"
    top -b -n 1 | head -n 20 >> "$SCRIPT_DIR/logs/combined_logs.txt"
    
    echo -e "\n=== Disk Usage ===" >> "$SCRIPT_DIR/logs/combined_logs.txt"
    df -h >> "$SCRIPT_DIR/logs/combined_logs.txt"
    
    print_success "Logs have been saved to $SCRIPT_DIR/logs/combined_logs.txt"
    
    # Show last 10 lines of logs
    print_info "Last 10 lines of node logs:"
    tail -n 10 "$SCRIPT_DIR/logs/combined_logs.txt"
}

<<<<<<< HEAD
=======
# Stop Gaia Node
stop_node() {
    print_info "Stopping Gaia node..."
    
    # Try to stop gaianet gracefully first
    if command -v gaianet &> /dev/null; then
        gaianet stop
        sleep 2
    fi
    
    # Kill screen sessions
    local killed_screen=0
    
    if screen -list | grep -q "gaia-node"; then
        screen -S gaia-node -X quit
        print_success "Gaia node screen session terminated"
        killed_screen=1
    fi
    
    # Clean up startup script if exists
    if [ -f "/tmp/gaia_startup.sh" ]; then
        rm -f "/tmp/gaia_startup.sh"
    fi
    
    # Double check if node is really stopped
    if gaianet info &>/dev/null; then
        print_warning "Node process might still be running"
        print_info "You may need to manually kill the process"
        ps aux | grep gaianet | grep -v grep
    else
        if [ $killed_screen -eq 1 ]; then
            print_success "Node stopped successfully"
        else
            print_warning "No running node found"
        fi
    fi
}

>>>>>>> a3f898e (Initial commit)
# Remove Gaia Node
remove_node() {
    print_warning "This will completely remove Gaia node and all its data."
    read -p "Are you sure you want to continue? (y/N) " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        print_info "Stopping Gaia node services..."
        gaianet stop
        
        print_info "Removing Gaia node files..."
        rm -rf "$SCRIPT_DIR"
        
        print_info "Cleaning up environment..."
        # Remove environment variables from .bashrc
        sed -i "/$SCRIPT_DIR/d" ~/.bashrc
        
        print_success "Gaia node has been completely removed."
    else
        print_info "Operation cancelled."
    fi
}

<<<<<<< HEAD
# Start Gaia Node
start_node() {
    print_info "Starting Gaia node in screen session..."
    
    # Check if screen is installed
    if ! command -v screen &> /dev/null; then
        print_warning "Screen is not installed. Installing..."
        sudo apt-get update && sudo apt-get install -y screen
    fi
    
    # Check if node is already running
    if screen -list | grep -q "gaia-node"; then
        print_warning "Gaia node screen session already exists!"
        print_info "You can attach to it using: screen -r gaia-node"
        return
    fi
    
    # Start node in screen session
    screen -dmS gaia-node bash -c '
        source ~/.bashrc
        cd "'"$SCRIPT_DIR"'"
        gaianet start
    '
    
    # Wait a bit for node to start
    sleep 5
    
    # Check if screen session was created
    if screen -list | grep -q "gaia-node"; then
        print_success "Node started in screen session 'gaia-node'"
        print_info "To view the node:"
        print_info "1. Attach to screen: screen -r gaia-node"
        print_info "2. Detach from screen: Press Ctrl+A, then D"
        
        # Start web interface if requested
        read -p "Do you want to start the web interface? (y/N) " start_web
        if [ "$start_web" = "y" ] || [ "$start_web" = "Y" ]; then
            if screen -list | grep -q "gaia-web"; then
                print_warning "Web interface screen session already exists!"
                print_info "You can attach to it using: screen -r gaia-web"
            else
                screen -dmS gaia-web bash -c '
                    cd "'"$SCRIPT_DIR"'"
                    python3 app.py
                '
                print_success "Web interface started in screen session 'gaia-web'"
                print_info "Access it at: http://localhost:5001"
                print_info "To view the web interface logs: screen -r gaia-web"
            fi
        fi
    else
        print_error "Failed to start node in screen session"
    fi
}

# Stop Gaia Node
stop_node() {
    print_info "Stopping Gaia node..."
    
    # Stop node process
    gaianet stop
    
    # Kill screen sessions
    if screen -list | grep -q "gaia-node"; then
        screen -S gaia-node -X quit
        print_success "Gaia node screen session terminated"
    fi
    
    if screen -list | grep -q "gaia-web"; then
        screen -S gaia-web -X quit
        print_success "Web interface screen session terminated"
    fi
    
    print_success "Node stopped."
}

# Check Node Status
check_status() {
    print_info "Checking node status..."
=======
# Function to check if port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        return 0
    else
        return 1
    fi
}

# Function to find available port
find_available_port() {
    local start_port=$1
    local port=$start_port
    print_info "Checking port $port..."
    while check_port $port; do
        print_warning "Port $port is in use, trying next port..."
        port=$((port + 1))
        print_info "Checking port $port..."
    done
    print_success "Found available port: $port"
    echo $port
}

# Check Node Status and Information
check_status() {
    # Check if gaianet is installed
    if ! command -v gaianet &> /dev/null; then
        print_error "Gaia node not found. Please install it first (Option 1)"
        return 1
    fi
    
    print_info "Checking node status and information..."
    
    # Setup environment
    setup_environment
>>>>>>> a3f898e (Initial commit)
    
    # Check screen sessions
    echo -e "\n=== Screen Sessions ==="
    if screen -list | grep -q "gaia"; then
        screen -list | grep "gaia"
    else
        echo "No Gaia screen sessions found"
    fi
    
<<<<<<< HEAD
    # Check node status
    echo -e "\n=== Node Status ==="
    gaianet status
}

# Show Node Information
show_info() {
    if [ -f "$SCRIPT_DIR/node_info.txt" ]; then
        cat "$SCRIPT_DIR/node_info.txt"
    else
        print_error "Node information file not found. Has the node been installed?"
=======
    # Check if node is running and show information
    echo -e "\n=== Node Status & Information ==="
    if gaianet info &>/dev/null; then
        NODE_INFO=$(gaianet info 2>/dev/null)
        NODE_ID=$(echo "$NODE_INFO" | grep "Node ID" | cut -d':' -f2 | tr -d ' ')
        DEVICE_ID=$(echo "$NODE_INFO" | grep "Device ID" | cut -d':' -f2 | tr -d ' ')
        
        if [ ! -z "$NODE_ID" ] || [ ! -z "$DEVICE_ID" ]; then
            print_success "Node is running"
            
            echo -e "\nNode Configuration:"
            echo "=================="
            [ ! -z "$NODE_ID" ] && echo "Node ID: $NODE_ID"
            [ ! -z "$DEVICE_ID" ] && echo "Device ID: $DEVICE_ID"
            [ ! -z "$NODE_ID" ] && echo "Public URL: https://${NODE_ID}.gaia.domains"
            
            echo -e "\nUseful Commands:"
            echo "=================="
            echo "1. Start node:    gaianet start"
            echo "2. Stop node:     gaianet stop"
            echo "3. View logs:     gaianet logs"
            echo "4. View screen:   screen -r gaia-node"
            
            echo -e "\nScreen Commands:"
            echo "=================="
            echo "- List screens:     screen -list"
            echo "- Attach to screen: screen -r [screen-name]"
            echo "- Detach:           Ctrl+A, then D"
            echo "- Kill screen:      screen -S [screen-name] -X quit"
        else
            print_warning "Node status unknown"
        fi
    else
        print_error "Node is not running"
        print_info "Try starting the node first (Option 2)"
    fi
}

# Auto Chat function
start_auto_chat() {
    print_info "Starting Auto Chat with Gaia AI..."
    
    # Check if node is running and get node ID
    if ! gaianet info &>/dev/null; then
        print_error "Node is not running. Please start the node first (Option 2)"
        return 1
    fi
    
    NODE_ID=$(gaianet info 2>/dev/null | grep "Node ID" | cut -d':' -f2 | tr -d ' ')
    if [ -z "$NODE_ID" ]; then
        print_error "Could not get Node ID. Please ensure the node is running properly"
        return 1
    fi
    
    # Check if python3 is installed
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 is required but not installed"
        return 1
    fi
    
    # Check if required files exist
    if [ ! -f "$SCRIPT_DIR/bot_chat.py" ]; then
        print_error "bot_chat.py not found"
        return 1
    fi
    
    if [ ! -f "$SCRIPT_DIR/keyword.txt" ]; then
        print_error "keyword.txt not found"
        return 1
    fi
    
    # Check if requests module is installed
    if ! python3 -c "import requests" &> /dev/null; then
        print_info "Installing required Python package: requests"
        pip3 install requests
    fi
    
    # Kill existing screen if exists
    screen -S gaia-auto-chat -X quit 2>/dev/null
    
    # Create startup script for auto chat
    AUTO_CHAT_SCRIPT="/tmp/auto_chat_startup.sh"
    cat > "$AUTO_CHAT_SCRIPT" << EOL
#!/bin/bash

cd "$SCRIPT_DIR"
NODE_ID="$NODE_ID"

while true; do
    echo "Starting auto chat for Node ID: \$NODE_ID"
    python3 bot_chat.py "\$NODE_ID"
    
    # Check exit status
    if [ \$? -ne 0 ]; then
        echo "Auto chat failed, retrying in 5 seconds..."
    else
        echo "Auto chat exited normally, restarting in 5 seconds..."
    fi
    sleep 5
done
EOL
    chmod +x "$AUTO_CHAT_SCRIPT"
    
    print_info "Starting auto chat in screen session 'gaia-auto-chat'..."
    print_info "Using Node ID: $NODE_ID"
    
    # Start auto chat in screen
    screen -dmS gaia-auto-chat bash -c "
        cd \"$SCRIPT_DIR\"
        exec $AUTO_CHAT_SCRIPT
    "
    
    # Wait for screen session to be created
    sleep 2
    
    # Verify screen session exists
    if screen -list | grep -q "gaia-auto-chat"; then
        print_success "Auto chat started in screen session"
        print_info "To view auto chat:"
        print_info "- Attach to screen: screen -r gaia-auto-chat"
        print_info "- Detach from screen: Press Ctrl+A, then D"
        print_info "- Stop auto chat: screen -S gaia-auto-chat -X quit"
    else
        print_error "Failed to start auto chat"
        rm -f "$AUTO_CHAT_SCRIPT"
        return 1
    fi
}

# Stop auto chat
stop_auto_chat() {
    local stopped=0
    
    # Try to find and kill the screen session
    if screen -list | grep -q "gaia-auto-chat"; then
        screen -S gaia-auto-chat -X quit
        stopped=1
    fi
    
    # Clean up startup script if exists
    if [ -f "/tmp/auto_chat_startup.sh" ]; then
        rm -f "/tmp/auto_chat_startup.sh"
    fi
    
    # Check if any python process related to auto chat is still running
    if pgrep -f "python3.*bot_chat.py" > /dev/null; then
        print_warning "Auto chat process still running"
        print_info "Attempting to kill remaining processes..."
        pkill -f "python3.*bot_chat.py"
        sleep 1
    fi
    
    if [ $stopped -eq 1 ]; then
        print_success "Auto chat stopped successfully"
    else
        print_warning "Auto chat is not running"
    fi
}

# Check auto chat status
check_auto_chat() {
    local running=0
    
    # Check screen session
    if screen -list | grep -q "gaia-auto-chat"; then
        running=1
    fi
    
    # Check python process
    if pgrep -f "python3.*bot_chat.py" > /dev/null; then
        running=1
    fi
    
    if [ $running -eq 1 ]; then
        print_success "Auto chat is running"
        print_info "Screen session: gaia-auto-chat"
        print_info "Process info:"
        ps aux | grep "python3.*bot_chat.py" | grep -v grep
    else
        print_warning "Auto chat is not running"
>>>>>>> a3f898e (Initial commit)
    fi
}

# Display menu
show_menu() {
    clear
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}      Gaia Node Manager${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
    echo "1) Install Gaia Node"
    echo "2) Start Node"
    echo "3) Stop Node"
    echo "4) Check Node Status"
<<<<<<< HEAD
    echo "5) View Node Information"
    echo "6) Check Logs"
    echo "7) Remove Node"
    echo "8) Check System Requirements"
    echo "9) Exit"
    echo
    echo -n "Please enter your choice [1-9]: "
=======
    echo "5) View Node Logs"
    echo "6) Start Auto Chat"
    echo "7) Stop Auto Chat"
    echo "8) Check Auto Chat Status"
    echo "0) Exit"
    echo
    echo -n "Choose an option: "
>>>>>>> a3f898e (Initial commit)
}

# Main loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1)
            install_node
            ;;
        2)
            start_node
            ;;
        3)
            stop_node
            ;;
        4)
            check_status
            ;;
        5)
<<<<<<< HEAD
            show_info
            ;;
        6)
            check_logs
            ;;
        7)
            remove_node
            ;;
        8)
            check_requirements
            ;;
        9)
            echo "Goodbye!"
=======
            check_logs
            ;;
        6)
            start_auto_chat
            ;;
        7)
            stop_auto_chat
            ;;
        8)
            check_auto_chat
            ;;
        0)
            print_info "Exiting..."
>>>>>>> a3f898e (Initial commit)
            exit 0
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
    
    echo
    read -n 1 -s -r -p "Press any key to continue..."
<<<<<<< HEAD
done
=======
done
>>>>>>> a3f898e (Initial commit)
