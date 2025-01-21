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

# Install Gaia Node
install_node() {
    print_info "Starting Gaia node installation..."
    
    # Check requirements first
    check_requirements
    
    # Use current directory
    INSTALL_DIR="$PWD"
    cd "$INSTALL_DIR"
    
    # Create a log file for installation
    INSTALL_LOG="$INSTALL_DIR/gaia_install.log"
    
    # Install required packages
    print_info "Installing required packages..."
    sudo apt-get update
    sudo apt-get install -y curl wget build-essential jq screen
    
    # Download and run Gaia installer, capture all output
    print_info "Downloading and running Gaia installer..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | tee "$INSTALL_LOG" | bash
    
    # Extract node information from the log immediately after installation
    NODE_ID=$(grep -o "0x[a-fA-F0-9]\{40\}" "$INSTALL_LOG" | tail -n 1)
    DEVICE_ID=$(grep "device ID is" "$INSTALL_LOG" | grep -o "device-[a-zA-Z0-9]\{24\}")
    
    print_info "Node ID found: $NODE_ID"
    print_info "Device ID found: $DEVICE_ID"
    
    # Set up environment
    print_info "Setting up environment..."
    
    # Add gaianet binary path to current session
    export PATH="$PATH:$INSTALL_DIR/gaianet/bin"
    
    # Add to .bashrc if not already present
    if ! grep -q "$INSTALL_DIR/gaianet/bin" ~/.bashrc; then
        echo "export PATH=\$PATH:$INSTALL_DIR/gaianet/bin" >> ~/.bashrc
    fi
    
    # Source .bashrc
    source ~/.bashrc
    
    # Verify gaianet is available
    if ! command -v gaianet &> /dev/null; then
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
Node Information (Generated at: $(date))
=======================================
Node ID: $NODE_ID
Device ID: $DEVICE_ID
Installation Path: $INSTALL_DIR
Public URL: https://${NODE_ID}.gaia.domains

Important Commands:
-----------------
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
EOL
    fi
    
    # Initialize node
    print_info "Initializing Gaia node..."
    if command -v gaianet &> /dev/null; then
        gaianet init
        print_success "Node initialized successfully"
    else
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

# Start Gaia Node
start_node() {
    print_info "Starting Gaia node in screen session..."
    
    # Check if screen is installed
    if ! command -v screen &> /dev/null; then
        print_info "Installing screen..."
        sudo apt-get update && sudo apt-get install -y screen
    fi
    
    # Kill existing screen if exists
    screen -S gaia-node -X quit 2>/dev/null
    
    # Start node in screen
    screen -dmS gaia-node gaianet start
    
    if [ $? -eq 0 ]; then
        print_success "Node started in screen session 'gaia-node'"
        print_info "To view the node:"
        print_info "1. Attach to screen: screen -r gaia-node"
        print_info "2. Detach from screen: Press Ctrl+A, then D"
        
        # Save NODE_ID for auto chat
        NODE_ID=$(gaianet info 2>/dev/null | grep "Node ID" | cut -d':' -f2 | tr -d ' ')
        if [ ! -z "$NODE_ID" ]; then
            print_success "Node ID: $NODE_ID"
        fi
    else
        print_error "Failed to start node"
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
    
    # Check screen sessions
    echo -e "\n=== Screen Sessions ==="
    if screen -list | grep -q "gaia"; then
        screen -list | grep "gaia"
    else
        echo "No Gaia screen sessions found"
    fi
    
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
    fi
}

# Auto Chat function
start_auto_chat() {
    if [ -z "$NODE_ID" ]; then
        print_error "Node ID not found. Please start the node first."
        return 1
    fi

    print_info "Starting Auto Chat with Gaia AI..."
    
    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 is required but not installed."
        return 1
    fi

    # Check if screen is installed
    if ! command -v screen &> /dev/null; then
        print_info "Installing screen..."
        sudo apt-get update && sudo apt-get install -y screen
    fi

    # Check if required Python packages are installed
    if ! python3 -c "import requests" &> /dev/null; then
        print_info "Installing required Python package: requests"
        pip3 install requests
    fi

    # Kill existing auto-chat screen if exists
    screen -S gaia-auto-chat -X quit 2>/dev/null

    # Start auto chat in a new screen session
    print_info "Starting auto chat in screen session 'gaia-auto-chat'..."
    screen -dmS gaia-auto-chat python3 "$SCRIPT_DIR/gaian_chat.py" "$NODE_ID"
    
    print_success "Auto chat started in screen session"
    print_info "To view auto chat:"
    print_info "- Attach to screen: screen -r gaia-auto-chat"
    print_info "- Detach from screen: Ctrl+A, then D"
    print_info "- Stop auto chat: screen -S gaia-auto-chat -X quit"
}

# Check auto chat status
check_auto_chat() {
    if screen -list | grep -q "gaia-auto-chat"; then
        print_success "Auto chat is running"
        print_info "To view messages, use: screen -r gaia-auto-chat"
    else
        print_warning "Auto chat is not running"
    fi
}

# Stop auto chat
stop_auto_chat() {
    if screen -list | grep -q "gaia-auto-chat"; then
        print_info "Stopping auto chat..."
        screen -S gaia-auto-chat -X quit
        print_success "Auto chat stopped"
    else
        print_warning "Auto chat is not running"
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
    echo "5) View Node Logs"
    echo "6) Show Node Info"
    echo "7) Remove Node"
    echo "8) Start Auto Chat"
    echo "9) Stop Auto Chat"
    echo "10) Check Auto Chat Status"
    echo "11) Exit"
    echo
    echo -n "Choose an option: "
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
            check_logs
            ;;
        6)
            show_info
            ;;
        7)
            remove_node
            ;;
        8)
            start_auto_chat
            ;;
        9)
            stop_auto_chat
            ;;
        10)
            check_auto_chat
            ;;
        11)
            print_info "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
    
    echo
    read -n 1 -s -r -p "Press any key to continue..."
done
