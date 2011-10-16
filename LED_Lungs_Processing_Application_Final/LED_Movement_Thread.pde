//for timing
int movementDelay = 120;
int movementDelayModifier = 30;

public class LED_Movement_Thread implements Runnable {
  Thread thread;

  public LED_Movement_Thread(PApplet parent) {
    parent.registerDispose(this);
  }

  public void start() {
    thread = new Thread(this);
    thread.start();
  }

  /* these three methods run in sequence, since there is delays in each breathIn and breathOut the finished will never
   be called until it is actually finished */
  public void run() {
    breathIn();
    breathOut();
    threadFinished();
  }

  public void stop() {
    thread = null;
  }

  // this will magically be called by the parent once the user hits stop
  // this functionality hasn't been tested heavily so if it doesn't work, file a bug
  public void dispose() {
    stop();
  }
} 

//for in visual
void breathIn() {

  if (movementDelayModifier > 15) {
    filePlayer1.play();
  }
  else if (movementDelayModifier < 15) {
    filePlayer3.play();
  }

  if (testMode == false) {
    myPort.write(1);
  }

  testStage1 = true;

  delay(movementDelay + movementDelayModifier);

  if (testMode == false) {
    myPort.write(2);
  }

  testStage2 = true;

  delay(movementDelay + movementDelayModifier*2);

  if (testMode == false) {
    myPort.write(3);
  }

  testStage3 = true;

  delay(movementDelay + movementDelayModifier*3);

  if (testMode == false) {  
    myPort.write(4);
  }

  testStage4 = true;

  delay(movementDelay + movementDelayModifier*4);

  if (testMode == false) { 
    myPort.write(5);
  }

  testStage5 = true;

  delay(movementDelay + movementDelayModifier*5);

  if (testMode == false) { 
    myPort.write(6);
  }

  testStage6 = true;

  delay(movementDelay + movementDelayModifier*6);

  if (testMode == false) {
    myPort.write(7);
  }

  testStage7 = true;

  delay(movementDelay + movementDelayModifier*7);

  if (testMode == false) { 
    myPort.write(8);
  }
  testStage8 = true;

  delay(movementDelay + movementDelayModifier*8);

  filePlayer1.pause();
  filePlayer1.rewind();
  filePlayer3.pause();
  filePlayer3.rewind();
}

//for out visual
void breathOut() {

   if (movementDelayModifier > 15) {
    filePlayer2.play();
  }
  else if (movementDelayModifier < 15) {
    filePlayer4.play();
  }

  if (testMode == false) {
    myPort.write(9);
  }

  testStage8 = false;

  delay(movementDelay + movementDelayModifier*8);

  if (testMode == false) {
    myPort.write(10);
  }

  testStage7 = false;

  delay(movementDelay + movementDelayModifier*7);

  if (testMode == false) {
    myPort.write(11);
  }

  testStage6 = false;

  delay(movementDelay + movementDelayModifier*6);

  if (testMode == false) {
    myPort.write(12);
  }

  testStage5 = false;

  delay(movementDelay + movementDelayModifier*5);

  if (testMode == false) {
    myPort.write(13);
  }

  testStage4 = false;

  delay(movementDelay + movementDelayModifier*4);

  if (testMode == false) {
    myPort.write(14);
  }
  testStage3 = false;

  delay(movementDelay + movementDelayModifier*3);

  if (testMode == false) {
    myPort.write(15);
  }

  testStage2 = false;

  delay(movementDelay + movementDelayModifier*2);

  if (testMode == false) {
    myPort.write(16);
  }

  testStage1 = false;

  delay(movementDelay + movementDelayModifier);

  filePlayer2.pause();
  filePlayer2.rewind();
  filePlayer4.pause();
  filePlayer4.rewind();
  
}

