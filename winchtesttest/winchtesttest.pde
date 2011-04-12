#include <AFMotor.h>

#define DEBUG 0

//Winch Constants
#define WinchHomeSwitch 8 //Homing Endstop
#define loweringtime 2000 //Time to lower the winch before raising it again in milliseconds
#define loweringDirection FORWARD
#define raisingDirection BACKWARD

#define deadStopReverseTime 100

//Globals
unsigned long winchTime;

//Some booleans to manage the test cycle
boolean running = false;
boolean hitbottom = false;
boolean testOver = false;

//Winch Motor init
AF_DCMotor winchMotor(2, MOTOR12_8KHZ);

void stopWinchRaising() {
  winchMotor.run(loweringDirection);
  delay(deadStopReverseTime);
  winchMotor.run(RELEASE);
}

void setup() {
  
  winchMotor.setSpeed(200); //set the speed to 200/255
  winchMotor.run(RELEASE);
}

void loop() {
  winchMotor.run(FORWARD);
  delay(1000);
  winchMotor.run(BACKWARD);
  delay(1000);
  winchMotor.run(RELEASE);
  delay(1000);
}
