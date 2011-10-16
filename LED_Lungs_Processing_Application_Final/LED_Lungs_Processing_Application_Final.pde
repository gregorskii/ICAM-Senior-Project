
/**
 Greg Parsons
 ICAM Senior Thesis Project
 
 This project Utilizes a custom made LED Matrix Display created from scratch over the course of two quarters at UCSD.
 
 The project uses the Arduino to both control the LED Matrix display and manipulate the "breathing" visual on the display
 using the distance from a PING sensor.
 
 The distance is restricted to 80 inches from the display at start, to up to 1 inch away from the work. As the viewer gets closer to
 the display the the display "breathes" faster. 
 
 There is an implementation of a TEST use of the processing program that avoids any reference to the Arduino. This method is
 in place to allow manipulation of the code without having the display in front of the programmer.
 
 Included in test mode is a ControlP5 slider to adjust the modifier value without the need for the Arduino range. 
 
 This function is turned on by setting the boolean testMode to True.  
 */

/**IMPORT STATEMENTS */

//TEST MODE
import controlP5.*;

//SOUND
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
import ddf.minim.spi.*; 

//SERIAL
import processing.serial.*;
Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
float delayValueFromArduino = 0;

/** VARIABLES */

//TEST MODE
boolean testMode = true;
ControlP5 controlP5;

//SLOW COMPUTER MODE
boolean slowComputer = false;

//SOUND
Minim minim;
AudioOutput out;
FilePlayer filePlayer1;
FilePlayer filePlayer2;
FilePlayer filePlayer3;
FilePlayer filePlayer4;
Constant bitCrushValue;
BitCrush bitCrush;
Summer sum;

//ARDUINO
boolean isArduinoCommunicating = false;

//THREADS
boolean threadDone = true;
int numberOfThreadsRun = 0;

//VISUALS
boolean testStage1, testStage2, testStage3, testStage4, testStage5, testStage6, testStage7, 
testStage8;

//TEXT
PFont fontA;

void setup () {

  //PROCESSING WINDOW
  size (800, 600);

  //TEXT
  fontA = loadFont("Monospaced-48.vlw");
  textFont(fontA, 16);

  //SERIAL
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 57600);

  //TEST MODE
  if (testMode == true) {
    controlP5 = new ControlP5(this);
    controlP5.addSlider("Modifier", 10, 40, 10, 330, 50, 100, 10);
    println("YOU ARE RUNNING IN TEST MODE");
  }

  //SOUND
  minim = new Minim( this );
  out = minim.getLineOut( Minim.STEREO, 512 );

  //INITIALIZE SOUNDS
  AudioRecordingStream breatheInSlow = minim.loadFileStream( "breath in slow.wav", 1024, true);  
  AudioRecordingStream breatheOutSlow = minim.loadFileStream( "breath out slow.wav", 1024, true);  
  
  AudioRecordingStream breatheInFast = minim.loadFileStream( "breath in medium.wav", 1024, true);  
  AudioRecordingStream breatheOutFast = minim.loadFileStream( "breath out medium.wav", 1024, true);  

  //PLAY SOUNDS THEN IMMEDIATELY STOP, SINCE PLAY IS AUTOMATIC                        
  filePlayer1 = new FilePlayer( breatheInSlow );
  filePlayer2 = new FilePlayer( breatheOutSlow );
  filePlayer3 = new FilePlayer( breatheInFast );
  filePlayer4 = new FilePlayer( breatheOutFast );
  filePlayer1.pause();
  filePlayer2.pause();
  filePlayer3.pause();
  filePlayer4.pause();

  //SOUND SETUP
  out = minim.getLineOut();
  sum = new Summer();
  bitCrush = new BitCrush(16.f);
  bitCrushValue = new Constant(16.f);
  bitCrushValue.patch( bitCrush.bitRes );

  //PATCH IT ALL TOGETHER
  filePlayer1.patch( sum );
  filePlayer2.patch( sum );
  filePlayer3.patch( sum );
  filePlayer4.patch( sum );
  sum.patch( bitCrush ).patch( out );
}

void draw () {

  //PROCESSING
  background(120);

  //first check if we are running in test mode to determine if a call to serial read is even needed
  if (testMode == false) {
    readFromSerial();
  }

  /*check to see if the arduino is communicating, and also that we are not in test mode before
   setting the new modifier value to affect the local delay value in processing */
  if ((isArduinoCommunicating == true) && (testMode == false)) {
    if (val < 80) {
      delayValueFromArduino = map(val, 0, 75, 0, 30);
      movementDelayModifier = ((int)delayValueFromArduino);
      bitCrushValue.setConstant( map(val, 80, 1, 16.f, 8.f));
    }
    else {
      movementDelayModifier = 30;
      bitCrushValue.setConstant( 16.f );
    }

    fill(255);
    text("Arduino is Communicating", 20, 20);
    text("modifier = " + movementDelayModifier, 20, 40);
    text("Ping Distance: " + val, 20, 60);
  }

  /* values to setup visually whether the system is communicating with arduino or if it is 
   in test mode */
  if ((isArduinoCommunicating == false) && (testMode == false)) {
    fill(255);
    text("Arduino is not Communicating", 20, 20);
  }

  if (testMode == true) {
    fill(255);
    text("YOU ARE RUNNING IN TEST MODE! NO ARDUINO COM", 20, 20);
    text("modifier = " + movementDelayModifier, 20, 40);
  }

  /* if we are indeed communicating or running in test mode, initialize the LED Movement Threads */
  if ((isArduinoCommunicating == true) || (testMode == true)) {
    if ( threadDone == true) {
      initThread();
      numberOfThreadsRun++;
    }
  }

  //thread visuals
  if (threadDone == false) {
    fill(255);
    text("The thread is running.", 20, 80);
  }
  else {
    fill(255);
    text("The thread is not running.", 20, 80);
  }

  fill(255);
  text("Number of Threads Started = " + numberOfThreadsRun, 500, 80);

  //visual representations of the actions of the display, disabled by slow computer mode

  if (!slowComputer) {
    if (filePlayer1.isPlaying()) {
      text("inhaling", 350, 500);
    }


    if (filePlayer2.isPlaying()) {
      text("exhaling", 350, 550);
    }

    //for testing -- this is the visuals on the actual processing app
    strokeWeight(5);

    /* for the visuals that run on screen to show what the display itself is doing, more useful for test mode, but it
     also will run when the display is actually on */
    if (testStage1 == true) {
      stroke(0, 255, 0);
    }
    else {
      stroke(255);
    }

    line(42*8, height*(0.75), 42*8, height*(0.25)); //L1
    line(420+42*1, height*(0.75), 420+42*1, height*(0.25)); //R1

    if (testStage2 == true) {
      stroke(0, 255, 0);
    }
    else {
      stroke(255);
    }

    line(42*7, height*(0.75), 42*7, height*(0.25)); //L2
    line(420+42*2, height*(0.75), 420+42*2, height*(0.25)); //R2


    if (testStage3 == true) {
      stroke(0, 255, 0);
    }
    else {
      stroke(255);
    }
    line(42*6, height*(0.75), 42*6, height*(0.25)); //L3
    line(420+42*3, height*(0.75), 420+42*3, height*(0.25)); //R3


    if (testStage4 == true) {
      stroke(0, 255, 0);
    }
    else {
      stroke(255);
    }

    line(42*5, height*(0.75), 42*5, height*(0.25)); //L4
    line(420+42*4, height*(0.75), 420+42*4, height*(0.25)); //R4

    if (testStage5 == true) {
      stroke(0, 255, 0);
    }
    else {
      stroke(255);
    }

    line(42*4, height*(0.75), 42*4, height*(0.25)); //L5
    line(420+42*5, height*(0.75), 420+42*5, height*(0.25)); //R5

      if (testStage6 == true) {
      stroke(0, 255, 0);
    }
    else {
      stroke(255);
    }

    line(42*3, height*(0.75), 42*3, height*(0.25)); //L6
    line(420+42*6, height*(0.75), 420+42*6, height*(0.25)); //R6

    if (testStage7 == true) {
      stroke(0, 255, 0);
    }
    else {
      stroke(255);
    }

    line(42*2, height*(0.75), 42*2, height*(0.25)); //L7
    line(420+42*7, height*(0.75), 420+42*7, height*(0.25)); //R7

    if (testStage8 == true) {
      stroke(0, 255, 0);
    }
    else {
      stroke(255);
    }

    line(42*1, height*(0.75), 42*1, height*(0.25)); //L8
    line(420+42*8, height*(0.75), 420+42*8, height*(0.25)); //R8
  }
}

/* method to initialize the thread and set the boolean value telling the system that a new thread can be
 created to false */
void initThread() {
  threadDone = false;
  LED_Movement_Thread tt = new LED_Movement_Thread(this);
  tt.start();
}

//if a thread is finished allow a new one to be made
void threadFinished()
{
  threadDone = true;
}

//for serial communication, also sets wether arduino is communicating
void readFromSerial() {
  while (myPort.available () >= 3) {
    val = myPort.read();
    //System.out.println(val);
  }
  if (val != 0) {
    isArduinoCommunicating = true;
  }
  else {
    isArduinoCommunicating = false;
  }
}

//for slider in test mode
void Modifier(int theModifierValue) {
  movementDelayModifier = theModifierValue;
}

//this is called so that when the program is stopped the display goes back into standby mode
void stop() {  
  // close the AudioOutput
  out.close();
  // we must also close our file player so the underlying stream can be closed properly
  filePlayer1.close();
  filePlayer2.close();
  filePlayer3.close();
  filePlayer4.close();
  // stop the minim object
  minim.stop();
  // stop the processing object
  super.stop();

  if (testMode == false) {
    myPort.write(17);
  }
}

