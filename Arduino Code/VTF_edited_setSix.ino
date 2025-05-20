/*
  Orignally: TactorGlove.pde
  This code allows serial port command processing for the 12 channel Tactor Glove
  Based onL http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1251426835

  Now: Gathers input from MATLAB and interprets results to send to vibration motors

  Authors:
  R. Scheidt PhD
    03/31/12
  Adapted by Alexis Krueger
    01/08/15
  Adapted by Rocky Mazorow
    11/09/2022 to fix lack of error if less than 6 values are sent before semicolon
*/

#define MAX_PARAMETER_LEN    (10)     // mximum length for each x+ x- y+ y- parameter
#define MIN_TACTOR_VALUE     (0)      // minimum value for each vibration motor
#define MAX_TACTOR_VALUE     (255)    // maximum value for each vibration motor
#define NUM_TACTORS          (6)      // number of vibration motors (a.k.a. tactors)            

//int Tctr[NUM_TACTORS] = {2, 3, 4, 5, 6, 7};
int Tctr[NUM_TACTORS] = {6,7,10,11,8,9};                                
int Goggles = 9;

char gParam1Buffer[MAX_PARAMETER_LEN + 1];
char gParam2Buffer[MAX_PARAMETER_LEN + 1];
char gParam3Buffer[MAX_PARAMETER_LEN + 1];
char gParam4Buffer[MAX_PARAMETER_LEN + 1];
char gParam5Buffer[MAX_PARAMETER_LEN + 1];
char gParam6Buffer[MAX_PARAMETER_LEN + 1];
char gParam7Buffer[MAX_PARAMETER_LEN + 1];
long gParam1Value;
long gParam2Value;
long gParam3Value;
long gParam4Value;
long gParam5Value;
long gParam6Value;
long gParam7Value;
long gLoopCounter;
long gParam1Value_old;
long gParam2Value_old;
long gParam3Value_old;
long gParam4Value_old;
long gParam5Value_old;
long gParam6Value_old;

long oldTime;
long newTime;

/**********************************************************************
   Function:    cliBuildCommand
   Description: Put received characters into the command buffer or the
                parameter buffer. Once a complete command is received
                return true.
   Notes:       Each paramerter has a check value to see if it is
                complete. Possible values are 0 (not compiled), 1 (compiled
                without error, or -1 (error due to exceeding parameter
                length). Final return will only be true if all parameter
                checks are 1.
   Returns:     true if a command is complete, otherwise false.
 **********************************************************************/
int cliBuildCommand(char nextChar) {
  // Return value for function.
  // 1 (true) if all 6 tactor params are properly filled and ends with semicolon (no check for goggle)
  // 0 (false) if param error, params not filled, or not semicolon
  static int isReady = false;
  static int lastSemi = false;

  // indices for parameter buffers
  static uint8_t param1Indx = 0;
  static uint8_t param2Indx = 0;
  static uint8_t param3Indx = 0;
  static uint8_t param4Indx = 0;
  static uint8_t param5Indx = 0;
  static uint8_t param6Indx = 0;
  static uint8_t param7Indx = 0;

  // checks for each parameter: 0 (not compiled), 1 (compiledwithout error), -1 (error due to exceeding parameter length)
  static int checkParam1 = 0;
  static int checkParam2 = 0;
  static int checkParam3 = 0;
  static int checkParam4 = 0;
  static int checkParam5 = 0;
  static int checkParam6 = 0;

  enum {PARAM1, PARAM2, PARAM3, PARAM4, PARAM5, PARAM6, PARAM7};
  static uint8_t state = PARAM1;

  // If last iteration was a ;, reset values
  if(lastSemi) {
    checkParam1 = 0;
    checkParam2 = 0;
    checkParam3 = 0;
    checkParam4 = 0;
    checkParam5 = 0;
    checkParam6 = 0;
    param1Indx = 0;
    param2Indx = 0;
    param3Indx = 0;
    param4Indx = 0;
    param5Indx = 0;
    param6Indx = 0;
    param7Indx = 0;
    state = PARAM1;
    isReady = false;
    lastSemi = false;
  }
  
  // Don't store any new line characters or spaces.
  if ((nextChar == '\n') || (nextChar == ' ') || (nextChar == '\t') || (nextChar == '\r')) {
    isReady = false;
  }

  //The completed command has been received.
  else if (nextChar == ';') {
    // Add \0 to signifiy end of String
    gParam1Buffer[param1Indx] = '\0';
    gParam2Buffer[param2Indx] = '\0';
    gParam3Buffer[param3Indx] = '\0';
    gParam4Buffer[param4Indx] = '\0';
    gParam5Buffer[param5Indx] = '\0';
    gParam6Buffer[param6Indx] = '\0';
    gParam7Buffer[param7Indx] = '\0';
    
    // If all check params are 1 (compiled without param errors)
    if (checkParam1 == 1 && checkParam2 == 1 && checkParam3 == 1 && checkParam4 == 1 && checkParam5 == 1 && checkParam6 == 1) {
      Serial.println("data complete");
      isReady = true;
    }
    else {
      Serial.println("data incomplete");
    }
    lastSemi = true;
  }

  else if (nextChar == ',') {
    if (state == PARAM1) {
      state = PARAM2;
    }
    else if (state == PARAM2) {
      state = PARAM3;
    }
    else if (state == PARAM3) {
      state = PARAM4;
    }
    else if (state == PARAM4) {
      state = PARAM5;
    }
    else if (state == PARAM5) {
      state = PARAM6;
    }
    else if (state == PARAM6) {
      state = PARAM7;
    }
  }

  else {
    // Repeated for each PARAM
    // Store the received character in the parameter buffer and increase param index.
    // If the command is too long, make param check equal to 0 to trigger error
    if (state == PARAM1) {
      gParam1Buffer[param1Indx] = nextChar;
      param1Indx++;
      if (checkParam1 == 0) {
        checkParam1 = 1;
      }
      if (param1Indx > MAX_PARAMETER_LEN) {
        param1Indx = 0;
        checkParam1 = -1;
      }
    }
    if (state == PARAM2) {
      gParam2Buffer[param2Indx] = nextChar;
      param2Indx++;
      if (checkParam2 == 0) {
        checkParam2 = 1;
      }
      if (param2Indx > MAX_PARAMETER_LEN) {
        param2Indx = 0;
        checkParam2 = -1;
      }
    }
    if (state == PARAM3) {
      gParam3Buffer[param3Indx] = nextChar;
      param3Indx++;
      if (checkParam3 == 0) {
        checkParam3 = 1;
      }
      if (param3Indx > MAX_PARAMETER_LEN) {
        param3Indx = 0;
        checkParam3 = -1;
      }
    }
    if (state == PARAM4) {
      gParam4Buffer[param4Indx] = nextChar;
      param4Indx++;
      if (checkParam4 == 0) {
        checkParam4 = 1;
      }
      if (param4Indx > MAX_PARAMETER_LEN) {
        param4Indx = 0;
        checkParam4 = -1;
      }
    }
    if (state == PARAM5) {
      gParam5Buffer[param5Indx] = nextChar;
      param5Indx++;
      if (checkParam5 == 0) {
        checkParam5 = 1;
      }
      if (param5Indx > MAX_PARAMETER_LEN) {
        param5Indx = 0;
        checkParam5 = -1;
      }
    }
    if (state == PARAM6) {
      gParam6Buffer[param6Indx] = nextChar;
      param6Indx++;
      if (checkParam6 == 0) {
        checkParam6 = 1;
      }
      if (param6Indx > MAX_PARAMETER_LEN) {
        param6Indx = 0;
        checkParam6 = -1;
      }
    }
    if(state == PARAM7) {
      gParam7Buffer[param7Indx] = nextChar;
      param7Indx++;
    }
  }

  return isReady;
}


/**********************************************************************
   Function:    setSix
   Description: This command takes the String values generated in
                cliBuildCommand(), converts them to integers, and then 
                sends them to vibration motors.
   Notes:       For debugging, can send values through Serial Monitor
                and view what Arduino is sending each pin.
   Returns:     None.
 **********************************************************************/
void setSix(void) {
  Serial.println("Buffer: " + String(gParam1Buffer) + ", " + String(gParam2Buffer) + ", " + String(gParam3Buffer) + ", " + String(gParam4Buffer) + ", " + String(gParam5Buffer) + ", " + String(gParam6Buffer) + ", " + String(gParam7Buffer));
  // Convert the parameter to an long value.  If the parameter is empty, gParamValue becomes 0.
  gParam1Value = strtol(gParam1Buffer, NULL, 0);
  gParam2Value = strtol(gParam2Buffer, NULL, 0);
  gParam3Value = strtol(gParam3Buffer, NULL, 0);
  gParam4Value = strtol(gParam4Buffer, NULL, 0);
  gParam5Value = strtol(gParam5Buffer, NULL, 0);
  gParam6Value = strtol(gParam6Buffer, NULL, 0);
  gParam7Value = strtol(gParam7Buffer, NULL, 0);
  gParam7Value = abs(gParam7Value-255L);

  // Write values to vibration motors
  analogWrite(Tctr[0], gParam1Value);
  analogWrite(Tctr[1], gParam2Value);
  analogWrite(Tctr[2], gParam3Value);
  analogWrite(Tctr[3], gParam4Value);
  analogWrite(Tctr[4], gParam5Value);
  analogWrite(Tctr[5], gParam6Value);
  analogWrite(Goggles, gParam7Value);

  // For debugging: will print value that was sent to vibration motors
  Serial.print("P1 is ");
  Serial.println(gParam1Value);
  Serial.print("P2 is ");
  Serial.println(gParam2Value);
  Serial.print("P3 is ");
  Serial.println(gParam3Value);
  Serial.print("P4 is ");
  Serial.println(gParam4Value);
  Serial.print("P5 is ");
  Serial.println(gParam5Value);
  Serial.print("P6 is ");
  Serial.println(gParam6Value);
  Serial.print("P7 is ");
  Serial.println(gParam7Value);
  Serial.println("data sent");
}


void setup() {
  int idx;
  Serial.begin(115200);
  // sets the pins as outputs
  for (idx = 0; idx < NUM_TACTORS; idx++)
  {
    pinMode(Tctr[idx], OUTPUT);
  }
  oldTime = 0;
  newTime = 0;
  gLoopCounter = 0;
}

void loop() {
  char rcvChar;                   // character sent to Arduino
  int  bCommandReady = false;     // is full command sent? (4 values separated by commas and ending with ;)
  char finalChar;                 // equal to rcvChar - in place to deal with potential future interrupts from read

  if (Serial.available() > 0) {
    // Wait for a character.
    rcvChar = Serial.read();
    finalChar = rcvChar;

    // Build a new command.
    bCommandReady = cliBuildCommand(finalChar);
    oldTime = newTime;
  }

  // If full command sent (4 values separated by commas and ending with ;)
  // reset boolean and call setFour() to send to vibration motors
  if (bCommandReady == true) {
    bCommandReady = false;
    setSix();
  }
}
