#include <AFMotor.h>

AF_DCMotor motor1(1, MOTOR12_8KHZ);

void setup() {
  motor1.setSpeed(200);
  motor1.run(RELEASE);
}

void loop() {
  motor1.run(FORWARD);
  delay(1000);
  motor1.run(BACKWARD);
  delay(1000);
  motor1.run(RELEASE);
  delay(1000);
}
