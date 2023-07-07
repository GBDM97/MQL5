//+------------------------------------------------------------------+
//|                                                    Learning2.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

CTrade trade;
int i = 1;
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
   if(i< 10010)
   {
      i++;
   }
   if(i == 10000)
   {
      trade.PositionClose("EURUSD");
   }
   
   
   if(i == 1000)
   {
      trade.Sell(0.01,NULL,0.0,0.0,0.0,NULL);
   }
   
   if(PositionsTotal()){
      PositionSelect("EURUSD");
      Comment(PositionGetInteger(POSITION_TYPE));
      
   }
  }
//+------------------------------------------------------------------+
