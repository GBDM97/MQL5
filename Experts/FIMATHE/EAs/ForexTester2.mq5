#include "../Operators/FimatheForexOperation/Index.mqh"
#include "../Operators/FimatheForexOperation/OperationInfo.mqh"

FimatheForexOperation fimatheForexOperation;
OperationInfo operationInfo;

enum takeProfitType {
    SURF,
    ONE_LEVEL,
    TWO_LEVELS,
    THREE_LEVELS,
    FOUR_LEVELS
   };
input double volume;
input TakeProfitType takeProfitType = SURF;
input double stopLossMultiplier = 2.25;
input double macroInitRef1;
input double macroInitRef2;
input double channelDivider = 8.5;

operationInfo.volume = volume;
operationInfo.takeProfitType = takeProfitType;
operationInfo.stopLossMultiplier = stopLossMultiplier;
operationInfo.macroInitRef1 = macroInitRef1;
operationInfo.macroInitRef2 = macroInitRef2;
operationInfo.channelDivider = channelDivider;

int OnInit()
  {
    if(macroInitRef1>macroInitRef2) //refs validation
    {
        return(INIT_SUCCEEDED);
    }else{
        return(INIT_FAILED);
    };
  }

void OnTick()
  { 
   fimatheForexOperation.Update(operationInfo);
  }
