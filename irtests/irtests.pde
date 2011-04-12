#define IRPIN A0

int reading;
int readingAv[8]; //Circular buffer
byte nextRead = 0;

void setup() {
  pinMode(IRPIN, INPUT);
  
  Serial.begin(9600);
}

void loop() {
  /*for(int i = 0; i < 8; i++) {
    readingAv[nextRead] = analogRead(IRPIN);
    
    //Advance nextRead
    nextRead = (nextRead + 1) % 7;
    delay(60);
  }
  
  //Take Average
  int acc;
  for(int i; i < 8; i++) {
    acc += readingAv[i];
  }
  float average = (float)acc / 8.0;
  */
  
  reading = analogRead(IRPIN);
  Serial.println(reading);
  
  delay(600);
}
