
#Step1: Create Simulator Object
set ns [new Simulator]


# Checking for the number of arguments
if { $argc != 2 } {
        puts "Please enter the TCP_flavor and Case_number"
}

#set the TCP_flavor and Case_number from input
set flavor [lindex $argv 0]
set case_no [lindex $argv 1]

# Step2: Tracing
set nf [open out.nam w]
$ns namtrace-all $nf

set tracefile [open out.tr w]
$ns trace-all $tracefile

set file "out_$flavor$case_no"

#Recording Data in output files and declaring variables for throughput
set f1 [open out1.tr w]
set f2 [open out2.tr w]

set thrp1 0
set thrp2 0
set temp 0


#Step3: Create Network
#Defining nodes
set src1 [$ns node];
set src2 [$ns node];
set r1 [$ns node];
set r2 [$ns node];
set rcv1 [$ns node];
set rcv2 [$ns node];

#Defining colours
#Define different colors for data flows
$ns color 1 Red
$ns color 2 Blue

#Taking care of delay parameter for all three cases
global delay
set delay 0

if {$case_no == 1} {
	set delay "12.5ms"
} elseif {$case_no == 2} {
	set delay "20ms"
} elseif {$case_no == 3} {
	set delay "27.5ms"
} else {
	puts "You've entered the wrong case number"
}

#Defining links and queuing
$ns duplex-link $src1 $r1 10Mb 5ms DropTail
$ns duplex-link $src2 $r1 10Mb $delay DropTail
$ns duplex-link $r1 $r2 1Mb 5ms DropTail
$ns duplex-link $r2 $rcv1 10Mb 5ms DropTail
$ns duplex-link $r2 $rcv2 10Mb $delay DropTail


#Assigning node positions
$ns duplex-link-op $src1 $r1 orient right-down
$ns duplex-link-op $src2 $r1 orient right-up
$ns duplex-link-op $r1 $r2 orient right
$ns duplex-link-op $r2 $rcv1 orient right-up
$ns duplex-link-op $r2 $rcv2 orient right-down


#Step4: Network Dynamics


#Step5: Creating TCP Connection
if {$flavor == "VEGAS"} {
	set tcp1 [new Agent/TCP/Vegas]
	set tcp2 [new Agent/TCP/Vegas]
} elseif {$flavor == "SACK"} {
	set tcp1 [new Agent/TCP/Sack1]
	set tcp2 [new Agent/TCP/Sack1]
} else {
	puts "You've entered the wrong TCP flavor"
}


#Setting the colour for the connections
$tcp1 set class_ 1
$tcp2 set class_ 2

#Creating receiver sinks and connecting
set sink1 [new Agent/TCPSink]
$ns attach-agent $src1 $tcp1
$ns attach-agent $rcv1 $sink1
$ns connect $tcp1 $sink1

set sink2 [new Agent/TCPSink]
$ns attach-agent $src2 $tcp2
$ns attach-agent $rcv2 $sink2
$ns connect $tcp2 $sink2


#Step6: Creating Traffic
#FTP
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1 

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2



#Step7: Post processing procedures
#These files have to be closed at some point. Wecan use a finish procedure to do that
proc finish {} {
	global f1 f2 thrp1 thrp2 temp ns nf tracefile
	puts "Average throughput for src1: [expr $thrp1/$temp] Mbit/s \n"
	puts "Average throughput for src2: [expr $thrp2/$temp] Mbit/s \n"
	puts "Ratio of average throughput of src1 to src2: [expr $thrp1/$thrp2] \n"
	$ns flush-trace
	exec nam out.nam &
	close $f1
	close $f2
	close $nf
	close $tracefile
	#Call xgraph to display result
	#exec xgraph out1.tr out2.tr -geometry 800x400 &
	exit 0
}

# writes the data to the output files
proc record {} {

  global sink1 sink2 f1 f2 thrp1 thrp2 temp

  # get an instance of the simulator 
  set ns [Simulator instance]  

  #set the time after which the procedure would be called again
  set time 0.5  

  #how many bytes have been received by the traffic sinks?
  set bw1 [$sink1 set bytes_]
  set bw2 [$sink2 set bytes_]

  # get the current time
  set now [$ns now]  
  
  # calculate bandwidth in Mbit/s and write it to the files
  puts $f1 "$now [expr $bw1/$time*8/1000000]"
  puts $f2 "$now [expr $bw2/$time*8/1000000]"
  set thrp1 [expr $thrp1+ $bw1/$time*8/1000000 ]
  set thrp2 [expr $thrp2+ $bw2/$time*8/1000000 ]
  set temp [expr $temp + 1]
  
  #Reset the bytes_ values on the traffic sinks
  $sink1 set bytes_ 0
  $sink2 set bytes_ 0
  
  #Re-schedule the procedure
  $ns at [expr $now+$time] "record"

}

#Step8: Start simulation
#Start the simulation
$ns at 100 "record"
$ns at 0 "$ftp1 start"
$ns at 0 "$ftp2 start"
#stop simulation at 400
$ns at 400 "$ftp1 stop"
$ns at 400 "$ftp2 stop"
#calling "finish" procedure
$ns at 400 "finish"

$ns run
