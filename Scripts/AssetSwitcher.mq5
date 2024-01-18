   // string list[] = {
   //    "ABEV3","ALOS3","ALPA4","ARZZ3","ASAI3","AURE3","AZUL4","B3SA3","BBAS3","BBDC3","BBDC4","BBSE3","BEEF3","BHIA3","BOVA11","BOVV11","BPAC11","BRAP4","BRFS3","BRKM5","CBAV3","CCRO3","CIEL3","CMIG4","CMIN3","COGN3","CPLE6","CSAN3","CSNA3","CVCB3","CYRE3","EGIE3","ELET3","ELET6","EMBR3","ENAT3","ENEV3","EQTL3","EZTC3","GFSA3","GGBR4","GOAU4","GOLL4","HAPV3","HYPE3","IRBR3","ITSA4","ITUB4","JBSS3","KLBN11","LREN3","LWSA3","MGLU3","MRFG3","MRVE3","MULT3","NTCO3","PCAR3","PETR3","PETR4","PETZ3","PRIO3","QUAL3","RADL3","RAIL3","RAIZ4","RDOR3","RENT3","RRRP3","SANB11","SBSP3","SEQL3","SMAL11","SOMA3","SUZB3","TAEE11","TRPL4","UGPA3","USIM5","VALE3","VBBR3","VIVT3","WEGE3","YDUQ3"
   // };

//+------------------------------------------------------------------+
//| Create a simple button on the chart                              |
//+------------------------------------------------------------------+
void OnStart()
{
   //--- create a button
   if(!ObjectCreate(0,"MyButton",OBJ_BUTTON,0,0,0))
     {
      Print("Failed to create a button! Error code: ", GetLastError());
      return;
     }
   //--- set button coordinates on the chart
   ObjectSetInteger(0,"MyButton",OBJPROP_XDISTANCE,20);
   ObjectSetInteger(0,"MyButton",OBJPROP_YDISTANCE,20);
   //--- set button size
   ObjectSetInteger(0,"MyButton",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"MyButton",OBJPROP_YSIZE,50);
   //--- set button text
   ObjectSetString(0,"MyButton",OBJPROP_TEXT,"Click Me!");
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   //--- check if the event is for the button click
   if(id==CHARTEVENT_OBJECT_CLICK && sparam=="MyButton")
     {
      //--- handle the button click
      Print("Button clicked!");
     }
}

// 
// In this example, when the button "MyButton" is clicked, the `OnChartEvent` function will print "Button clicked!" to the log.
// 
// For more complex interactions or custom graphical elements, you might need to use a combination of chart objects and check their properties on each tick or timer event to simulate mouse click listening. However, this would be a more manual and less straightforward approach.
// 
// Keep in mind that MQL5 is optimized for trading-related activities and may not have all the capabilities of a full-fledged programming language for creating standalone applications with advanced user interaction features.
// 

//change current chart ticker
// In MQL5, you can change the symbol (ticker) of the current chart by using the `ChartSetSymbolPeriod` function. This function allows you to change the symbol and timeframe of the specified chart window.
// 
// Here's an example of how you can use `ChartSetSymbolPeriod` to change the symbol of the current chart:
// 

// MQL5 script to change the current chart symbol

void OnStart()
{
    // Define the new symbol you want to set for the current chart
    string newSymbol = "EURUSD"; // Change this to the desired symbol

    // Get the current chart ID
    long chartId = ChartID();

    // Get the current chart timeframe
    ENUM_TIMEFRAMES currentPeriod = (ENUM_TIMEFRAMES)ChartPeriod(chartId);

    // Change the symbol of the current chart
    bool result = ChartSetSymbolPeriod(chartId, newSymbol, );

    // Check if the symbol was changed successfully
    if (result)
    {
        Print("The chart symbol has been changed to ", newSymbol);
    }
    else
    {
        Print("Failed to change the chart symbol to ", newSymbol);
    }
}

// 
// In this example, `ChartID()` is used to get the ID of the current chart, and `ChartPeriod` is used to get the current timeframe of the chart. The `ChartSetSymbolPeriod` function is then called with the chart ID, the new symbol, and the current timeframe.
// 
// Please note that this script will only work when it is run on the chart you want to change. If you want to change the symbol of a different chart, you would need to specify the chart ID of that chart instead of using `ChartID()`.
// 
// Also, keep in mind that not all brokers allow changing the symbol of a chart programmatically. Some trading platforms might have restrictions on this operation, so it's important to test this functionality on a demo account before using it on a live account.
// 

