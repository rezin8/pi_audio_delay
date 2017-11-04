# pi_audio_delay
A random 0 - 3 second audio delay for the Raspberry Pi Zero. Used for practicing International Skeet by yourself on a field without a delay box.

All scripts need chmod +x to make them executable.

The delay.sh script needs to be moved to /etc/init.d/

The scripts assume they will be store in /home/pi. You can put them anywhere you want, but you'll need to update the script with the correct path.

The button script assumes GPIO pin 18 will be used. 
