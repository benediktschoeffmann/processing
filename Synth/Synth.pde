import processing.sound.*;

char currentKey = 'a';
String notes = "awsdrftghujik";
float[][] pitches = {
  { 110.0000, 116.5409, 123.4708, 130.8128, 138.5913, 146.8324, 155.5635, 164.8138, 174.6141, 184.9972, 195.9977, 207.6523}, 
  { 220.0000, 233.0819, 246.9417, 261.6256, 277.1826, 293.6648, 311.1270, 329.6276, 349.2282, 369.9944, 391.9954, 415.3047}, 
  { 440.0000, 466.1638, 493.8833, 523.2511, 554.3653, 587.3295, 622.2540, 659.2551, 698.4565, 739.9888, 783.9909, 830.6094}, 
  { 880.0000, 932.3275, 987.7666, 1046.5023, 1108.7305, 1174.6591, 1244.5079, 1318.5102, 1396.9129, 1479.9777, 1567.9817, 1661.2188}
};
int currentOctave = 0;
int currentOscillator = 0;
float pulseWidth;

Oscillator[] oscs = new Oscillator[5]; 

FFT fft;
int fftBands = 512;

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
}



void keyPressed() {
  currentKey = key;
  int index = notes.indexOf(currentKey);
  if (index > -1 && index < notes.length()) {
    oscs[currentOscillator].freq(pitches[currentOctave][index]);
    oscs[currentOscillator].play();
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
  ((Pulse) oscs[4]).width(map(mouseX, 0, width, 0.0, 1.0)); 
  keyPressed();
  
  
  println (mouseX + ":" + mouseY);
}

void mouseClicked() {
  oscs[currentOscillator].stop();
  currentOscillator = (currentOscillator + 1) % oscs.length;
  
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
}
