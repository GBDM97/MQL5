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
        ManageTrailingStop();//todo
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
                    stop = PositionGetDouble(POSITION_OPEN);//todo insert modify stop expression
                }
            }else{
                expertAdvisorInfo.firstCdPastLine = true;
                expertAdvisorInfo.firstCdPastLineClose = expertAdvisorInfo.GetLastClosePriceM15();
            if (expertAdvisorInfo.GetLastClosePriceM15() > expertAdvisorInfo.microRef1 + (expertAdvisorInfo.microChannelSize*2) && expertAdvisorInfo.stopPosition == 1)
                {expertAdvisorInfo.stopPosition = 2
                stop = round(0.75*expertAdvisorInfo.microChannelSize + expertAdvisorInfo.microRef1)
                operationRequest[4] = [expertAdvisorInfo.microRef1+expertAdvisorInfo.microChannelSize*3, expertAdvisorInfo.microRef1+expertAdvisorInfo.microChannelSize, expertAdvisorInfo.microChannelSize]
                }
            if (expertAdvisorInfo.GetLastClosePriceM15()) > expertAdvisorInfo.microRef1 && expertAdvisorInfo.stopPosition == 2:
                expertAdvisorInfo.microRef1 = expertAdvisorInfo.microRef1+expertAdvisorInfo.microChannelSize
                operationRequest[4][1] = operationRequest[4][1]+expertAdvisorInfo.microChannelSize
                stop = operationRequest[4][1]-round(0.25*expertAdvisorInfo.microChannelSize)
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
        trade.Buy(expertAdvisorInfo.volume,Symbol(),0.0,
        expertAdvisorInfo.microChannelSize*-expertAdvisorInfo.stopLossMultiplier,
        (expertAdvisorInfo.takeProfitType==TakeProfitType(0) ? 
        0.0 : expertAdvisorInfo.microChannelSize*TakeProfitTypeToNumber()),NULL);
    }
    if(close < expertAdvisorInfo.entryPoint2 && expertAdvisorInfo.entryPoint2 != 0 && expertAdvisorInfo.entryPoint2 != -1 && PositionsTotal() == false)
      {
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

