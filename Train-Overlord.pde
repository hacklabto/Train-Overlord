#define RED 1100
#define GREEN 1010
#define BLUE 1001
#define YELLOW 1110
#define PURPLE 1101
#define TEAL 1011
#define WHITE 1111

#define BACKMULTI 1.0
#define FWDMULTI 1.1

class LED
{
  public:
    LED(int,int,int);
    void setColor(int);
    
    int PinRed;  
    int PinGreen;
    int PinBlue;

};

LED::LED (int pinR, int pinG, int pinB) { 
  PinGreen = pinG;
  PinBlue = pinB;
  PinRed = pinR;
}  

void LED::setColor(int color) {
  switch(color) {
     case RED:
     digitalWrite(PinRed, LOW);
     digitalWrite(PinGreen, HIGH);
     digitalWrite(PinBlue, HIGH);
     break;
    case YELLOW:
     digitalWrite(PinRed, LOW);
     digitalWrite(PinGreen, LOW);
     digitalWrite(PinBlue, HIGH);
     break; 
   case PURPLE:
     digitalWrite(PinRed,LOW);
     digitalWrite(PinGreen, HIGH);
     digitalWrite(PinBlue, LOW);
     break;      
   case WHITE:
     digitalWrite(PinRed, LOW);
     digitalWrite(PinGreen, LOW);
     digitalWrite(PinBlue, LOW);
     break;
   case TEAL:
     digitalWrite(PinRed, HIGH);
     digitalWrite(PinGreen, LOW);
     digitalWrite(PinBlue, LOW);
     break;         
   case GREEN:
     digitalWrite(PinRed, HIGH);
     digitalWrite(PinGreen, LOW);     
     digitalWrite(PinBlue, HIGH);
     break;
   case BLUE:
     digitalWrite(PinRed, HIGH);
     digitalWrite(PinGreen, HIGH);     
     digitalWrite(PinBlue, LOW);
     break;  
  }
} 

#include <AFMotor.h>

LED myLED(3,4,5); 
AF_DCMotor motor1(1, MOTOR12_8KHZ); //create motor #1, 64KHz pwm

void setup()
{ 
  motor1.setSpeed(200); //set the speed to 200/255
  motor1.run(RELEASE);
  pinMode(myLED.PinRed, OUTPUT);
  pinMode(myLED.PinGreen, OUTPUT);
  pinMode(myLED.PinBlue, OUTPUT);
  
  digitalWrite(myLED.PinRed, HIGH);
  digitalWrite(myLED.PinGreen, HIGH);  
  digitalWrite(myLED.PinBlue, HIGH);
}


void loop()
{  
  myLED.setColor(GREEN);
  motor1.run(FORWARD);
  motor1.setSpeed(255);
  delay(16000);
  motor1.run(RELEASE);
  myLED.setColor(BLUE);
  delay(500);  
  myLED.setColor(RED);
  motor1.run(BACKWARD);
  motor1.setSpeed(255);
  delay(16000);
  motor1.run(RELEASE);
  myLED.setColor(TEAL);
  delay(500); 
}

 
   
