//+------------------------------------------------------------------+
//|                                                    Learning3.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
datetime d1 = D'2023.07.03';
MqlDateTime str1;
TimeToStruct(d1,str1);
//Print(str1.day_of_week);
MqlRates rates[];
CopyRates("USDJPY",PERIOD_D1,1,1,rates);
if(StringSubstr(rates[0].time,0,10) == StringSubstr(TimeCurrent()-3*PeriodSeconds(PERIOD_D1),0,10))
{
   Print("First Day of the week");
}else{Print("not the first day of the week");};

// Print("date1= ",StringSubstr(rates[0].time,0,10));
// Print("date2= ",StringSubstr(TimeCurrent()-2*PeriodSeconds(PERIOD_D1),0,10));


  }
