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
        if(expertAdvisorInfo.takeProfitType == TakeProfitType(0)){
            ManageTrailingStop();//todo
        }else{return;}
    }else if(!PositionsTotal() && recentPosition == true){
        //todo mark specific expertAdvisorInfo.entryPoint undefined
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
    //todo
}

void FimatheForexOperation::CheckWhereToOpenNextOrder() {
    if(riskManager.AuthorizeOperations() == false)//todo wait for sunday, and other logics
    {
        return;
    }
    //todo logic to 50% return, after position opened and get or dont get expertAdvisorInfo.entryPoint
    if(expertAdvisorInfo.entryPoint1 == 0) 
    {
        expertAdvisorInfo.entryPoint1 = expertAdvisorInfo.microRef1;
        while (expertAdvisorInfo.entryPoint1 < expertAdvisorInfo.macroRef1 + expertAdvisorInfo.microChannelSize*2)
        {
            expertAdvisorInfo.entryPoint1 += expertAdvisorInfo.microChannelSize;
        }
    }

    if(expertAdvisorInfo.entryPoint2 == 0) 
    {
        //caso
    }
    
    if(expertAdvisorInfo.entryPoint3 == 0 || macroRef1-2*macroChannelSize > expertAdvisorInfo.entryPoint4)
    {
        expertAdvisorInfo.entryPoint3 = expertAdvisorInfo.entryPoint1;
    }
    
    if(expertAdvisorInfo.entryPoint4 == 0 || macroRef1-2*macroChannelSize > expertAdvisorInfo.entryPoint4) 
    {
        expertAdvisorInfo.entryPoint1 = expertAdvisorInfo.microRef2;
        while (expertAdvisorInfo.entryPoint4 > expertAdvisorInfo.macroRef2 - expertAdvisorInfo.microChannelSize*2)
        {
            expertAdvisorInfo.entryPoint4 -= expertAdvisorInfo.microChannelSize;
        }
    }
    
}

void FimatheForexOperation::UpdateMicroChannel(){
    if(todayIsTheFirstWeekDay.Verify() && StringSubstr(TimeToString(TimeCurrent()),11,8) == "06:00:00")
    {expertAdvisorInfo.CreateNewMicroChannel();}
    else{expertAdvisorInfo.UpdateMicroChannel();}
}

void FimatheForexOperation::WaitForPositionEntryPoint(){
    
    double close = expertAdvisorInfo.GetLastClosePriceM15();
    if(close > expertAdvisorInfo.entryPoint1)//todo this logic is wrong
    {
        trade.Buy(expertAdvisorInfo.volume,Symbol(),0.0,
        expertAdvisorInfo.microChannelSize*-expertAdvisorInfo.stopLossMultiplier,
        (expertAdvisorInfo.takeProfitType==TakeProfitType(0) ? 
        0.0 : expertAdvisorInfo.microChannelSize*TakeProfitTypeToNumber()),NULL);
    }
    if(close < expertAdvisorInfo.entryPoint1)//todo this logic is wrong
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

