#!/usr/bin/perl
################################################################################
#	audiodelay
#	
#	Author: Greg Ledet 
#	Version: 1.1
#
#	© 11/04/2017
#
#	For delaying audio by a set time. Great for syncing up audio that is always
#	ahead of a video stream, like listening to the radio for a sports game while
#	watching it on TV.
#
#	Usage: perl audiodelay_set.pl --number of seconds for delay--
#
#	Usage Options.
#	
#	You may need to change the input and output port assignments to suit your
#	setup.
#	
#	To determine how your audio devices are assigned run aplay as shown in the 
#	following example:
#	
#	$ aplay -l
#	
#	**** List of PLAYBACK Hardware Devices ****
#	card 0: ALSA [bcm2835 ALSA], device 0: bcm2835 ALSA [bcm2835 ALSA]
#	  Subdevices: 7/8
#	  Subdevice #0: subdevice #0
#	  Subdevice #1: subdevice #1
#	  Subdevice #2: subdevice #2
#	  Subdevice #3: subdevice #3
#	  Subdevice #4: subdevice #4
#	  Subdevice #5: subdevice #5
#	  Subdevice #6: subdevice #6
#	  Subdevice #7: subdevice #7
#	card 1: system [iMic USB audio system], device 0: USB Audio [USB Audio]
#	  Subdevices: 1/1
#	  Subdevice #0: subdevice #0
#	
#	This shows that card 0 is the built in audio device (bcm2835) and card 1 is 
#	a Griffin iMic USB audio device.
#	
#	This translates to the following lines in the script:
#	
#	my $input_device = "-D plughw:1";
#	my $output_device = " ";
#	
#	These lines may need to be altered to suit your audio devices and their 
#	order.
#	
#	Also, you may need to change the audio levels on the Raspberry Pi to suit 
#	the audio source and output, do this by running the following:
#	
#	$ alsamixer
#	
#	and then follow the on-screen instructions to adjust the volume.
#
################################################################################

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use Thread;
use Thread::Queue;
use Thread qw(yield);
use Time::HiRes qw(usleep);

# set buffering to flush STDOUT immediately
$| = 1;

# find the location of all the executables
my $aplay = `which aplay`;
chomp $aplay;
my $arecord = `which arecord`;
chomp $arecord;

# aplay and arecord devices

#my $input_device = " ";
my $input_device = " -D plughw:1 ";
#my $output_device = " ";
my $output_device = " -D plughw:1 ";

# aplay and arecord options
my $format = " -f cd ";
my $options = " ";

# aplay and arecord command lines
my $input_line = "$arecord  $options  $format " . $input_device . "  2> /dev/null";
my $output_line = "$aplay  $options  $format " . $output_device . "  2> /dev/null";

# time delay
my $seconds = 0;
my $delay = 0;

if (defined($ARGV[0]) && looks_like_number($ARGV[0]) && ($ARGV[0] >= 1.5)) {
	$seconds = $ARGV[0];
	$delay = $seconds - 0.8;
}
else {
	print "Usage:\n";
	print "$0 [delay in seconds > 1.5 seconds]\n\n";
	exit;
}

print "Delaying audio by $seconds seconds\n";
#print "Input = $input_line\n";
#print "Output = $output_line\n";

# variables for buffering audio
my $buffer_len = 1024;

# create a thread data queue for audio data
my $stream = new Thread::Queue;

# launch threads for audio input and output

# opening file handle for audio input
open (INPUT, "-|", $input_line);
# start input thread 
my $input_thread = new Thread \&input_sub;
$input_thread->detach;

# let the input data queue up for the required delay length
print "Buffering $seconds seconds of audio data...";
usleep($seconds * 1000000);
print " done.\n";

# opening file handle for audio output
open (OUTPUT, "|-", $output_line);
# start output thread
print "Starting playback of delayed audio data.\n";
my $output_thread = new Thread \&output_sub;
$output_thread->detach;

# this is the input thread subroutine
sub input_sub {
    my $in_buf = 0;
#    print "Input thread started\n";
    while (1){
	# read data from the audio input
	read(INPUT, $in_buf, $buffer_len);
	# put data into the queue
        $stream->enqueue($in_buf);
	yield();
    }
}

# this is the output thread subroutine 
sub output_sub {
    my $out_buf = 0;
#    print "Output thread started\n";
    while (1){
	# get data from the queue
	$out_buf = $stream->dequeue;
	# write data to audio output
	print OUTPUT $out_buf;
	yield();
    }
}

# run in a loop for ever until the program is exited. 
print "Enter CTRL-C to end playback\n";
while (1){
    yield();
};

close (INPUT);
close (OUTPUT);
exit;


