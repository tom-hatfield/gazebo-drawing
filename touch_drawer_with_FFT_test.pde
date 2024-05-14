import processing.sound.*;

FFT fft;
AudioIn in;
Amplitude amp;
int bands = 2048;
float[] spectrum = new float[bands];
boolean drawFFT = false;

int MidiCC0 = 0;
int MidiCC1 = 0;
int MidiCC2 = 0;
int MidiCC3 = 0;
float specLowStart = 0.02; // 3%
float specMidStart = 0.12;  // 12.5%
float specHiStart = 0.25;   // 25%
float specLow = specLowStart; 
float specMid = specMidStart;  
float specHi = specHiStart;  
float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;
import themidibus.*;
MidiBus myBus;
int pointBufferSize = 30000;
PVector[] pointHistory = new PVector[pointBufferSize];

int pointHistoryIndex = 0;
int distthresh = 56;
float myStrokeWeight = 0;
float currentAmp;

void setup() {
  
  fullScreen(P2D, 2);

  background(0);
  strokeWeight(0.4);
  stroke(0, 15);
  smooth();
  cursor(CROSS);
  
  MidiBus.list();  
  MidiBus.availableInputs();
  
  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, bands);
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);  
  // start the Audio Input
  in.start();
  amp.input(in);  
  // patch the AudioIn
  fft.input(in);
}      

void draw() { 
  
  currentAmp = amp.analyze();
  currentAmp *= currentAmp;
  myStrokeWeight = (currentAmp * 1000) + 1 + MidiCC3;
  if(myStrokeWeight > 200)
    myStrokeWeight = 200;
   
  fft.analyze(spectrum);

  scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;
  
  strokeWeight(5);
  stroke(100, 100, 255);
  for(int i = 0; i < bands*specLow; i++)
  {
    scoreLow += spectrum[i];
    //if(drawFFT)
      //line( i*5, height, i*5, height - spectrum[i]*height*5 );
  }
  stroke(100, 255, 100);
  for(int i = (int)(bands*specLow); i < bands*specMid; i++)
  {
    scoreMid += spectrum[i];
    //if(drawFFT)
      //line( i*5, height, i*5, height - spectrum[i]*height*5 );
  }
  stroke(255, 100, 100);
  for(int i = (int)(bands*specMid); i < bands * specHi; i++)
  {
    scoreHi += spectrum[i];
    //if(drawFFT)
      //line( i*5, height, i*5, height - spectrum[i]*height*5 );
  }
  
  scoreLow = scoreLow * 255 + MidiCC2;
  scoreMid = scoreMid * 255 + MidiCC2;
  scoreHi = scoreHi * 255 + MidiCC2;
  if(scoreLow > 255)
    scoreLow = 255;
  if(scoreMid > 255)
    scoreMid = 255;
  if(scoreHi > 255)
    scoreHi = 255;
    
  if(drawFFT){
    strokeWeight(50);
    stroke(scoreLow, scoreLow, scoreLow);
    line(0, 25, 50, 25);
    stroke(scoreMid, scoreMid, scoreMid);
    line(100, 25, 150, 25);
    stroke(scoreHi, scoreHi, scoreHi);
    line(200, 25, 250, 25);
    stroke(scoreHi, scoreMid, scoreLow);
    line(300, 25, 600, 25);
  }
}

void addPoint(int xp, int yp) {

  PVector vCurrent  = new PVector();
  PVector vPrev;
  
  vCurrent.x = xp;
  vCurrent.y = yp;
  
  if(pointHistoryIndex == pointBufferSize)
    pointHistoryIndex = 0;
  if(pointHistoryIndex > 0)
    vPrev = pointHistory[pointHistoryIndex];
    
  pointHistory[pointHistoryIndex++] = vCurrent;

  stroke(scoreHi, scoreMid, scoreLow, 15);
  
  strokeWeight(myStrokeWeight);
  if(pointHistoryIndex > 1)
    line(xp, yp, pointHistory[pointHistoryIndex-2].x, pointHistory[pointHistoryIndex-2].y);
  
  for (int p=0; p < pointHistoryIndex; p++) {
    //println("p hist " + pointHistoryIndex);
    vPrev = pointHistory[p];
    //println(vCurrent, vPrev);
    //println(vCurrent.dist(vPrev));
    if ((vCurrent.dist(vPrev) < distthresh) && (random(1) < 0.5) && (myStrokeWeight < 10)) {
      //println("join");
      line(vCurrent.x, vCurrent.y, vPrev.x, vPrev.y);
    }
  }
}



void mouseDragged() { 
  addPoint(mouseX, mouseY);
}

void controllerChange(int channel, int number, int value) {
  // Here we print the controller number.
  println(channel, number, value);
  if(number == 50)
    specLow = ((float)value / 127.0) * specLowStart;
  if(number == 51)
    specMid = ((float)value / 127.0) * specMidStart;
  if(number == 52)
    MidiCC2 = value;
  if(number == 53)
    MidiCC3 = value;
}

void keyPressed() {
  
  if (key == ' ') {
    background(0);
    pointHistoryIndex = 0;
  }
  if (key == 's') {
    println("key is " + key);
    saveFrame();
  }
  if (key == 'f'){
    drawFFT = !drawFFT;
    if(!drawFFT){
      strokeWeight(50);
      stroke(0, 0, 0);
      line(0, 25, 650, 25);
    }
  }
    
  if (key == 'x') {
    println("key is " + key);
    saveFrame();
    exit();
  }
}
