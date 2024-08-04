#!/bin/bash

# Function to install the selected script
install_script() {
  local script_path="$1"
  local frequency="$2"
  local time="$3"

  # Ensure the script exists
  if [[ ! -f $script_path ]]; then
    echo "The script $script_path does not exist. Exiting."
    exit 1
  fi

  # Add the cron job
  case $frequency in
    "hourly")
      (crontab -l 2>/dev/null; echo "0 * * * * $script_path") | crontab -
      ;;
    "daily")
      if [[ -n $time ]]; then
        minute=$(echo $time | cut -d':' -f2)
        hour=$(echo $time | cut -d':' -f1)
        (crontab -l 2>/dev/null; echo "$minute $hour * * * $script_path") | crontab -
      else
        (crontab -l 2>/dev/null; echo "0 0 * * * $script_path") | crontab -
      fi
      ;;
    "weekly")
      (crontab -l 2>/dev/null; echo "0 0 * * 0 $script_path") | crontab -
      ;;
    *)
      echo "Invalid frequency. Exiting."
      exit 1
      ;;
  esac

  echo "Cron job has been set up successfully."
}

# Main script
echo "Select the script to run (.sh or .py):"
read -e -p "Path to the script: " script_path

echo "How often do you want to run the script?"
options=("hourly" "daily" "weekly")
select opt in "${options[@]}"
do
  frequency=$opt
  break
done

time=""
if [[ $frequency == "daily" ]]; then
  read -p "Enter the time to run the script daily (HH:MM format, 24-hour): " time
fi

install_script "$script_path" "$frequency" "$time"

