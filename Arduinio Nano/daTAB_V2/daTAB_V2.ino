
String btName = "AT+NAMEdaTAB0002";
String btPin = "AT+PIN1234";

int foot_sw = 6;
int buzzer = 13;


int req = 5; //mic REQ line goes to pin 5 through q1 (arduino high pulls request line low)
int dat = 2; //mic Data line goes to pin 2
int clk = 3; //mic Clock line goes to pin 3

int i = 0;
int j = 0;
int k = 0;
int signCh = 8;
int sign = 0;
int decimal;
float dpp;
int units;

byte mydata[14];
String value_str;
long value_int; //was an int, could not measure over 32mm
float value;

String units_str;
String result;
//-----------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------------------
void setup() 
{
  Serial.begin(9600);

  pinMode(buzzer, OUTPUT);
  
  pinMode(req, OUTPUT);
  pinMode(clk, INPUT_PULLUP);
  pinMode(dat, INPUT_PULLUP);

  pinMode(LED_BUILTIN, OUTPUT);
  
  digitalWrite(req,LOW); // set request at high

  pinMode(foot_sw, INPUT);
  
  digitalWrite(buzzer,HIGH);  // ON

  // Rename and change PIN code
  //Serial.println(btName);
  delay(1000);
  digitalWrite(buzzer, LOW);  // OFF
  delay(200);
  digitalWrite(buzzer,HIGH);  // ON
  //Serial.println(btPin);
  delay(1000);
  digitalWrite(buzzer, LOW);  // OFF

  //Serial.println("daTAB V2.0");
}

//-----------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------------------
void read_micrometer()
{
  digitalWrite(req, HIGH); // generate set request
  digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
   
  for(i = 0; i < 13; i++) 
  {
    k = 0;
    for (j = 0; j < 4; j++) 
    {
      while( digitalRead(clk) == LOW) {} // hold until clock is high
      while( digitalRead(clk) == HIGH){} // hold until clock is low
      bitWrite(k, j, (digitalRead(dat) & 0x1));
    }
    mydata[i] = k;
  }
  
  
  sign = mydata[4];
  value_str = String(mydata[5]) + String(mydata[6]) + String(mydata[7]) + String(mydata[8] + String(mydata[9] + String(mydata[10]))) ;
  decimal = mydata[11];
  units = mydata[12];

  if(units == 0)
  {
    units_str = ",mm";
  }
  else
  {
    units_str = ",inch";
  }
  
  value_int = value_str.toInt();
  
  if (decimal == 0) dpp = 1.0;
  if (decimal == 1) dpp = 10.0;
  if (decimal == 2) dpp = 100.0;
  if (decimal == 3) dpp = 1000.0;
  if (decimal == 4) dpp = 10000.0;
  if (decimal == 5) dpp = 100000.0;
  
  value = value_int / dpp;

  result = String(value) + units_str;
  
  if (sign == 0) 
  {
    //Serial.print(value,decimal);
    Serial.print(result);
  }
  if (sign == 8) {
    result = "-" + result;
    Serial.print(result);
    
    //Serial.print("-"); 
    //Serial.println(value,decimal);
  }
  
  digitalWrite(req,LOW);
  digitalWrite(LED_BUILTIN, LOW);    // turn the LED off by making the voltage LOW
}
//-----------------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------------------------
void loop() 
{
  

    if ( digitalRead(foot_sw) == HIGH) // Pressed
    {
      delay(100);
      while (digitalRead(foot_sw) == LOW) // Unpress
      {    
        read_micrometer();  
        digitalWrite(buzzer, HIGH); // ON
        delay(50);
        digitalWrite(buzzer, LOW); // OFF   
        break;
      }
    }
    else
    {
       //digitalWrite(buzzer, LOW); // OFF
    }  

    /*digitalWrite(LED_BUILTIN, LOW); 
    delay(100);
    digitalWrite(LED_BUILTIN, HIGH); 
    delay(100);*/
}
