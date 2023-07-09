#include <Trade/Trade.mqh>
#include "Utils/LastClosePrice.mqh"
#include "RiskManager.mqh"
#include "GetEntryPoint.mqh"

CTrade trade;
LastClosePrice lastClosePrice;
RiskManager riskManager;
GetEntryPoint getEntryPoint;

class FimatheForexOperation {
public:
    void Update(bool levelToLevelSurf);
    void ManageTrailingStop(void);
    void CheckWhereToOpenNextOrder(bool levelToLevelSurf);
    double EntryPoints[2];
};

void FimatheForexOperation::Update(bool levelToLevelSurf) {
    if(PositionsTotal()) 
    {
        if(levelToLevelSurf){
            ManageTrailingStop();
        }else{return;}
    }else{
        EntryPoints[0] = -1;
        EntryPoints[1] = -1;
        CheckWhereToOpenNextOrder(levelToLevelSurf);
    }
}

void FimatheForexOperation::ManageTrailingStop(void) {
    
}

void FimatheForexOperation::CheckWhereToOpenNextOrder(bool levelToLevelSurf) {
    
    if(riskManager.AuthorizeOperations() == false)
    {
        return;
    }

    if(EntryPoints[0] == -1 && EntryPoints[1] == -1) 
    {
        EntryPoints[0] = getEntryPoint.Above();
        EntryPoints[1] = getEntryPoint.Bellow();
    }

    if(lastClosePrice.M15() > EntryPoints[0])
    {
        trade.Buy(0.01,NULL,0.0,0.0,0.0,NULL);
    }

    if(lastClosePrice.M15() < EntryPoints[1])
      {
        trade.Sell(0.01,NULL,0.0,0.0,0.0,NULL);
      }
    
}

