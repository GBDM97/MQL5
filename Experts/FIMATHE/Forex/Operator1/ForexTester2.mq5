#include "Index.mqh"
#include "ExpertAdvisorInfo.mqh"
#include "./Enums/TakeProfitType.mqh"

FimatheForexOperation fimatheForexOperation;
ExpertAdvisorInfo expertAdvisorInfo;

input double volumeOfOperations;
input TakeProfitType tpType = SURF;
input double stopLossMultiplier = 2.25;
input double macroInitRef1;
input double macroInitRef2;
input double channelDivider = 8;


int OnInit()
  {
    expertAdvisorInfo.volume = volumeOfOperations;
    expertAdvisorInfo.takeProfitType = tpType;
    expertAdvisorInfo.stopLossMultiplier = stopLossMultiplier;
    expertAdvisorInfo.macroRef1 = macroInitRef1;
    expertAdvisorInfo.macroRef2 = macroInitRef2;
    expertAdvisorInfo.channelDivider = channelDivider;

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
