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

L    - turn laser on
l    - turn laser off
t###   - tilt 20-90
p###   - pan 0-165

e#   - play Darth Vader evil sound 1, 2 or 3

i    - Toggle IR marker message ("--MARKER--")

a    - Toggle move until IR hit then reverse
d    - Automatic laser DEMO
R    - Reset
*/

#include <AFMotor.h>
#include <Servo.h>

#define DEBUG 0

#define IRSensor A0
#define WinchHomeSwitch A1 // pull down resistor, switch pulls up.
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

#define EvilSound1 A1
#define EvilSound2 A2
#define EvilSound3 A3

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
AF_DCMotor wheelMotor(3, MOTOR12_8KHZ);
AF_DCMotor winchMotor(4, MOTOR12_8KHZ);

//State Globals
boolean winchDown = false;
boolean winchMoving = false;

boolean moving = false;
boolean movingForward = false;
boolean autoMove = false;
boolean autoLaser = false;
boolean laserOn = false;

int moveState = 0;
int winchState = 0;

boolean atMarker = false;
boolean IRMarkerMessage = false;

int autoAngle;

//Time globals
unsigned long winchTime = 0; //Used to wait for the winch to drop.
unsigned long wheelTime = 0; //Used for timed movement.
unsigned long senseTime = 0; //Used to ride past the marker so we don't sense the same one twice.
unsigned long laserTime = 0; //Used for slowing down the servos in automatic mode

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

void laserDeadStop() {
  laserOn = false;
  autoLaser = false;
  digitalWrite(LaserPowerPin, 0);
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

void autoMoveLaser() {
  laserTime = millis() + 30;
  if (autoLaser){
    laserOn=true;
    autoAngle=autoAngle+3;
    if (autoAngle > 360) autoAngle = 0;
    laserPan.write(90+(30*sin(PI/180.0*(float)autoAngle)));
    laserTilt.write(60+(15*cos(PI/180.0*(float)autoAngle)));
  }

}

void setup() {
  Serial.begin(9600);
  
  //Set Pins.
  pinMode(IRSensor, INPUT);
  pinMode(WinchHomeSwitch, INPUT);

  // initialize the Darth Vader sound board
  pinMode(EvilSound1, OUTPUT);
  pinMode(EvilSound2, OUTPUT);
  pinMode(EvilSound3, OUTPUT);
  digitalWrite(EvilSound1, LOW);
  digitalWrite(EvilSound2, LOW);
  digitalWrite(EvilSound3, LOW);
  
  //Set Motors.
  winchMotor.setSpeed(WinchMotorSpeed);
  winchMotor.run(RELEASE);
  
  wheelMotor.setSpeed(WheelMotorSpeed);
  wheelMotor.run(RELEASE);
  
  laserPan.attach(PanPin);
  laserTilt.attach(TiltPin);
  pinMode(LaserPowerPin,OUTPUT);
  delay(10);
  Serial.println("Finished Booting.");
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
       digitalWrite(LaserPowerPin,0);
       wheelDeadStop();
       winchDeadStop();
       laserDeadStop();
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
     case 'T':
       digitalWrite(LaserPowerPin,1);
       tone(3, 5000, 200); 
       delay(200);
       tone(3,4800,50);
       digitalWrite(LaserPowerPin,0);
       delay(300);
       digitalWrite(LaserPowerPin,1);
       tone(3, 5000, 200); 
       delay(200);
       tone(3,4800,50);
       digitalWrite(LaserPowerPin,0);
       break;
     case 'L':
       // Laser on:
       laserOn=true;
       break;
     case 'l':
       // Laser off
       laserOn=false;
       break;
     case 'p': 
       // Pan (Range: 0 - 165)
       delay(4); // give it a few ms to get the value. 1 / 9600baud * 8bits/byte + 1 * 1000ms/s = 0.94ms / byte + overhead, or 4ms minimum to work....
                 // Ideally, this should take just the pure value of the character, and use a single byte for this....
                 // This should be done at the same time as the web + phone interfaces though.
       if ( Serial.available() >2 )
       {
         char p[3];
          p[0] = Serial.read();
          p[1] = Serial.read();
          p[2] = Serial.read();
          int pan = atoi(p);
          if (pan > 165)
           pan = 165;
          if (pan < 0)
            pan = 0; 
       	  laserPan.write(pan);
	  Serial.print("Panned to:");
	  Serial.println(pan);
       }
       break;
     case 't':
       // Tilt (range: 20 - 110)
       delay(4); // give it a few ms to get the value
       if ( Serial.available() >2 )
       {
         char t[3];
          t[0] = Serial.read();
          t[1] = Serial.read();
          t[2] = Serial.read();
          int tilt = atoi(t);
          if (tilt >110)
           tilt = 110;
          if (tilt < 20)
            tilt = 20; 
       	  laserTilt.write(tilt);
	  Serial.print("Tilted to:");
	  Serial.println(tilt);
       }
       break;
     case 'e': 
       // make Evil sound
       delay(4); // give it a few ms to get the value. 1 / 9600baud * 8bits/byte + 1 * 1000ms/s = 0.94ms / byte + overhead, or 4ms minimum to work....
                 // Ideally, this should take just the pure value of the character, and use a single byte for this....
                 // This should be done at the same time as the web + phone interfaces though.
       if ( Serial.available() >0 )
       {
         char e;
          e = Serial.read();
          int evilnum = atoi(&e);
          if (evilnum == 1)
          {
             digitalWrite(EvilSound1, HIGH);
             delay(10);  // 1ms is probably enough
             digitalWrite(EvilSound1, LOW);
             Serial.println("You have failed me for the last time");
          }
          else if (evilnum == 2)
          {
             digitalWrite(EvilSound2, HIGH);
             delay(10);  // 1ms is probably enough
             digitalWrite(EvilSound2, LOW);
             Serial.println("If you only knew the power of the dark side!");
          }
          else if (evilnum == 3)
          {
             digitalWrite(EvilSound3, HIGH);
             delay(10);  // 1ms is probably enough
             digitalWrite(EvilSound3, LOW);
             Serial.println("I find your lack of faith disturbing!");
          }
       }
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
     case 'd':
       if(autoLaser) {
         Serial.println("Laser demo off");
         laserDeadStop();
       }
       else {
         Serial.println("Laser demo initiated");
         autoLaser = true;
       }
       break;
     case 'R': // Does this even work?
       Serial.println("Resetting");
       asm volatile ("jmp 0x0000"); 
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
  
  // calculate the new laser positions and set the servos
  digitalWrite(LaserPowerPin,laserOn);
  if (autoLaser && laserTime <= millis() )
    autoMoveLaser();
  
}
