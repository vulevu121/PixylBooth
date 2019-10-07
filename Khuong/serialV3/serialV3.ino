#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
 #include <avr/power.h> // Required for 16 MHz Adafruit Trinket
#endif

// Which pin on the Arduino is connected to the NeoPixels?
// On a Trinket or Gemma we suggest changing this to 1:
#define LED_PIN    6

// How many NeoPixels are attached to the Arduino?
#define LED_COUNT 32

// Declare our NeoPixel strip object:
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);


uint8_t red;
uint8_t green;
uint8_t blue;


//String cmd1 = "SetColor(#A6433c)";
//String cmd2 = "ColorSweep(FF0000,2)";
//String cmd3 = "FadeTo(color,duration)";
//Flash(#ffffff,2,1)
//FadeIn(#ffff00,2)

String SetCmd = "SetColor";
String SweepCmd = "ColorSweep";
String FadeInCmd = "FadeIn"; 
String FadeOutCmd = "FadeOut"; 
String FlashCmd = "Flash";
String StopCmd = "Stop"; 
 

String rmParenthesis(String s);
void colorWipe(uint32_t color, int wait);
int charToInt(char c);
void FadeIn(uint32_t color, int duration);
void Stop();
void flash(uint32_t color, double timeOn, double timeOff);
void FadeOut(int duration);
void FadeIn(uint32_t color, int duration);
void sweep(uint32_t color,int wait);



void setup() 
{
    Serial.begin(9600);
    Serial.setTimeout(10);

   // These lines are specifically to support the Adafruit Trinket 5V 16 MHz.
    // Any other board, you can remove this part (but no harm leaving it):
  #if defined(__AVR_ATtiny85__) && (F_CPU == 16000000)
    clock_prescale_set(clock_div_1);
  #endif
    // END of Trinket-specific code.
  
    strip.begin();           // INITIALIZE NeoPixel strip object (REQUIRED)
    strip.show();            // Turn OFF all pixels ASAP
    strip.setBrightness(50); // Set BRIGHTNESS to about 1/5 (max = 255)

//    Serial.println(charToInt('a'));
//    Serial.println(charToInt('f'));

}


//void loop() {
//  FadeIn(strip.Color(255,0,0),4);
//  delay(3000);
//  FadeOut(4);
//  delay(3000);
//  pulseWhite(strip.Color(100,100,0),2,5);
//  delay(2000);
//  pulseWhite(strip.Color(100,100,0),5,5);
//  delay(2000);
//  pulseWhite(strip.Color(100,100,0),8,5);
//  delay(2000);
//}





void loop(){
  while(Serial.available() > 0){
    String input = Serial.readString();
    input = rmParenthesis(input);

    if(input.indexOf(SetCmd) > -1 ){
        Serial.println("setColor command received");
        input.toLowerCase();

//        Serial.println(input);
        char r[3], g[3],b[3]; 
        String num = input.substring(SetCmd.length());
        num.substring(0,2).toCharArray(r,sizeof(r));
        num.substring(2,4).toCharArray(g,sizeof(g));
        num.substring(4,6).toCharArray(b,sizeof(b));


        red = charToInt(r[0]) * 16 + charToInt(r[1]) * 1;
        green = charToInt(g[0]) * 16 + charToInt(g[1]) * 1;
        blue = charToInt(b[0]) * 16 + charToInt(b[1]) * 1;
        colorWipe(strip.Color(red,  green, blue), 0);
            
//      Serial.println(red);     
//      Serial.println(green);
//      Serial.println(blue);


    }else if( input.indexOf(SweepCmd) > -1){
        Serial.println("colorSweep command received");
        input.toLowerCase();

        String param = input.substring(SweepCmd.length());
        Serial.println(param);
        String num = param.substring(0,6);
        float duration = param.substring(7).toFloat() * 1000; 
        Serial.println(num);
        Serial.println(duration);
        
        char r[3], g[3],b[3]; 
        num.substring(0,2).toCharArray(r,sizeof(r));
        num.substring(2,4).toCharArray(g,sizeof(g));
        num.substring(4,6).toCharArray(b,sizeof(b));
        red = charToInt(r[0]) * 16 + charToInt(r[1]) * 1;
        green = charToInt(g[0]) * 16 + charToInt(g[1]) * 1;
        blue = charToInt(b[0]) * 16 + charToInt(b[1]) * 1;
        
        sweep(strip.Color(red, green, blue), duration/LED_COUNT);
    
    }else if( input.indexOf(FlashCmd) > -1 ){
        Serial.println("Flash command received");
        input.toLowerCase();

//        Serial.println(input);
        char r[3], g[3],b[3]; 
        String num = input.substring(FlashCmd.length());
        num.substring(0,2).toCharArray(r,sizeof(r));
        num.substring(2,4).toCharArray(g,sizeof(g));
        num.substring(4,6).toCharArray(b,sizeof(b));
        
        red = charToInt(r[0]) * 16 + charToInt(r[1]) * 1;
        green = charToInt(g[0]) * 16 + charToInt(g[1]) * 1;
        blue = charToInt(b[0]) * 16 + charToInt(b[1]) * 1;
        
        int firstCommaIdx = num.indexOf(",");
        int secondCommaIdx = num.indexOf(",",firstCommaIdx+1);

        double timeOn = num.substring(firstCommaIdx + 1,secondCommaIdx).toDouble();
//        Serial.println(timeOn);

        double timeOff = num.substring(secondCommaIdx + 1).toDouble();
//        Serial.println(timeOff);
        flash(strip.Color(red, green, blue),timeOn,timeOff);
       
    }else if( input.indexOf(FadeInCmd) > -1 ){
        Serial.println("Fade In command received");
        input.toLowerCase();
        char r[3], g[3],b[3]; 
        String num = input.substring(FadeInCmd.length());
        num.substring(0,2).toCharArray(r,sizeof(r));
        num.substring(2,4).toCharArray(g,sizeof(g));
        num.substring(4,6).toCharArray(b,sizeof(b));
        
        red = charToInt(r[0]) * 16 + charToInt(r[1]) * 1;
        green = charToInt(g[0]) * 16 + charToInt(g[1]) * 1;
        blue = charToInt(b[0]) * 16 + charToInt(b[1]) * 1;
        
        int firstCommaIdx = num.indexOf(",");
        double duration = num.substring(firstCommaIdx + 1).toDouble();
        Serial.println(duration);
        FadeIn(red,green,blue,duration);
       
    }else if( input.indexOf(FadeOutCmd) > -1 ){
       Serial.println("Fade Out command received");
       input.toLowerCase();
       int duration = input.substring(FadeOutCmd.length()).toInt();
//       red = 255;
//       green = 255;
//       blue = 0;
//       colorWipe(strip.Color(red,  green, blue), 0);
       FadeOut(duration);
       
    }else if( input.indexOf(StopCmd) > -1 ){
       Serial.println("Stop command received");
       Stop();
    }else{
       Serial.println("unknown command:");
       Serial.println(input);
    }
  }
}

int charToInt(char c){

  switch(c){
    case '0': return 0; break;
    case '1': return 1; break;
    case '2': return 2; break;
    case '3': return 3; break;
    case '4': return 4; break;
    case '5': return 5; break;
    case '6': return 6; break;
    case '7': return 7; break;
    case '8': return 8; break;
    case '9': return 9; break;
    case 'a': return 10; break;
    case 'b': return 11; break;
    case 'c': return 12; break;
    case 'd': return 13; break;
    case 'e': return 14; break;
    case 'f': return 15; break;
    default: return -1;
  }
}

String rmParenthesis(String s){
  bool done = false;

//  Serial.println(s);
  while(!done){
    int x = s.indexOf("(");
    if(x > 0){s.remove(x,1);}

    int y = s.indexOf(")");
    if(y > 0){s.remove(y,1);}

    int z = s.indexOf("#");
    if(z > 0){s.remove(z,1);}
    if(x < 0 && y < 0 && z < 0){done = true;}
  }
    return s;

}

void colorWipe(uint32_t color, int wait) {
  for(int i=0; i<strip.numPixels(); i++) { // For each pixel in strip...
    strip.setPixelColor(i, color);         //  Set pixel's color (in RAM)
    strip.show();                          //  Update strip to match
    delay(wait);                           //  Pause for a moment
  }
}

void sweep(uint32_t color,int wait){
    while (true){
        for(int i=0; i<strip.numPixels(); i++) { // For each pixel in strip...
          strip.setPixelColor(i, color);         //  Set pixel's color (in RAM)
          strip.show();                          //  Update strip to match
          delay(wait);                           //  Pause for a moment
          if(Serial.available()>0){
              Stop();
              return;
            }
        }
        Stop();
}
}

void Stop() {
  for (int i = 0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, 0, 0, 0);
    }
        strip.show();
}



void flash(uint32_t color, double timeOn, double timeOff){
  while (true){

    for (int i = 0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, color);
    }
   strip.show();

   if(Serial.available()>0){
        Stop();
        return;
    }
   delay(timeOn*1000);
   
    if(Serial.available()>0){
        Stop();
        return;
    }
   Stop();
   delay(timeOff*1000);
  }
}


void FadeOut(int duration){

  uint8_t rate = 1; 
  int num_step = duration * 1000 / rate; 
  int wait = duration * 1000/strip.numPixels();
  for (int j = 255; j > 0; j--) {
      red = max(red - rate,0);
      green = max(green - rate,0);  // make sure the value always greater than 0
      blue = max(blue - rate,0);
    for (int i = 0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, red, green, blue);
    }
    strip.show();
    delay( duration * 1000 / 255);
  }
}



void FadeIn(uint8_t red, uint8_t green, uint8_t blue, int duration){

  // Use max value of each color (255) as the reference point
  int red_offset = red - 255;
  int green_offset = green - 255;
  int blue_offset = blue - 255;
  int wait = duration * 1000.0/254;
  
  // iterate each value from 0 -> 255 and subtract the offset

  for (int j = 0; j < 256; j++) {
    red = max(j + red_offset,0);
    green = max(j + green_offset,0);  // make sure the value always greater than 0
    blue = max(j + blue_offset,0);
    for (int i = 0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, red, green, blue);
    }
    strip.show();
    delay(wait);
  }
}
