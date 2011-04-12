#include <AFMotor.h>

#define DEBUG 1

//Winch Constants
#define WinchHomeSwitch 8 //Homing Endstop
#define loweringtime 2000 //Time to lower the winch before raising it again in milliseconds
#define loweringDirection FORWARD
#define raisingDirection BACKWARD

#define deadStopReverseTime 100

//Winch Motor init
AF_DCMotor winchMotor(2, MOTOR12_8KHZ);

//Globals
unsigned long winchTime;

//Some booleans to manage the test cycle
boolean running = false;
boolean hitbottom = false;
boolean testOver = false;

AF_DCMotor motor1(1, MOTOR12_8KHZ); //create motor #1, 64KHz pwm

void setup() {
  
  motor1.setSpeed(200); //set the speed to 200/255
  motor1.run(RELEASE);
  
  //Setup buttons
  pinMode(WinchHomeSwitch, INPUT);
  
  #if DEBUG == 1
    Serial.begin(9600);
    Serial.println("Setup Finished");
  #endif
}

void loop() {
  if(running) {
    if(hitbottom) {
      //We're moving upwards.
      if(digitalRead(WinchHomeSwitch)) {
        //We've hit home, run stop sequence.
        stopWinchRaising();
        
        testOver = true;
        running = false;
        #if DEBUG == 1
          Serial.println("Test Finished: Homing button hit");
        #endif
        }
    }
    else {
      //We're still moving downwards, do time check.
      if((millis() - winchTime) >= loweringtime) {
        //Reverse direction
        #if DEBUG == 1
          Serial.println("Hit Bottom, beginning to raise again.");
        #endif
        hitbottom = true;
        winchMotor.run(raisingDirection);
      }
    }
  }
  else if(!testOver){
    #if DEBUG == 1
      Serial.println("Test Begins, lowering");
    #endif
    //Start the test.
    running = true;
    winchTime = millis();
    winchMotor.run(loweringDirection);
  }
}
