#!/usr/bin/perl

use strict;
use warnings;
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
my $input_device = " -D plughw:1 ";
my $output_device = " -D plughw:1 ";

# aplay and arecord options
my $format = " -f cd ";
my $options = " ";

# aplay and arecord command lines
my $input_line = "$arecord  $options  $format " . $input_device . "  2> /dev/null";
my $output_line = "$aplay  $options  $format " . $output_device . "  2> /dev/null";

# time delay
my $seconds = rand(3);
my $delay = 0;

#convert to milliseconds
my $milli = sprintf( "%.0f", $seconds*1000);

print "Delaying audio by $milli milliseconds\n";

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
print "Buffering $milli milliseconds of audio data...";
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
    #print "Input thread started\n";
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
    #print "Output thread started\n";
    while (1){
	# get data from the queue
	$out_buf = $stream->dequeue;
	# write data to audio output
	print OUTPUT $out_buf;
	yield();
    }
}

# run in a loop for ever until the program is exited. 
#print "Enter CTRL-C to end playback\n";
#while (1){
sleep(8);
#    yield();

#};

close (INPUT);
close (OUTPUT);
exit;

