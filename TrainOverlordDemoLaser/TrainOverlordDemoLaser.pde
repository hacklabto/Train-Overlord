/* This demo will see the Train Overlord moving back and forth,
    with forth having the laser/servos on, and back having them off
    back and forth being triggered by the IR sensor on the markers
*/
  
#include <AFMotor.h>
#include <Servo.h> 
#include <math.h>

// DC hobby servo
Servo LaserX;
Servo LaserY;

boolean trainDir = false;

#define DEBUG 0

#define IRSensor A0

#define MarkerIRThreshhold 580

#define DropLength 8000
#define SaneResenseTime 2000

#define WheelMotorSpeed 255

#define WheelForwardDirection FORWARD
#define WheelBackwardDirection BACKWARD


//Globals
AF_DCMotor wheelMotor(1, MOTOR12_8KHZ);
unsigned long senseTimer; //Used to ride past the marker so we don't sense the same one twice.

int angle = 0;
int LaserPin = 13;

int readIR() {
  return analogRead(IRSensor);
}


void setup() {
  
#if DEBUG == 1
   Serial.begin(9600);
   Serial.println("DEMO -1- BEGINS");
#endif
  pinMode(IRSensor, INPUT);
  
  //Setup motors.
  wheelMotor.setSpeed(WheelMotorSpeed);
  wheelMotor.run(RELEASE);
  
  LaserX.attach(9);
  LaserY.attach(10);  
  pinMode(LaserPin, OUTPUT);
  digitalWrite(LaserPin, HIGH);
}

void loop() {
  int irReading;

  // move the train (this sometimes causes it to flip direction)
  wheelMotor.run(RELEASE);
  wheelMotor.run( trainDir ? WheelBackwardDirection : WheelForwardDirection );  

  // calculate the new laser positions and set the servos
  if (trainDir){
    angle=angle+2;
    if (angle > 360) angle = 0;
    LaserX.write(90+(30*sin(PI/180.0*(float)angle)));
    LaserY.write(60+(30*cos(PI/180.0*(float)angle)));
  }
  
  // check the IR sensor to see if we're hit the barrier
  // if so, switch the train direction
  irReading = readIR();
  if(irReading >= MarkerIRThreshhold && (millis() - senseTimer >= SaneResenseTime)) {
    trainDir = !trainDir;
    senseTimer = millis();
    digitalWrite(LaserPin, trainDir);
  }

  delay(10);
}
