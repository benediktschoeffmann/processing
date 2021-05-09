import processing.sound.*;

char currentKey = 'a';
String notes = "awsdrftghujik";
float[][] pitches = {
  { 110.0000, 116.5409, 123.4708, 130.8128, 138.5913, 146.8324, 155.5635, 164.8138, 174.6141, 184.9972, 195.9977, 207.6523}, 
  { 220.0000, 233.0819, 246.9417, 261.6256, 277.1826, 293.6648, 311.1270, 329.6276, 349.2282, 369.9944, 391.9954, 415.3047}, 
  { 440.0000, 466.1638, 493.8833, 523.2511, 554.3653, 587.3295, 622.2540, 659.2551, 698.4565, 739.9888, 783.9909, 830.6094}, 
  { 880.0000, 932.3275, 987.7666, 1046.5023, 1108.7305, 1174.6591, 1244.5079, 1318.5102, 1396.9129, 1479.9777, 1567.9817, 1661.2188}
};
String[] tools = {
  "Pulse Width",
  "Low Pass Filter"
  //,
  // "Delay"
};

int currentOctave = 0;
int currentOscillator = 0;
int currentTool = 0;

float pulseWidth;
float delayTime, maxDelayTime = 20.0f;

Oscillator[] oscs = new Oscillator[5];
LowPass lowPass;
float filterFrequency;

FFT fft;
int fftBands = 512;

// Delay delay;

void setup() {
  size(640, 360);
  background(255);
  
  Sound s = new Sound(this);
  s.volume(0.5);
  
  fft = new FFT(this, 512);
  
  oscs[0] = new SinOsc(this);
  oscs[1] = new TriOsc(this);
  oscs[2] = new SawOsc(this);
  oscs[3] = new SqrOsc(this);
  
  Pulse pulse = new Pulse(this);
  pulse.width(0.1);
  oscs[4] = pulse;
  
  fft.input(oscs[currentOscillator]);
  
  lowPass = new LowPass(this);
  
  lowPass.process(oscs[currentOscillator], setFilterFrequency(mouseX));
  
  // delay = new Delay(this);
  
}

void setPulseWidth(float w) {
  w = constrain(w, 0, width);
  w = map(w, 0, width, 0.0, 1.0);
  ((Pulse) oscs[4]).width(w);
}


float delay(float delayTime) {
  /*
  if (currentTool != 2) {
    delay.feedback(0);
  } else {
    delay.feedback(0.5);
    delayTime = constrain(delayTime, 0, width);
    delayTime = map(delayTime, 0, width, 0, maxDelayTime);
    delay.process(oscs[currentOscillator], delayTime);
  }
  
  return delayTime;
  */ 
  return 0;
  
}

float setFilterFrequency(float f) {
   f = constrain(f, 0, width);
   filterFrequency = map(f, 0, width, 80.0, 22000.0);
   lowPass.freq(filterFrequency);
   return filterFrequency;
}

void filter() {
  if (currentTool != 1) {
    lowPass.stop();
  }
  
  
  if (currentTool == 1) {
    lowPass.stop();
    lowPass.process(oscs[currentOscillator], setFilterFrequency(mouseX));
  }
}

void keyPressed() {
  currentKey = key;
  int index = notes.indexOf(currentKey);
  if (index > -1 && index < notes.length()) {
    oscs[currentOscillator].freq(pitches[currentOctave][index]);
    oscs[currentOscillator].play();
    return;
  }
  if (key == '1') {
    currentTool = (++currentTool) % tools.length;
    currentTool = processTool(currentTool);
  }
  
}

void keyReleased() {
  if (key == currentKey) {
    oscs[currentOscillator].stop();
  }
}

void mouseMoved() {
  currentOctave = (int) map(mouseY, 0, height, 0, pitches.length);
  currentOctave = abs(currentOctave - pitches.length) % pitches.length;
  
  currentTool = processTool(currentTool);

  
  print ("Tool: " + tools[currentTool]);
  println (mouseX + ":" + mouseY);
}

int processTool(int currentTool) {
    switch (currentTool) {
      case 0: // PWM
        setPulseWidth(mouseX);
        //delay(mouseX);
        //filter();
        break;
      case 1:
        filter();
        // delay(mouseX);
        break;
        /*
      case 2:
        filter();
        delay(mouseX);
        break;
      */
      default:
        println("unknown value:" + currentTool);
        break;
        
    }
    
    return currentTool;
}

void mouseClicked() {
  oscs[currentOscillator].stop();
  currentOscillator = (currentOscillator + 1) % oscs.length;
  oscs[currentOscillator].play();
  
  processTool(currentTool);
  fft.input(oscs[currentOscillator]);
}

void draw() {
  // Draw frequency spectrum.
  background(125, 255, 125);
  fill(255, 0, 150);
  noStroke();

  fft.analyze();

  float r_width = width/float(fftBands);

  for (int i = 0; i < fftBands; i++) {
    rect( i*r_width, height, r_width, -fft.spectrum[i]*height);
  }

  // Display the name of the oscillator class.
  textSize(32);
  fill(0);
  float verticalPosition = map(currentOscillator, -1, oscs.length, 0, height);
  text(oscs[currentOscillator].getClass().getSimpleName(), 0, verticalPosition);
  
  // Display the name of the currentTool
  verticalPosition = map(currentTool, -1, tools.length, 0, height);
  text(tools[currentTool], width * 0.6, verticalPosition);
}
