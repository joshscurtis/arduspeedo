/*
  6-8-10
  Aaron Weiss
  SparkFun Electronics
  
  Example GPS Parser based off of arduiniana.org TinyGPS examples.
  
  Parses NMEA sentences from an EM406 running at 4800bps into readable 
  values for latitude, longitude, elevation, date, time, course, and 
  speed. 
  
  For the SparkFun GPS Shield. Make sure the switch is set to DLINE.
  
  Once you get your longitude and latitude you can paste your 
  coordinates from the terminal window into Google Maps. Here is the 
  link for SparkFun's location.  
  http://maps.google.com/maps?q=40.06477,+-105.20997
  
  Uses the NewSoftSerial library for serial communication with your GPS, 
  so connect your GPS TX and RX pin to any digital pin on the Arduino, 
  just be sure to define which pins you are using on the Arduino to 
  communicate with the GPS module. 
  
  REVISIONS:
  1-17-11 
    changed values to RXPIN = 2 and TXPIN = to correspond with
    hardware v14+. Hardware v13 used RXPIN = 3 and TXPIN = 2.

  3/2012  josh curtis

      added output to my serial seven segment display from sparkfun

   todo's: a toggle switch to show miles since turned on? maybe a notification 
	of some sort once 60 miles is ridden since power on...

  
*/ 

// In order for this sketch to work, you will need to download 
// NewSoftSerial and TinyGPS libraries from arduiniana.org and put them 
// into the hardware->libraries folder in your ardiuno directory.
// Here are the lines of code that point to those libraries.
#include <NewSoftSerial.h>
#include <TinyGPS.h>
//#include <SoftwareSerial.h>

// Define which pins you will use on the Arduino to communicate with your 
// GPS. In this case, the GPS module's TX pin will connect to the 
// Arduino's RXPIN which is pin 3.
#define RXPIN 2
#define TXPIN 3
#define RXPIN2 4
#define TXPIN2 5

//const int txPin2 = 5; // serial output pin
//const int rxPin2 = 4; // unused, but SoftwareSerial needs it...
              
//Set this value equal to the baud rate of your GPS
#define GPSBAUD 4800

// Create an instance of the TinyGPS object
TinyGPS gps;

// Initialize the NewSoftSerial library to the pins you defined above
NewSoftSerial uart_gps(RXPIN, TXPIN);
NewSoftSerial serial_display(RXPIN2,TXPIN2);

// This is where you declare prototypes for the functions that will be 
// using the TinyGPS library.
void getgps(TinyGPS &gps);


// per above, define active segments with a "1":
// 0x3F -> 0011 1111 = 0
// 0x06 -> 0000 0110 = 1
// 0x5B -> 0101 1011 = 2
// 0x4F -> 0100 1111 = 3
// 0x66 -> 0110 0110 = 4
// 0x6D -> 0110 1101 = 5
// 0x7D -> 0111 1101 = 6
// 0x07 -> 0000 0111 = 7
// 0x7F -> 0111 1111 = 8
// 0x6F -> 0110 1111 = 9

// compilation of the numbers above; of course, additional possibilities
// are available for additional letters or symbols
const int digis[10] = {0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F};

//SoftwareSerial mySerial = SoftwareSerial(rxPin2, txPin2);


// In the setup function, you need to initialize two serial ports; the 
// standard hardware serial port (Serial()) to communicate with your 
// terminal program an another serial port (NewSoftSerial()) for your 
// GPS.
void setup()
{
  // This is the serial rate for your terminal program. It must be this 
  // fast because we need to print everything before a new sentence 
  // comes in. If you slow it down, the messages might not be valid and 
  // you will likely get checksum errors.
  Serial.begin(115200);
  //Sets baud rate of your GPS
  uart_gps.begin(GPSBAUD);
  
  Serial.println("");
  Serial.println("GPS Shield QuickStart Example Sketch v12");
  Serial.println("       ...waiting for lock...           ");
  Serial.println("");
  
  // serial display setup
  pinMode(TXPIN2, OUTPUT);  // define the output to the display
  serial_display.begin(9600);   // initialize communication to the display
  serial_display.print(0x76,BYTE); // reset the display
  serial_display.print(0x7A,BYTE); // command byte
  serial_display.print(0x0F,BYTE); // display brightness (lower = brighter)
  //mySerial.print(0x77,BYTE); // command byte for decimal points
  //mySerial.print(0x0F,BYTE); // turn them off for this example
  serial_display.print("w@"); // wB Turn the 2nd dot on. w@ turns all off.
  serial_display.print("----");

}

// This is the main loop of the code. All it does is check for data on 
// the RX pin of the ardiuno, makes sure the data is valid NMEA sentences, 
// then jumps to the getgps() function.
void loop()
{
  while(uart_gps.available())     // While there is data on the RX pin...
  {
      int c = uart_gps.read();    // load the data into a variable...
      if(gps.encode(c))      // if there is a new valid sentence...
      {
        getgps(gps);         // then grab the data.
      }
  }
}

// The getgps function will get and print the values we want.
void getgps(TinyGPS &gps)
{
  // To get all of the data into variables that you can use in your code, 
  // all you need to do is define variables and query the object for the 
  // data. To see the complete list of functions see keywords.txt file in 
  // the TinyGPS and NewSoftSerial libs.
  
  // Define the variables that will be used
  float latitude, longitude;
  // Then call this function
  gps.f_get_position(&latitude, &longitude);
  // You can now print variables latitude and longitude
  Serial.print("Lat/Long: "); 
  Serial.print(latitude,5); 
  Serial.print(", "); 
  Serial.println(longitude,5);
  
  // Same goes for date and time
  int year;
  byte month, day, hour, minute, second, hundredths;
  gps.crack_datetime(&year,&month,&day,&hour,&minute,&second,&hundredths);
  // Print data and time
  Serial.print("Date: "); Serial.print(month, DEC); Serial.print("/"); 
  Serial.print(day, DEC); Serial.print("/"); Serial.print(year);
  Serial.print("  Time: "); Serial.print(hour, DEC); Serial.print(":"); 
  Serial.print(minute, DEC); Serial.print(":"); Serial.print(second, DEC); 
  Serial.print("."); Serial.println(hundredths, DEC);
  //Since month, day, hour, minute, second, and hundr
  
  // Here you can print the altitude and course values directly since 
  // there is only one value for the function
  Serial.print("Altitude (meters): "); Serial.println(gps.f_altitude());  
  // Same goes for course
  Serial.print("Course (degrees): "); Serial.println(gps.f_course()); 
  // And same goes for speed
  Serial.print("Speed(mph): "); Serial.println(gps.f_speed_mph());
  Serial.println();
  
  
  // write to display
  //////////////////////////////////
  int current_speed = gps.f_speed_mph();
    
  char strOut[5] = "0000";

  strOut[0] = '0' + (current_speed /1000);
  strOut[1] = '0' + ((current_speed % 1000) / 100);
  strOut[2] = '0' + ((current_speed % 100) / 10);
  strOut[3] = '0' + (current_speed % 10);
  strOut[4] = '\0';
    
  serial_display.print(strOut);
  Serial.println(strOut);

  // Here you can print statistics on the sentences.
  unsigned long chars;
  unsigned short sentences, failed_checksum;
  gps.stats(&chars, &sentences, &failed_checksum);
  //Serial.print("Failed Checksums: ");Serial.print(failed_checksum);
  //Serial.println(); Serial.println();
}
