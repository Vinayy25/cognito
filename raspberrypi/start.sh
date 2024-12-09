# Start the pigpio daemon
sudo pigpiod


#call the connect_bluetooth.sh script
./connect_bluetooth.sh

# Set the bluetooth headset to handsfree_head_unit
pactl set-card-profile bluez_card.A2_6E_CE_5E_2A_62 handsfree_head_unit



