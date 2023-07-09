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
    void Update(bool takeProfitType);
protected:
    void ManageTrailingStop(void);
    void CheckWhereToOpenNextOrder(bool takeProfitType);
    double EntryPoints[2];
};

void FimatheForexOperation::Update(bool takeProfitType,double volume,double stopLossMultiplier) {
    if(PositionsTotal()) 
    {
        if(takeProfitType == "surf"){
            ManageTrailingStop();
        }else{return;}
    }else{
        EntryPoints[0] = -1;
        EntryPoints[1] = -1;
        CheckWhereToOpenNextOrder(takeProfitType,volume,stopLossMultiplier);
    }
}

void FimatheForexOperation::ManageTrailingStop(void) {
    
}

void FimatheForexOperation::CheckWhereToOpenNextOrder(bool takeProfitType,double volume,double stopLossMultiplier) {
    
    if(riskManager.AuthorizeOperations() == false)
    {
        return;
    }

    if(EntryPoints[0] == -1 && EntryPoints[1] == -1) 
    {
        EntryPoints[0] = getEntryPoint.Above();
        EntryPoints[1] = getEntryPoint.Bellow();
        microChannelSize = microChannel.GetSize();
    }

    if(lastClosePrice.M15() > EntryPoints[0])
    {
        trade.Buy(volume,Symbol(),0.0,microChannelSize*-stopLossMultiplier,
        (takeProfitType=="surf" ? 0.0 : microChannelSize*StringToInteger(takeProfitType)),NULL); //todo
    }
    if(lastClosePrice.M15() < EntryPoints[1])
      {
        trade.Sell(volume,Symbol(),0.0,microChannelSize*stopLossMultiplier,
        (takeProfitType=="surf" ? 0.0 : microChannelSize*-StringToInteger(takeProfitType)),NULL); //todo
      }
    
}

