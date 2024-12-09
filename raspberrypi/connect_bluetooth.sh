#!/bin/bash

# Start the bluetoothctl tool
bluetoothctl << EOF
power on
agent on
scan on
connect A2:6E:CE:5E:2A:62
EOF
