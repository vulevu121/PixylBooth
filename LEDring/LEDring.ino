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



//SetColor(#ff00ff);
//ColorSweep(FF0000,2);
//FadeTo(color,duration);
//Flash(#a6433c,2,2)

String SetCmd = "SetColor";
String SweepCmd = "ColorSweep";
String FadeInCmd = "FadeIn"; 
String FadeOutCmd = "FadeOut"; 
String FlashCmd = "Flash";
String StopCmd = "Stop"; 
 

String rmParenthesis(String s);
void colorWipe(uint32_t color, int wait);

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

}


void Stop() {
  for (int i = 0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, 0, 0, 0);
    }
        strip.show();
}

//void flashWhite(uint32_t color, float frequency, unsigned long duration){
//  unsigned long start = millis();
//  unsigned long now;
//  do{
//    now = millis();
//    for (int i = 0; i < strip.numPixels(); i++) {
//      strip.setPixelColor(i, color);
//    }
//    strip.show();
//    delay(1000.0/frequency/2);
//   Stop();
//   delay(1000.0/frequency/2);
////   Serial.println((now - start));
////   Serial.println(duration * 1000);
//  }while((now - start) < duration * 1000);  
//     Stop();
//}


void flashWhite(uint32_t color, int timeOn, int timeOff){
  while (true){
    for (int i = 0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, color);
    }
   strip.show();
   delay(timeOn*1000);
   Stop();
   delay(timeOff*1000);
  }
}

void FadeOut(int duration){
  uint16_t i, j;

  for (j = 255; j > 1; j--) {
    for (i = 0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, j, j, j);
    }
    strip.show();
    delay(duration * 1000.0/254);
  }  
}

void FadeIn(uint32_t color, int duration){
  uint16_t i, j;

  for (j = 5; j < 255; j++) {
    for (i = 0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, j, j, j);
    }
    strip.show();
    delay(duration * 1000.0/254);
  }
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


//String SetCmd = "SetColor";
//String SweepCmd = "ColorSweep";
//String FadeInCmd = "FadeIn"; 
//String FadeOutCmd = "FadeOut"; 
//String FlashCmd = "Flash";
//String StopCmd = "Stop"; 


void loop(){
  while(Serial.available() > 0){
    String input = Serial.readString();
    input = rmParenthesis(input);

    if(input.indexOf(SetCmd) > -1 ){
        Serial.println("setColor command received");

//        Serial.println(input);
        char r[3], g[3],b[3]; 
        String num = input.substring(SetCmd.length());
        num.substring(0,2).toCharArray(r,sizeof(r));
        num.substring(2,4).toCharArray(g,sizeof(g));
        num.substring(4,6).toCharArray(b,sizeof(b));
  //      Serial.println(r);
        uint8_t red = strtol(r,NULL,16);
  //      Serial.println(red);     
        uint8_t green = strtol(g,NULL,16);
  //      Serial.println(green);
        uint8_t blue = strtol(b,NULL,16);
  //      Serial.println(blue);
        colorWipe(strip.Color(red,  green, blue), 0);
    

    }else if( input.indexOf(SweepCmd) > -1){
       Serial.println("colorSweep command received");
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
        uint8_t red = strtol(r,NULL,16);
        uint8_t green = strtol(g,NULL,16);
        uint8_t blue = strtol(b,NULL,16);
        colorWipe(strip.Color(red, green, blue), duration/LED_COUNT);
    
    }else if( input.indexOf(FlashCmd) > -1 ){
       Serial.println("Flash command received");
//        Serial.println(input);
        char r[3], g[3],b[3]; 
        String num = input.substring(FlashCmd.length());
        num.substring(0,2).toCharArray(r,sizeof(r));
        num.substring(2,4).toCharArray(g,sizeof(g));
        num.substring(4).toCharArray(b,sizeof(b));
        int firstCommaIdx = num.indexOf(",");
        int timeOn = num.substring(firstCommaIdx,1).toInt();
        Serial.println(timeOn);
        int secondCommaIdx = num.indexOf(",",firstCommaIdx+1);

        int timeOff = num.substring(secondCommaIdx,1).toInt();
        Serial.println(timeOff);


  //      Serial.println(r);
        uint8_t red = strtol(r,NULL,16);
  //      Serial.println(red);     
        uint8_t green = strtol(g,NULL,16);
  //      Serial.println(green);
        uint8_t blue = strtol(b,NULL,16);
  //      Serial.println(blue);
        colorWipe(strip.Color(red,  green, blue), 0);
    
       
    }else if( input.indexOf(FadeInCmd) > -1 ){
       Serial.println("Fade In command received");
    }else if( input.indexOf(FadeOutCmd) > -1 ){
       Serial.println("Fade Out command received");
    }else if( input.indexOf(StopCmd) > -1 ){
       Serial.println("Stop command received");
       Stop();
    }else{
       Serial.println("unknown command:");
       Serial.println(input);
    }
  }
}

String rmParenthesis(String s){
  bool done = false;

//  Serial.println(s);
  while(!done){
    int x = s.indexOf("(");
    int y = s.indexOf(")");
    int z = s.indexOf("#");
//    Serial.println(x);
//    Serial.println(y);
    if(x > 0){s.remove(x,1);}
    if(y > 0){s.remove(y,1);}
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
