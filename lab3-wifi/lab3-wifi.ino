#include <ESP8266WiFi.h>
#include <time.h>

#define WIFI_SSID "UI-DeviceNet"
#define WIFI_PASSWORD "UI-DeviceNet"

// for time stamp
int timezone = 5;
int dst = 0;

void setup() {
  // put your setup code here, to run once:
  // Start the Serial Monitor
  Serial.begin(9600);

   Serial.print("MAC: ");

   Serial.println(WiFi.macAddress());

   wifiConnect();
}

void loop() {
  // put your main code here, to run repeatedly:

  time_t now = time(nullptr);

  Serial.println(ctime(&now));

}

void wifiConnect()
{

  WiFi.mode(WIFI_STA);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);             // Connect to the network

  Serial.print("Connecting to ");

  Serial.print(WIFI_SSID); Serial.println(" ...");



  int teller = 0;

  while (WiFi.status() != WL_CONNECTED)

  {                                       // Wait for the Wi-Fi to connect

    delay(1000);

    Serial.print(++teller); Serial.print(' ');

  }



  Serial.println('\n');

  Serial.println("Connection established!");  

  Serial.print("IP address:\t");

  Serial.println(WiFi.localIP());         // Send the IP address of the ESP8266 to the computer



  

  configTime(19 * 3600, 0, "pool.ntp.org", "time.nist.gov");

  Serial.println("\nWaiting for time");

  while (!time(nullptr)) {

    Serial.print(".");

    delay(1000);

  }

}
