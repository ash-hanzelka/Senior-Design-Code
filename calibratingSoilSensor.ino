#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>



#define AOUT_PIN 36 // ESP32 pin GPIO36 (ADC0) that connects to AOUT pin of moisture sensor



void setup() {
  
  Serial.begin(115200);

}


void loop() {
  int value = analogRead(AOUT_PIN); // read the analog value from sensor

  Serial.print("Moisture value: ");
  Serial.print(value);
  if(value > 2200) {
    Serial.println(" dry");
  }
  else {
    Serial.println(" wet");
  }

  delay(500);
}
