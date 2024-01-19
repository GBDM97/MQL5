
string button_name = "MyButton";
int OnInit()
  {
   ChartRedraw();
   
   ObjectCreate(0, button_name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, button_name, OBJPROP_XDISTANCE, 20); // X distance from the top left corner
   ObjectSetInteger(0, button_name, OBJPROP_YDISTANCE, 20); // Y distance from the top left corner
   ObjectSetInteger(0, button_name, OBJPROP_XSIZE, 20);    // Button width
   ObjectSetInteger(0, button_name, OBJPROP_YSIZE, 20);     // Button height
   ObjectSetString(0, button_name, OBJPROP_TEXT, ">"); // Button text
   ObjectSetInteger(0, button_name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, button_name, OBJPROP_BGCOLOR, clrBlack);
   return INIT_SUCCEEDED;
  }

void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
      if(id == CHARTEVENT_OBJECT_CLICK)
      {
      Sleep(80);
      ObjectSetInteger(0, button_name, OBJPROP_STATE, false);
      Print("click");
      ChartSetSymbolPeriod(0, "PETR4",PERIOD_M1);
      };
  }
