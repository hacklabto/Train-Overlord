#include <AFMotor.h>

//Winch Motor init
AF_DCMotor winchMotor(2, MOTOR12_8KHZ);

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
