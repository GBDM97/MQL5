#include "../Operators/FimatheForexOperation/Index.mqh"
FimatheForexOperation fimatheForexOperation;

input bool takeProfitType;
input double volume;
input double stopLossMultiplier = 2.25;

void OnTick()
  { 
   fimatheForexOperation.Update(takeProfitType,volume,stopLossMultiplier);
  }
