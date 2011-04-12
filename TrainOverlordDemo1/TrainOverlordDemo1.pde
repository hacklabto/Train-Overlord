/* This demo will see the Train Overlord moving in a loop thusly:
  10 Move to other side of track
  20 Drop Bucket for X seconds
  30 Move to other side of track
  40 Reel in Bucket for X seconds
  50 GOTO 10
*/
  
#include <AFMotor.h>

#define DEBUG 0

#define IRSensor A0
#define WinchHomeSwitch A1
//Unused for now
//#define WinchBarrelSwitch A2

#define MarkerIRThreshhold 560

#define DropLength 8000
#define SaneResenseTime 2000
#define WinchDeadStopWait 100

#define WheelMotorSpeed 255
#define WinchMotorSpeed 200

#define WinchLoweringDirection FORWARD
#define WinchRaisingDirection BACKWARD

#define WheelForwardDirection FORWARD
#define WheelBackwardDirection BACKWARD


//State Definitions
#define MotionStart 0
#define SenseWait 1
#define WinchActionStart 2
#define WinchActionWait 3

//Globals
AF_DCMotor wheelMotor(1, MOTOR12_8KHZ);
AF_DCMotor winchMotor(2, MOTOR12_8KHZ);

//State Globals
int State = -1;
boolean movingForwards = false;
boolean winchDown = false;

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

void winchStartMotion() {
  winchMotor.run(winchDown ? WinchRaisingDirection : WinchLoweringDirection);
}

void setup() {
  
#if DEBUG == 1
   Serial.begin(9600);
   Serial.println("DEMO -1- BEGINS");
#endif
  pinMode(IRSensor, INPUT);
  pinMode(WinchHomeSwitch, INPUT);
  
  //Setup motors.
  wheelMotor.setSpeed(WheelMotorSpeed);
  wheelMotor.run(RELEASE);
  
  winchMotor.setSpeed(WinchMotorSpeed);
  winchMotor.run(RELEASE);
  
  State = MotionStart;
}

void loop() {
  switch(State) {
  
  case MotionStart:
    //Start moving
    wheelMotor.run( winchDown ? WheelBackwardDirection : WheelForwardDirection );
    movingForwards = !winchDown;
    State = SenseWait;
    senseTimer = millis();
    break;
  case SenseWait:
    if(readIR() >= MarkerIRThreshhold && (millis() - senseTimer >= SaneResenseTime)) {
      //Hit a marker 
      //Stop movement
      wheelMotor.run(RELEASE);
      
      //Change to state 2
      State = WinchActionStart;
    }
    break;
  case WinchActionStart:
    winchStartMotion();
    winchTime = millis();
    State = WinchActionWait;
  case WinchActionWait:
    //Waiting for winch to finish moving.
    if(winchDown) {
      //Waiting for winch to reach home.
      if(digitalRead(WinchHomeSwitch)) {
        //Stop winch.
        winchDeadStop();
        
        winchDown = false;
        
        State = MotionStart;
      }
    }
    else {
      //Waiting for timer.
#if DEBUG == 1
   Serial.print("Waiting for drop, millis() - winchTime = ");
   Serial.println(millis() - winchTime);
#endif
      if(millis() - winchTime >= DropLength) {
        //Stop winch.
        winchDeadStop();
        
        winchDown = true;
        
        State = MotionStart;
      }
    }
    break;
  default:
    break;  
  }
}
