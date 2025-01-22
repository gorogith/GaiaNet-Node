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

# Auto Chat Configuration
AUTO_CHAT_FILE="/tmp/auto_chat.pid"
CHAT_LOG_FILE="$HOME/gaianet/chat_logs.txt"

# Function to start auto chat
start_auto_chat() {
    if [ -f "$AUTO_CHAT_FILE" ]; then
        print_warning "Auto chat is already running!"
        return 1
    fi

    print_info "Starting auto chat..."
    
    # Create chat log file if it doesn't exist
    touch "$CHAT_LOG_FILE"
    
    # Start auto chat process in background
    while true; do
        if [ -f "$AUTO_CHAT_FILE" ]; then
            current_time=$(date '+%Y-%m-%d %H:%M:%S')
            gaianet chat "hello" >> "$CHAT_LOG_FILE" 2>&1
            echo "[$current_time] Auto chat message sent" >> "$CHAT_LOG_FILE"
            sleep 300  # Wait 5 minutes between messages
        else
            break
        fi
    done &
    
    # Save PID
    echo $! > "$AUTO_CHAT_FILE"
    print_success "Auto chat started successfully"
}

# Function to check auto chat status
check_auto_chat() {
    if [ -f "$AUTO_CHAT_FILE" ]; then
        print_success "Auto chat is running"
        print_info "Latest chat logs:"
        tail -n 5 "$CHAT_LOG_FILE"
    else
        print_warning "Auto chat is not running"
    fi
}

# Function to stop auto chat
stop_auto_chat() {
    if [ -f "$AUTO_CHAT_FILE" ]; then
        pid=$(cat "$AUTO_CHAT_FILE")
        kill $pid 2>/dev/null
        rm "$AUTO_CHAT_FILE"
        print_success "Auto chat stopped successfully"
    else
        print_warning "Auto chat is not running"
    fi
}

# Function to install Gaia Node
install_node() {
    print_info "Starting Gaia node installation..."
    
    # Check requirements first
    check_requirements
    
    # Create installation directory
    INSTALL_DIR="$HOME/gaianet"
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Create log files
    INSTALL_LOG="$INSTALL_DIR/install.log"
    touch "$INSTALL_LOG"
    
    # Install required packages
    print_info "Installing required packages..."
    {
        sudo apt-get update
        sudo apt-get install -y curl wget build-essential jq screen python3 python3-pip
    } >> "$INSTALL_LOG" 2>&1
    
    # Download and run Gaia installer
    print_info "Downloading and running Gaia installer..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | tee -a "$INSTALL_LOG" | bash
    
    if [ $? -ne 0 ]; then
        print_error "Installation failed. Check $INSTALL_LOG for details"
        return 1
    fi
    
    # Extract node information
    NODE_ID=$(grep -o "0x[a-fA-F0-9]\{40\}" "$INSTALL_LOG" | tail -n 1)
    DEVICE_ID=$(grep "device ID is" "$INSTALL_LOG" | grep -o "device-[a-zA-Z0-9]\{24\}")
    
    if [ -z "$NODE_ID" ] || [ -z "$DEVICE_ID" ]; then
        print_error "Failed to extract node information"
        return 1
    fi
    
    print_info "Node ID: $NODE_ID"
    print_info "Device ID: $DEVICE_ID"
    
    # Set up environment
    {
        echo "export PATH=\$PATH:$INSTALL_DIR/bin"
        echo "export GAIA_HOME=$INSTALL_DIR"
    } >> "$HOME/.bashrc"
    
    source "$HOME/.bashrc"
    
    # Create start script
    cat > "$INSTALL_DIR/start_node.sh" << 'EOL'
#!/bin/bash
source "$HOME/.bashrc"

# Start node
screen -dmS gaia-node bash -c "cd $GAIA_HOME && gaianet start"

# Start web interface
screen -dmS gaia-web bash -c "cd $GAIA_HOME && gaianet web"
EOL
    
    chmod +x "$INSTALL_DIR/start_node.sh"
    
    # Save node information
    save_node_info "$NODE_ID" "$DEVICE_ID"
    
    print_success "Installation completed successfully!"
    print_info "Use 'source ~/.bashrc' to update your current session"
}

# Function to check node logs
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

# Function to remove Gaia Node
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

# Function to start Gaia Node
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

# Function to stop Gaia Node
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

# Function to check Node Status
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

# Function to show Node Information
show_info() {
    if [ -f "$SCRIPT_DIR/node_info.txt" ]; then
        cat "$SCRIPT_DIR/node_info.txt"
    else
        print_error "Node information file not found. Has the node been installed?"
    fi
}

# Display menu
show_menu() {
    clear
    echo -e "${BLUE}=== Gaia Node Manager ===${NC}"
    echo "1) Install Gaia Node"
    echo "2) Start Node"
    echo "3) Stop Node"
    echo "4) Check Node Status"
    echo "5) View Node Logs"
    echo "6) Show Node Info"
    echo "7) Start Auto Chat"
    echo "8) Stop Auto Chat"
    echo "9) Check Auto Chat Status"
    echo "0) Exit"
    echo
    echo -n "Choose an option: "
}

# Main loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1) install_node ;;
        2) start_node ;;
        3) stop_node ;;
        4) check_status ;;
        5) check_logs ;;
        6) show_info ;;
        7) start_auto_chat ;;
        8) stop_auto_chat ;;
        9) check_auto_chat ;;
        0) 
            print_info "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
done
