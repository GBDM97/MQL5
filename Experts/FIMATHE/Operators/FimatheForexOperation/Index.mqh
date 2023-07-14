#include <Trade/Trade.mqh>
#include "Utils/TodayIsTheFirstWeekDay.mqh"
#include "RiskManager.mqh"
#include "ExpertAdvisorInfo.mqh"
#include "Enums/TakeProfitType.mqh"

CTrade trade;
RiskManager riskManager;
TodayIsTheFirstWeekDay todayIsTheFirstWeekDay;

class FimatheForexOperation {
protected:
    void ManageTrailingStop(void);
    void CheckWhereToOpenNextOrder(void);
    int TakeProfitTypeToNumber(void);
    void WaitForPositionEntryPoint(void);
    void UpdateMicroChannel(void);
    ExpertAdvisorInfo expertAdvisorInfo;

    bool recentPosition;
public:
    void Update(ExpertAdvisorInfo& paramExpertAdvisorInfo);
};

void FimatheForexOperation::Update(ExpertAdvisorInfo& paramExpertAdvisorInfo) {
    
    expertAdvisorInfo = paramExpertAdvisorInfo;

    UpdateMicroChannel();
    expertAdvisorInfo.UpdateMacroChannel();
    
    if(PositionsTotal()) 
    {
        recentPosition = true;
        if(
            expertAdvisorInfo.takeProfitType = TakeProfitType(0) ||
            expertAdvisorInfo.takeProfitType = TakeProfitType(1) && expertAdvisorInfo.stopPosition == 0 ||
            expertAdvisorInfo.takeProfitType = TakeProfitType(2) && expertAdvisorInfo.stopPosition == 0 ||
            expertAdvisorInfo.takeProfitType = TakeProfitType(3) && expertAdvisorInfo.stopPosition == 0 ||
            expertAdvisorInfo.takeProfitType = TakeProfitType(4) && expertAdvisorInfo.stopPosition == 0 ||
           )
        {ManageTrailingStop();}

    }else if(!PositionsTotal() && recentPosition == true){
        expertAdvisorInfo.stopPosition = 0;
        expertAdvisorInfo.firstCdPastLine == false;
        expertAdvisorInfo.VerifyToLockEntryPoint();
        riskManager.AnalizeResults(); //todo
        recentPosition = false;
    }

    if(expertAdvisorInfo.entryPoint1 == 0 || expertAdvisorInfo.entryPoint2 == 0 || 
    expertAdvisorInfo.entryPoint3 == 0 || expertAdvisorInfo.entryPoint4 == 0){
        CheckWhereToOpenNextOrder();
    }

    if(expertAdvisorInfo.entryPoint1 != 0 || expertAdvisorInfo.entryPoint2 != 0 || 
    expertAdvisorInfo.entryPoint3 != 0 || expertAdvisorInfo.entryPoint4 != 0){
        WaitForPositionEntryPoint();
    }
}

void FimatheForexOperation::ManageTrailingStop(void) {
    PositionSelect(Symbol());
    if(PositionGetInt(POSITION_TYPE) == 1)
    {
        if(expertAdvisorInfo.GetLastClosePriceM15() > PositionGetDouble(POSITION_OPEN) + expertAdvisorInfo.microChannelSize 
        && expertAdvisorInfo.stopPosition == 0)
        {
            if(expertAdvisorInfo.firstCdPastLine == true)
            {
                if (expertAdvisorInfo.GetLastClosePriceM15() > expertAdvisorInfo.firstCdPastLineClose)
                {
                    expertAdvisorInfo.stopPosition = 1;
                    trade.PositionModify(Symbol(),PositionGetDouble(POSITION_OPEN),0);
                }

            }else{
                expertAdvisorInfo.firstCdPastLine = true;
                expertAdvisorInfo.firstCdPastLineClose = expertAdvisorInfo.GetLastClosePriceM15();
            }

            if(expertAdvisorInfo.GetLastClosePriceM15() > expertAdvisorInfo.entryPointRefPrice +
             (expertAdvisorInfo.microChannelSize*2) && expertAdvisorInfo.stopPosition == 1 &&
             expertAdvisorInfo.takeProfitType == TakeProfitType(0))
            {
                    expertAdvisorInfo.stopPosition = 2;
                    trade.PositionModify(Symbol(),MathRound(0.75*expertAdvisorInfo.microChannelSize + expertAdvisorInfo.entryPointRefPrice),0);

            }else if(expertAdvisorInfo.GetLastClosePriceM15() > PositionGetDouble(POSITION_SL) + 
            (2.25*expertAdvisorInfo.microChannelSize) && expertAdvisorInfo.stopPosition == 2 &&
             expertAdvisorInfo.takeProfitType == TakeProfitType(0))
            {
                stop = operationRequest[4][1]-round(0.25*expertAdvisorInfo.microChannelSize)
                trade.PositionModify(Symbol(),PositionGetDouble(POSITION_SL)+expertAdvisorInfo.microChannelSize,0);
            }  
        }
    }
}

void FimatheForexOperation::CheckWhereToOpenNextOrder() {
    if(riskManager.AuthorizeOperations() == false)//todo wait for sunday, and other logics
    {
        return;
    }
    expertAdvisorInfo.TryToDefine1And4();

    if(macroRef1-2*macroChannelSize > expertAdvisorInfo.entryPoint4)//break through above
    {
        expertAdvisorInfo.entryPoint3 = expertAdvisorInfo.entryPoint1;
        expertAdvisorInfo.entryPoint4 = expertAdvisorInfo.entryPoint2;

        if(expertAdvisorInfo.recentOperationEntryPoint == "entryPoint2")
        {expertAdvisorInfo.recentOperationEntryPoint = "entryPoint4";}
        else if(expertAdvisorInfo.recentOperationEntryPoint == "entryPoint4")
        {expertAdvisorInfo.recentOperationEntryPoint = "entryPoint2";}
    }
    if(macroRef2+2*macroChannelSize < expertAdvisorInfo.entryPoint1)//break through bellow
    {
        expertAdvisorInfo.entryPoint2 = expertAdvisorInfo.entryPoint4;
        expertAdvisorInfo.entryPoint1 = expertAdvisorInfo.entryPoint3;

        if(expertAdvisorInfo.recentOperationEntryPoint == "entryPoint3")
        {expertAdvisorInfo.recentOperationEntryPoint = "entryPoint1";}
        else if(expertAdvisorInfo.recentOperationEntryPoint == "entryPoint1")
        {expertAdvisorInfo.recentOperationEntryPoint = "entryPoint3";}
    }
    if(expertAdvisorInfo.PriceBellow50()){
        expertAdvisorInfo.UnlockEntryPoints();
    }
    if(expertAdvisorInfo.PriceAbove50()){
        expertAdvisorInfo.UnlockEntryPoints();
    }
}

void FimatheForexOperation::UpdateMicroChannel(){
    if(todayIsTheFirstWeekDay.Verify() && StringSubstr(TimeToString(TimeCurrent()),11,8) == "06:00:00")
    {expertAdvisorInfo.CreateNewMicroChannel();}
    else{expertAdvisorInfo.UpdateMicroChannel();}
}

void FimatheForexOperation::WaitForPositionEntryPoint(){
    
    double close = expertAdvisorInfo.GetLastClosePriceM15();
    if(close > expertAdvisorInfo.entryPoint3 && expertAdvisorInfo.entryPoint3 != 0 && expertAdvisorInfo.entryPoint3 != -1 && PositionsTotal() == false)
    {
        expertAdvisorInfo.entryPointRefPrice = expertAdvisorInfo.entryPoint3;
        trade.Buy(expertAdvisorInfo.volume,Symbol(),0.0,
        expertAdvisorInfo.microChannelSize*-expertAdvisorInfo.stopLossMultiplier,
        (expertAdvisorInfo.takeProfitType==TakeProfitType(0) ? 
        0.0 : expertAdvisorInfo.microChannelSize*TakeProfitTypeToNumber()),NULL);
    }
    if(close < expertAdvisorInfo.entryPoint2 && expertAdvisorInfo.entryPoint2 != 0 && expertAdvisorInfo.entryPoint2 != -1 && PositionsTotal() == false)
      {
        expertAdvisorInfo.entryPointRefPrice = expertAdvisorInfo.entryPoint2;
        trade.Sell(expertAdvisorInfo.volume,Symbol(),0.0,
        expertAdvisorInfo.microChannelSize*expertAdvisorInfo.stopLossMultiplier,
        (expertAdvisorInfo.takeProfitType == TakeProfitType(0) ? 
        0.0 : expertAdvisorInfo.microChannelSize*-TakeProfitTypeToNumber()),NULL);
      }   
}

int FimatheForexOperation::TakeProfitTypeToNumber() {
    if(expertAdvisorInfo.takeProfitType == TakeProfitType(1))
    {return 1;}
    if(expertAdvisorInfo.takeProfitType == TakeProfitType(2))
    {return 2;}
    if(expertAdvisorInfo.takeProfitType == TakeProfitType(3))
    {return 3;}
    if(expertAdvisorInfo.takeProfitType == TakeProfitType(4))
    {return 4;}
    return NULL;
}

