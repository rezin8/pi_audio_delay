#!/usr/bin/python

import RPi.GPIO as GPIO
import time
import os
import subprocess

GPIO.setmode(GPIO.BCM)
GPIO.setup(18, GPIO.IN, pull_up_down = GPIO.PUD_UP)

while True:
	if(GPIO.input(18) ==0):
#		print("Button Pressed")
		subprocess.call(["perl", "/home/pi/audiodelay.pl"])
GPIO.cleanup()

