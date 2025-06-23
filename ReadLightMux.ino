#include <Wire.h>
#include "Adafruit_VEML7700.h"

// PCA9547D I2C multiplexer configuration
#define SDA_PIN 13
#define SCL_PIN 14
#define PCA9547D_ADDR 0x70  // Confirmed I2C address

// Structure to hold sensor information
struct SensorInfo {
  int channel;
  bool isInitialized;
  Adafruit_VEML7700 sensor;
};

// Array to store sensors found on different channels
SensorInfo sensors[8];
int sensorCount = 0;

// Function declarations
void testPCA9547D();
void scanAllChannelsForVEML7700();
void scanChannelDevices(int channel);
bool selectChannel(int channel);
void disableAllChannels();
bool initVEML7700OnChannel(int channel);
void readAllVEML7700Sensors();
void readVEML7700OnChannel(int channel);

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("PCA9547D I2C Multiplexer - Multi VEML7700 Scanner");
  Serial.println("==================================================");
  
  // Initialize I2C with custom pins for multiplexer
  Wire.begin(SDA_PIN, SCL_PIN);
  Wire.setClock(100000); // 100kHz I2C clock
  
  Serial.printf("Multiplexer I2C initialized with SDA: %d, SCL: %d\n", SDA_PIN, SCL_PIN);
  
  // Initialize sensor array
  for (int i = 0; i < 8; i++) {
    sensors[i].channel = i;
    sensors[i].isInitialized = false;
  }
  
  // Test PCA9547D communication
  testPCA9547D();
  
  // Scan all channels for VEML7700 sensors
  Serial.println("\nScanning all multiplexer channels for VEML7700 sensors:");
  scanAllChannelsForVEML7700();
  
  Serial.printf("\nFound %d VEML7700 sensor(s) total\n", sensorCount);
  
  if (sensorCount > 0) {
    Serial.println("Setup complete! Starting sensor readings...");
  } else {
    Serial.println("⚠️  No VEML7700 sensors found. Check connections!");
  }
}

void loop() {
  if (sensorCount > 0) {
    Serial.println("\n=== Reading All VEML7700 Sensors ===");
    readAllVEML7700Sensors();
    delay(3000); // Wait 3 seconds before next reading cycle
  } else {
    Serial.println("No sensors to read. Waiting...");
    delay(5000);
  }
}

void testPCA9547D() {
  Serial.println("\nTesting PCA9547D communication...");
  
  // Try to communicate with the multiplexer at confirmed address 0x70
  Wire.beginTransmission(PCA9547D_ADDR);
  byte error = Wire.endTransmission();
  
  if (error == 0) {
    Serial.printf("✓ PCA9547D confirmed at address 0x%02X\n", PCA9547D_ADDR);
    
    // Read current channel selection
    Wire.requestFrom(PCA9547D_ADDR, 1);
    if (Wire.available()) {
      byte currentChannel = Wire.read();
      Serial.printf("Current channel register: 0x%02X\n", currentChannel);
      
      if (currentChannel & 0x08) {
        int activeChannel = currentChannel & 0x07;
        Serial.printf("Active channel: %d\n", activeChannel);
      } else {
        Serial.println("No channel currently selected");
      }
    }
  } else {
    Serial.printf("✗ Communication error with PCA9547D at 0x%02X (error: %d)\n", PCA9547D_ADDR, error);
    Serial.println("Check SDA/SCL connections and pull-up resistors!");
  }
}

void scanAllChannelsForVEML7700() {
  sensorCount = 0;
  
  for (int channel = 0; channel < 8; channel++) {
    Serial.printf("\nScanning Channel %d:\n", channel);
    
    // Select channel (bit 3 = enable, bits 2-0 = channel)
    if (!selectChannel(channel)) {
      Serial.printf("  ✗ Failed to select channel %d\n", channel);
      continue;
    }
    
    Serial.printf("  ✓ Channel %d selected successfully\n", channel);
    
    // Scan for devices on this channel
    scanChannelDevices(channel);
    
    // Check specifically for VEML7700 at address 0x10
    Wire.beginTransmission(0x10);
    byte error = Wire.endTransmission();
    
    if (error == 0) {
      Serial.printf("  ✓ VEML7700 detected on channel %d\n", channel);
      
      // Try to initialize the VEML7700 on this channel
      if (initVEML7700OnChannel(channel)) {
        Serial.printf("  ✓ VEML7700 on channel %d initialized successfully\n", channel);
        sensors[channel].isInitialized = true;
        sensorCount++;
      } else {
        Serial.printf("  ✗ Failed to initialize VEML7700 on channel %d\n", channel);
        sensors[channel].isInitialized = false;
      }
    }
  }
  
  // Disable all channels after scanning
  disableAllChannels();
}

void scanChannelDevices(int channel) {
  int deviceCount = 0;
  
  for (byte addr = 1; addr < 127; addr++) {
    // Skip the multiplexer's address (0x70)
    if (addr == 0x70) continue;
    
    Wire.beginTransmission(addr);
    byte error = Wire.endTransmission();
    
    if (error == 0) {
      Serial.printf("    Device found at 0x%02X", addr);
      if (addr == 0x10) {
        Serial.print(" (VEML7700)");
      }
      Serial.println();
      deviceCount++;
    }
  }
  
  if (deviceCount == 0) {
    Serial.println("    No devices found on this channel");
  } else {
    Serial.printf("    Total devices found: %d\n", deviceCount);
  }
}

// Helper function to select a specific channel
bool selectChannel(int channel) {
  if (channel < 0 || channel > 7) {
    Serial.println("Invalid channel! Must be 0-7");
    return false;
  }
  
  byte channelSelect = 0x08 | channel;
  Wire.beginTransmission(PCA9547D_ADDR);
  Wire.write(channelSelect);
  byte error = Wire.endTransmission();
  
  return (error == 0);
}

// Helper function to disable all channels
void disableAllChannels() {
  Wire.beginTransmission(PCA9547D_ADDR);
  Wire.write(0x00);
  Wire.endTransmission();
}

// Initialize VEML7700 on a specific channel
bool initVEML7700OnChannel(int channel) {
  // Select the channel
  if (!selectChannel(channel)) {
    Serial.printf("Failed to select channel %d\n", channel);
    return false;
  }
  
  // Initialize the VEML7700 using the Adafruit library
  if (!sensors[channel].sensor.begin(&Wire)) {
    Serial.printf("VEML7700 not found on channel %d\n", channel);
    return false;
  }
  
  // Configure sensor settings (optional - uses good defaults if not set)
  sensors[channel].sensor.setGain(VEML7700_GAIN_1);
  sensors[channel].sensor.setIntegrationTime(VEML7700_IT_100MS);
  
  Serial.printf("Channel %d VEML7700 - Gain: ", channel);
  switch (sensors[channel].sensor.getGain()) {
    case VEML7700_GAIN_1: Serial.println("1"); break;
    case VEML7700_GAIN_2: Serial.println("2"); break;
    case VEML7700_GAIN_1_4: Serial.println("1/4"); break;
    case VEML7700_GAIN_1_8: Serial.println("1/8"); break;
  }
  
  Serial.printf("Channel %d VEML7700 - Integration Time (ms): ", channel);
  switch (sensors[channel].sensor.getIntegrationTime()) {
    case VEML7700_IT_25MS: Serial.println("25"); break;
    case VEML7700_IT_50MS: Serial.println("50"); break;
    case VEML7700_IT_100MS: Serial.println("100"); break;
    case VEML7700_IT_200MS: Serial.println("200"); break;
    case VEML7700_IT_400MS: Serial.println("400"); break;
    case VEML7700_IT_800MS: Serial.println("800"); break;
  }
  
  // Set thresholds and enable interrupts if needed
  sensors[channel].sensor.setLowThreshold(10000);
  sensors[channel].sensor.setHighThreshold(20000);
  sensors[channel].sensor.interruptEnable(true);
  
  return true;
}

// Read all initialized VEML7700 sensors
void readAllVEML7700Sensors() {
  for (int channel = 0; channel < 8; channel++) {
    if (sensors[channel].isInitialized) {
      Serial.printf("\nReading VEML7700 on Channel %d:\n", channel);
      readVEML7700OnChannel(channel);
      delay(100); // Small delay between sensor readings
    }
  }
}

// Read VEML7700 data from a specific channel
void readVEML7700OnChannel(int channel) {
  // Select channel before reading
  if (!selectChannel(channel)) {
    Serial.printf("Failed to select channel %d for reading\n", channel);
    return;
  }
  
  // Read sensor data using Adafruit library
  uint16_t als_raw = sensors[channel].sensor.readALS();
  uint16_t white_raw = sensors[channel].sensor.readWhite();
  float lux = sensors[channel].sensor.readLux();
  
  // Display results
  Serial.printf("  Raw ALS: %d (0x%04X)\n", als_raw, als_raw);
  Serial.printf("  Raw White: %d (0x%04X)\n", white_raw, white_raw);
  Serial.printf("  Lux: %.2f\n", lux);
  
  // Check if we're getting all zeros (potential issue)
  if (als_raw == 0 && white_raw == 0) {
    Serial.println("  ⚠️  WARNING: Getting all zeros - check connections!");
  }
  
  // Light level description
  if (lux < 1) {
    Serial.println("  Light Level: Very Dark");
  } else if (lux < 10) {
    Serial.println("  Light Level: Dark");
  } else if (lux < 100) {
    Serial.println("  Light Level: Dim");
  } else if (lux < 1000) {
    Serial.println("  Light Level: Normal Indoor");
  } else if (lux < 10000) {
    Serial.println("  Light Level: Bright Indoor");
  } else {
    Serial.println("  Light Level: Very Bright/Outdoor");
  }
  
  // Check for interrupt conditions
  uint16_t irq = sensors[channel].sensor.interruptStatus();
  if (irq & VEML7700_INTERRUPT_LOW) {
    Serial.println("  ** Low threshold triggered");
  }
  if (irq & VEML7700_INTERRUPT_HIGH) {
    Serial.println("  ** High threshold triggered");
  }
}