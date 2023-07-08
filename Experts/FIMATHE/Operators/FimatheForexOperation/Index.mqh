#include <Trade/Trade.mqh>
CTrade trade;

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
        EntryPoints[0] == -1;
        EntryPoints[1] == -1;
        CheckWhereToOpenNextOrder(levelToLevelSurf);
    }
}

void FimatheForexOperation::ManageTrailingStop(void) {
    
}

void FimatheForexOperation::CheckWhereToOpenNextOrder(bool levelToLevelSurf) {
    if(EntryPoints[0] == -1 && EntryPoints[1] == -1) 
    {
        EntryPoints[0] = GetEntryPoint.Above();
        EntryPoints[1] = GetEntryPoint.Bellow();
    }

    if(LastClosePrice.M15() > EntryPoints[0])
    {
        trade.Buy(0.01,NULL,0.0,0.0,0.0,NULL);
    }

    if(LastClosePrice.M15() < EntryPoints[1])
    {
        trade.Sell(0.01,NULL,0.0,0.0,0.0,NULL);
    }
    
}

