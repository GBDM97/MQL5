//+------------------------------------------------------------------+
//|                                                    Learning2.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

input double macroChannelRef1;
input double macroChannelRef2;
int i = 1;

CTrade trade;
//Fimathe fimathe;
//Fimathe.GetWeekRef(macroChannelRef1,macroChannelRef2);

int OnInit()
  {
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   
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
   if(i == 3000)
   {
      trade.PositionClose("EURUSD");
   }
   
   
   if(i == 2000)
   {
      trade.Sell(0.01,NULL,0.0,0.0,0.0,NULL);
   }
   
   if(PositionsTotal()){
      PositionSelect("EURUSD");
      
   }
    if(HistorySelect(0, TimeCurrent()))
    {
    Print(HistoryDealGetDouble(HistoryDealGetTicket(HistoryDealsTotal()-1),DEAL_PROFIT));
    }
  }
//+------------------------------------------------------------------+
