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

i    - Toggle IR marker message ("--MARKER--")

a    - Toggle move until IR hit then reverse
R    - Reset
*/

#include <AFMotor.h>
#include <Servo.h>

#define DEBUG 0

#define IRSensor A0
#define WinchHomeSwitch A1
//Unused for now
//#define WinchBarrelSwitch A2

#define MarkerIRThreshhold 585


#define SaneResenseTime 1200
#define WinchDeadStopWait 75

#define WheelMotorSpeed 255
#define WinchMotorSpeed 255

#define WinchLoweringDirection FORWARD
#define WinchRaisingDirection BACKWARD

#define WheelForwardDirection FORWARD
#define WheelBackwardDirection BACKWARD

#define LaserPowerPin  2
#define PanPin 10
#define TiltPin 9
Servo laserPan;
Servo laserTilt;
int pan=90;
int tilt=90;


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
boolean winchMoving = false;

boolean moving = false;
boolean movingForward = false;
boolean autoMove = false;

int moveState = 0;
int winchState = 0;

boolean atMarker = false;
boolean IRMarkerMessage = false;

//Time globals
unsigned long winchTime = 0; //Used to wait for the winch to drop.
unsigned long wheelTime = 0; //Used for timed movement.
unsigned long senseTime = 0; //Used to ride past the marker so we don't sense the same one twice.

int readIR() {
  return analogRead(IRSensor);
}

void winchDeadStop() {
  if(winchMoving) {
    winchMotor.run(winchDown ? WinchLoweringDirection : WinchRaisingDirection);
    delay(WinchDeadStopWait);
    winchMotor.run(RELEASE);
    winchMoving = false;
    Serial.println("Winch Stopped");
  }
}

void wheelDeadStop() {
  if(moving) {
    wheelMotor.run(RELEASE);
    moving = false;
    Serial.println("Movement Stopped");
    senseTime = 0;
    wheelTime = 0;
  }
  autoMove = false;
}

void move(boolean forward, unsigned long time) {
  if(!autoMove)
    wheelDeadStop();
  moving = true;
  movingForward = forward ? true : false ;
  wheelMotor.run( forward ? WheelForwardDirection : WheelBackwardDirection );
  
  senseTime = millis() + SaneResenseTime;
  wheelTime = time;
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
  
  laserPan.attach(PanPin);
  laserTilt.attach(TiltPin);
  pinMode(LaserPowerPin,OUTPUT);
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
       move(true, millis() + 1000);
       break;
     case 'F':
       Serial.println("Move forward until stopped");
       move(true, 0);
       break;
     case 'b':
       Serial.println("Move backward, 1 second");
       move(false, millis() + 1000);
       break;
     case 'B':
       Serial.println("Move backward until stopped");
       move(false, 0);
       break;
     case 's':
       wheelDeadStop();
       break;
     case 'S':
       Serial.println("FullStop!");
       
       wheelDeadStop();
       winchDeadStop();
       break;
     case 'u':
       Serial.println("Winch up, 1 second.");
       winchTime = millis() + 1000;
       winchMoving = true;
       winchDown = true;
       winchMotor.run(WinchRaisingDirection);
       break;
     case 'U':
       Serial.println("Winch up until home.");
       winchTime = 0;
       winchMoving = true;
       winchDown = true;
       winchMotor.run(WinchRaisingDirection);
       break;
     case 'm':
       Serial.println("Winch down, 1 second");
       winchTime = millis() + 1000;
       winchMoving = true;
       winchDown = false;
       winchMotor.run(WinchLoweringDirection);
       break;
     case 'M':
       Serial.println("Winch down, 5 seconds");
       winchTime = millis() + 5000;
       winchMoving = true;
       winchDown = false;
       winchMotor.run(WinchLoweringDirection);
       break;
     case 'j':
       winchDeadStop();
       break;
     case 'i':
       //IR marker readout
       IRMarkerMessage = !IRMarkerMessage;
       break;
     case 'L':
       // Laser on:
       digitalWrite(LaserPowerPin,1);
       break;
     case 'l':
       // Laser off
       digitalWrite(LaserPowerPin,0);
       break;
     case 'p': 
       // Pan-
       pan-=5;
       if (pan<0)
         pan=0;
       laserPan.write(pan);
       Serial.print("Pan: ");
       Serial.println(pan);
       break;
     case 'P':
       // Pan+
       pan+=5;
       if (pan >165)
         pan=165;
       laserPan.write(pan);
       Serial.print("Pan: ");
       Serial.println(pan);
       break;
     case 't':
       // Tilt-
       tilt-=5;
       if (tilt < 20)
         tilt=20;
       laserTilt.write(tilt);
       Serial.print("Tilt: ");
       Serial.println(tilt);
       break;
     case 'T':
       // Tilt+
       tilt+=5;
       if (tilt>90)
         tilt=90;
       laserTilt.write(tilt);
       Serial.print("Tilt: ");
       Serial.println(tilt);
       break;
     case 'a':
       Serial.println("Toggling auto move");
       if(autoMove) {
         wheelDeadStop();
       }
       else {
         autoMove = true;
         move(movingForward, 0);
         
       }
       break;
     case 'R':
       //Serial.println("Resetting");
       
       break;
    }
    
    Serial.flush();
  }
  
  atMarker = false;
  int irReading = readIR();
  //IR Status Pump
  if(irReading >= MarkerIRThreshhold) {
    atMarker = true;
  }
  
  //Wheel Status Pump
  if(wheelTime && millis() >= wheelTime) {
    wheelDeadStop();
  }
  else if(atMarker && millis() >=  senseTime) {
    if(autoMove) {
      //Reverse direction
      move(!movingForward, 0);
    } 
    else {
      //Stop
      wheelDeadStop();
      movingForward = !movingForward;
    }
    
    if(IRMarkerMessage) {
      Serial.println("--MARKER--");
    }
  }
  
  //Winch Status Pump
  if(winchMoving) {
    if((winchDown && digitalRead(WinchHomeSwitch)) || (winchTime != 0 && millis() >= winchTime) ) {
      winchDeadStop();
    }
  }
  
}
