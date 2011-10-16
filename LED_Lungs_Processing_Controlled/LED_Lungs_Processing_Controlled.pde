//We always have to include the library
#include "LedControl.h"

/*
 Now we need a LedControl to work with.
 ***** These pin numbers will probably not work with your hardware *****
 pin 12 is connected to the DataIn 
 pin 11 is connected to the CLK 
 pin 10 is connected to LOAD 
 We have only a single MAX72XX.
 */
LedControl lc=LedControl(12,11,10,2);

// this constant won't change.  It's the pin number
// of the sensor's output:
const int pingPin = 7;

//Serial Variables
int delayValueFromSerial = 0;         // incoming serial byte

//variables to simplify addressing one row / column in each matrix
int L1 = 7, L2 = 6, L3 = 5, L4 = 4, L5 = 3, L6 = 2, L7 = 1, L8 = 0; 
int R1 = 0, R2 = 1, R3 = 2, R4 = 3, R5 = 4, R6 = 5, R7 = 6, R8 = 7;

//variables to simplify the matrix panel being called
int rightMatrix = 0, leftMatrix = 1;

void setup() {
  // initialize serial communication:
  Serial.begin(57600);

  /*
   The MAX72XX is in power-saving mode on startup,
   we have to do a wakeup call
   */
  lc.shutdown(0,false);
  /* Set the brightness to a medium values */
  lc.setIntensity(0,10);
  /* and clear the display */
  lc.clearDisplay(0);

  lc.shutdown(1,false);
  /* Set the brightness to a medium values */
  lc.setIntensity(1,10);
  /* and clear the display */
  lc.clearDisplay(1);
}

void loop() { 

  //ping sensor

  // establish variables for duration of the ping, 
  // and the distance result in inches and centimeters:
  long duration, inches, cm;

  // The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  pinMode(pingPin, OUTPUT);
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);

  // The same pin is used to read the signal from the PING))): a HIGH
  // pulse whose duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(pingPin, INPUT);
  duration = pulseIn(pingPin, HIGH);

  // convert the time into a distance
  inches = microsecondsToInches(duration);
  cm = microsecondsToCentimeters(duration);

  //sending the distance value out on serial
  Serial.write(inches);

  //delay so that the reporting of the distance is not more than once per second
  delay(10);

  // if we get a valid byte, read analog ins:
  if (Serial.available() > 0) {
    // get incoming byte:
    delayValueFromSerial = 0;
    delayValueFromSerial = Serial.read();
    // delay 10ms to let the ADC recover:
    delay(10);
  }

  if (delayValueFromSerial == 0) {
    noSerialDisplay();
    }

    //switch statement for setting the Matrix Leds based on serial input
    switch (delayValueFromSerial) {
    case 1:
      breathInStage1();
      break;
    case 2:
      breathInStage2();
      break;
    case 3:
      breathInStage3();
      break;
    case 4:
      breathInStage4();
      break;
    case 5:
      breathInStage5();
      break;
    case 6:
      breathInStage6();
      break;
    case 7:
      breathInStage7();
      break;
    case 8:
      breathInStage8();
      break;
    case 9:
      breathOutStage1();
      break;
    case 10:
      breathOutStage2();
      break;
    case 11:
      breathOutStage3();
      break;
    case 12:
      breathOutStage4();
      break;
    case 13:
      breathOutStage5();
      break;
    case 14:
      breathOutStage6();
      break;
    case 15:
      breathOutStage7();
      break;
    case 16:
      breathOutStage8();
      break;
    case 17:
      noSerialDisplay();
      break;
    }
}

//methods for the breathing in visual
void breathInStage1() {
  lc.setColumn(rightMatrix, R1, 24);
  lc.setColumn(leftMatrix, L1, 24);
}

void breathInStage2() {
  lc.setColumn(rightMatrix, R2, 60);
  lc.setColumn(leftMatrix, L2, 60);
}

void breathInStage3() {
  lc.setColumn(rightMatrix, R3, 126);
  lc.setColumn(leftMatrix, L3, 126);
}

void breathInStage4() {
  lc.setColumn(rightMatrix, R4, 255);
  lc.setColumn(leftMatrix, L4, 255);
}

void breathInStage5() {
  lc.setColumn(rightMatrix, R5, 255);
  lc.setColumn(leftMatrix, L5, 255);
}

void breathInStage6() {
  lc.setColumn(rightMatrix, R6, 255);
  lc.setColumn(leftMatrix, L6, 255);
}

void breathInStage7() {
  lc.setColumn(rightMatrix, R7, 255);
  lc.setColumn(leftMatrix, L7, 255);
}

void breathInStage8() {
  lc.setColumn(rightMatrix, R8, 126);
  lc.setColumn(leftMatrix, L8, 126);
}

//methods for the breathing out visual
void breathOutStage1() {
  lc.setColumn(rightMatrix, R8, 0);
  lc.setColumn(leftMatrix, L8, 0);
}

void breathOutStage2() {
  lc.setColumn(rightMatrix, R7, 0);
  lc.setColumn(leftMatrix, L7, 0);
}

void breathOutStage3() {
  lc.setColumn(rightMatrix, R6, 0);
  lc.setColumn(leftMatrix, L6, 0);
} 

void breathOutStage4() {
  lc.setColumn(rightMatrix, R5, 0);
  lc.setColumn(leftMatrix, L5, 0);
}

void breathOutStage5() {
  lc.setColumn(rightMatrix, R4, 0);
  lc.setColumn(leftMatrix, L4, 0);
}

void breathOutStage6() {
  lc.setColumn(rightMatrix, R3, 0);
  lc.setColumn(leftMatrix, L3, 0);
}

void breathOutStage7() {
  lc.setColumn(rightMatrix, R2, 0);
  lc.setColumn(leftMatrix, L2, 0);
}

void breathOutStage8() {
  lc.setColumn(rightMatrix, R1, 0);
  lc.setColumn(leftMatrix, L1, 0);
}

void noSerialDisplay() {
  lc.setColumn(rightMatrix, R1, 129);
  lc.setColumn(leftMatrix, L1, 129);
  lc.setColumn(rightMatrix, R8, 129);
  lc.setColumn(leftMatrix, L8, 129);

  lc.setColumn(rightMatrix, R4, 24);
  lc.setColumn(rightMatrix, R5, 24);
  lc.setColumn(leftMatrix, L4, 24);
  lc.setColumn(leftMatrix, L5, 24);
}


//ping sensor caluclating methods
long microsecondsToInches(long microseconds)
{
  // According to Parallax's datasheet for the PING))), there are
  // 73.746 microseconds per inch (i.e. sound travels at 1130 feet per
  // second).  This gives the distance travelled by the ping, outbound
  // and return, so we divide by 2 to get the distance of the obstacle.
  // See: http://www.parallax.com/dl/docs/prod/acc/28015-PING-v1.3.pdf
  return microseconds / 74 / 2;
}

long microsecondsToCentimeters(long microseconds)
{
  // The speed of sound is 340 m/s or 29 microseconds per centimeter.
  // The ping travels out and back, so to find the distance of the
  // object we take half of the distance travelled.
  return microseconds / 29 / 2;
}

















