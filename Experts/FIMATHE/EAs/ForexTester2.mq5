#include "../Operators/FimatheForexOperation/Index.mqh"
FimatheForexOperation fimatheForexOperation;

enum TakeProfitType {
    SURF,
    ONE_LEVEL,
    TWO_LEVELS,
    THREE_LEVELS,
    FOUR_LEVELS
};

input double volume;
input enum takeProfitType = SURF;
input double stopLossMultiplier = 2.25;
input double macroInitRef1;
input double macroInitRef2;
input double channelDivider = 8;

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
   fimatheForexOperation.Update(volume,takeProfitType,stopLossMultiplier,macroInitRef1,macroInitRef2,channelDivider);
  }
