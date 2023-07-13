#include "../Operators/FimatheForexOperation/Index.mqh"
#include "../Operators/FimatheForexOperation/ExpertAdvisorInfo.mqh"
#include "Enums/TakeProfitType.mqh"

FimatheForexOperation fimatheForexOperation;
ExpertAdvisorInfo expertAdvisorInfo;

input double volume;
input takeProfitType tpType = SURF;
input double stopLossMultiplier = 2.25;
input double macroInitRef1;
input double macroInitRef2;
input double channelDivider = 8.5;

expertAdvisorInfo.volume = volume;
expertAdvisorInfo.takeProfitType = tpType;
expertAdvisorInfo.stopLossMultiplier = stopLossMultiplier;
expertAdvisorInfo.macroInitRef1 = macroInitRef1;
expertAdvisorInfo.macroInitRef2 = macroInitRef2;
expertAdvisorInfo.channelDivider = channelDivider;

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
   fimatheForexOperation.Update(expertAdvisorInfo);
  }
