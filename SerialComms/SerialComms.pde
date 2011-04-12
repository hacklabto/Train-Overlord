/* This sketch details serial communications over USB or XBee:
q    - Query Status
Q    - Query Verbose Status

f    - Move Forwards 1 second
F    - Move Forwards until stopped
b    - Move Backwards 1 second
B    - Move Backwards until stopped
s    - Stop

S    - Stop ALL (Including winch)

u    - Winch up for 1 second
U    - Winch up until home switch reached
m    - Winch down for 1 second
M    - Winch down for 5 seconds
j    - Stop Winch

i    - Toggle IR marker message ("--MARKER--");

a    - Toggle move until IR hit then reverse
R    - Reset
*/

#include <AFMotor.h>

#define DEBUG 0

#define IRSensor A0
#define WinchHomeSwitch A1
//Unused for now
//#define WinchBarrelSwitch A2

#define MarkerIRThreshhold 580

#define SaneResenseTime 2000
#define WinchDeadStopWait 75

#define WheelMotorSpeed 255
#define WinchMotorSpeed 255

#define WinchLoweringDirection FORWARD
#define WinchRaisingDirection BACKWARD

#define WheelForwardDirection FORWARD
#define WheelBackwardDirection BACKWARD


/*
#define MotionStart 0
#define SenseWait 1
#define WinchActionStart 2
#define WinchActionWait 3
*/

//Globals
AF_DCMotor wheelMotor(1, MOTOR12_8KHZ);
AF_DCMotor winchMotor(2, MOTOR12_8KHZ);

//State Globals
boolean winchDown = false;

boolean autoMove = false;

int moveState = 0;
int winchState = 0;

boolean IRMarker = false;

//Time globals
unsigned long winchTime; //Used to wait for the winch to drop.
unsigned long senseTimer; //Used to ride past the marker so we don't sense the same one twice.

int readIR() {
  return analogRead(IRSensor);
}

void winchDeadStop() {
  winchMotor.run(winchDown ? WinchLoweringDirection : WinchRaisingDirection);
  delay(WinchDeadStopWait);
  winchMotor.run(RELEASE);
}

void setup() {
  Serial.begin(9600);
  
  //Set Pins.
  pinMode(IRSensor, INPUT);
  pinMode(WinchHomeSwitch, INPUT);
  
  //Set Motors.
  winchMotor.setSpeed(WinchMotorSpeed);
  winchMotor.run(RELEASE);
  
  wheelMotor.setSpeed(WheelMotorSpeed);
  wheelMotor.run(RELEASE);
  
  
}

void loop() {
  if( int bytes = Serial.available() ) {
    char command = Serial.read();
    switch(command) {
     case 'Q':
       Serial.println("Verbose state query: ");
       break;
       case 'q':
       Serial.println("State query: ");
       
       break;
     case 'f':
       Serial.println("Move forward, 1 second");
       
       break;
     case 'F':
       Serial.println("Move forward until stopped");
   
       break;
     case 'b':
       Serial.println("Move backward, 1 second");
       
       break;
     case 'B':
       Serial.println("Move backward until stopped");
       
       break;
     case 's':
       Serial.println("Stopping all wheel movement");
       
       
       break;
     case 'S':
       Serial.println("Stopping all actions");
       
       
       break;
     case 'u':
       Serial.println("Winch up, 1 second.");
       
       break;
     case 'U':
       Serial.println("Winch up until home.");
       
       break;
     case 'm':
       Serial.println("Winch down, 1 second");
       
       break;
     case 'M':
       Serial.println("Winch down, 5 seconds");
       
       break;
     case 'j':
       Serial.println("Stop winch");
       
       break;
     case 'i':
       //IR marker readout
       
       break;
     case 'a':
       Serial.println("Toggling auto move");
       
       break;
     case 'R':
       Serial.println("Resetting");
       
       break;
    }
    
    Serial.flush();
  }
  
  boolean atMarker = false;
  int irReading = readIR();
  //IR Status Pump
  if(irReading >= MarkerIRThreshhold) {
    atMarker = true;
  }
  
  //Wheel Status Pump
  if(
  
  //Winch Status Pump
  
}
