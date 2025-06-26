// run this, modifying ssid/password as needed
// 

#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>

#define AOUT_PIN 36

const char* ssid = "sUpBr0 (2)";
const char* password = "JustinBieber";

WebServer server(80);

int lastMoistureValue = 0;
String lastStatus = "unknown";
unsigned long lastReadTime = 0;
const unsigned long interval = 1000; // 5 seconds

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);

  Serial.print("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nConnected!");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());

  server.on("/moisture", HTTP_GET, []() {
    StaticJsonDocument<200> doc;
    doc["value"] = lastMoistureValue;
    doc["status"] = lastStatus;

    String json;
    server.sendHeader("Access-Control-Allow-Origin", "*");  // ADD THIS LINE
    serializeJson(doc, json);
    server.send(200, "application/json", json);
  });

  server.begin();
  Serial.println("Server started");
}

void loop() {
  server.handleClient();

  unsigned long now = millis();
  if (now - lastReadTime >= interval) {
    lastReadTime = now;
    lastMoistureValue = analogRead(AOUT_PIN);
    lastStatus = lastMoistureValue > 2200 ? "dry" : "wet";

    Serial.print("Updated moisture: ");
    Serial.print(lastMoistureValue);
    Serial.print(" - ");
    Serial.println(lastStatus);
  }
}
