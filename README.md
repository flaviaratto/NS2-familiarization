# NS2-familiarization

ECEN602 Simulation Assignment 
1. Flavia Ratto
2. Eric Lloyd Robles

## Assignment Overview
1. Create a simulator object, check the correct number of arguments and set the TCP flavor and case number from the command line arguments.
2. Set up of tracefiles and throughput parameters.
3. Create the network topology as per the assignment specifications - define nodes, links, delay parameter as per the case number, node color and position.
4. Set up of the TCP connection as per the TCP flavor value in the input.Create receiver sinks and connect them.
5. Set up FTP application traffic.
6. Create post processing procedures - record and finish.
   record procedure is called to calculate throughput for both the sources the sources in itervals of 0.5s and the total throughput for both the sources until that time.
   finish procedure is called at 400s to calculate and display the average throughput at both the sources, the ratio, close all the files and execute the NAM file in the background, and to exit the program.
7. Set up of simulation parameters sources to start the application at time = 0 and end at time = 400. The record procedure is called at 100 and finish procedure is called at 400.  

## Steps to compile and run
Type in terminal:
  ```
  ns ns2.tcl <TCP_flavor> <case_no>
  ```
Here, TCP_flavor - VEGAS or SACK, case_no - 1, 2 or 3.
  ```
  Example - ns ns2.tcl VEGAS 3
  ```

**Note:** - The code is written in C and is compiled and tested in a Linux environment. Code referred from the TA's recitation slides and referrences.
