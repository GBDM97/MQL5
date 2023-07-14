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
    ExpertAdvisorInfo ex;

    bool recentPosition;
public:
    void Update(ExpertAdvisorInfo& paramExpertAdvisorInfo);
};

void FimatheForexOperation::Update(ExpertAdvisorInfo& paramExpertAdvisorInfo) {
    
    ex = paramExpertAdvisorInfo;

    UpdateMicroChannel();
    ex.UpdateMacroChannel();
    
    if(PositionsTotal()) 
    {
        recentPosition = true;
        if(
            (ex.takeProfitType == TakeProfitType(0)) ||
            (ex.takeProfitType == TakeProfitType(1) && ex.stopPosition == 0) ||
            (ex.takeProfitType == TakeProfitType(2) && ex.stopPosition == 0) ||
            (ex.takeProfitType == TakeProfitType(3) && ex.stopPosition == 0) ||
            (ex.takeProfitType == TakeProfitType(4) && ex.stopPosition == 0)
           )
        {ManageTrailingStop();}

    }else if(!PositionsTotal() && recentPosition == true){
        ex.stopPosition = 0;
        ex.firstCdPastLine = false;
        ex.VerifyToLockEntryPoint();
        riskManager.AnalizeResults(); //todo
        recentPosition = false;
    }

    if(ex.entryPoint1 == 0 || ex.entryPoint2 == 0 || 
    ex.entryPoint3 == 0 || ex.entryPoint4 == 0){
        CheckWhereToOpenNextOrder();
    }

    if(ex.entryPoint1 != 0 || ex.entryPoint2 != 0 || 
    ex.entryPoint3 != 0 || ex.entryPoint4 != 0){
        WaitForPositionEntryPoint();
    }
}

void FimatheForexOperation::ManageTrailingStop(void) {
    PositionSelect(Symbol());
    if(PositionGetInteger(POSITION_TYPE) == 1)
    {
        if(ex.GetLastClosePriceM15() > PositionGetDouble(POSITION_PRICE_OPEN) + ex.microChannelSize 
        && ex.stopPosition == 0)
        {
            if(ex.firstCdPastLine == true)
            {
                if (ex.GetLastClosePriceM15() > ex.firstCdPastLineClose)
                {
                    ex.stopPosition = 1;
                    trade.PositionModify(Symbol(),PositionGetDouble(POSITION_PRICE_OPEN),0);
                }

            }else{
                ex.firstCdPastLine = true;
                ex.firstCdPastLineClose = ex.GetLastClosePriceM15();
            }

            if(ex.GetLastClosePriceM15() > ex.entryPointRefPrice +
             (ex.microChannelSize*2) && ex.stopPosition == 1 &&
             ex.takeProfitType == TakeProfitType(0))
            {
                    ex.stopPosition = 2;
                    trade.PositionModify(Symbol(),MathRound(0.75*ex.microChannelSize + ex.entryPointRefPrice),0);

            }else if(ex.GetLastClosePriceM15() > PositionGetDouble(POSITION_SL) + 
            (2.25*ex.microChannelSize) && ex.stopPosition == 2 &&
             ex.takeProfitType == TakeProfitType(0))
            {
                trade.PositionModify(Symbol(),PositionGetDouble(POSITION_SL)+ex.microChannelSize,0);
            }  
        }
    }else if(PositionGetInteger(POSITION_TYPE) == 2)
    {
        if(ex.GetLastClosePriceM15() < PositionGetDouble(POSITION_PRICE_OPEN) - ex.microChannelSize 
        && ex.stopPosition == 0)
        {
            if(ex.firstCdPastLine == true)
            {
                if (ex.GetLastClosePriceM15() < ex.firstCdPastLineClose)
                {
                    ex.stopPosition = 1;
                    trade.PositionModify(Symbol(),PositionGetDouble(POSITION_PRICE_OPEN),0);
                }

            }else{
                ex.firstCdPastLine = true;
                ex.firstCdPastLineClose = ex.GetLastClosePriceM15();
            }

            if(ex.GetLastClosePriceM15() < ex.entryPointRefPrice -
             (ex.microChannelSize*2) && ex.stopPosition == 1 &&
             ex.takeProfitType == TakeProfitType(0))
            {
                    ex.stopPosition = 2;
                    trade.PositionModify(Symbol(),MathRound(ex.entryPointRefPrice - 0.75*ex.microChannelSize),0);

            }else if(ex.GetLastClosePriceM15() < PositionGetDouble(POSITION_SL) - 
            (2.25*ex.microChannelSize) && ex.stopPosition == 2 &&
             ex.takeProfitType == TakeProfitType(0))
            {
                trade.PositionModify(Symbol(),PositionGetDouble(POSITION_SL) - ex.microChannelSize,0);
            }  
        }
    }
}

void FimatheForexOperation::CheckWhereToOpenNextOrder() {
    if(riskManager.AuthorizeOperations() == false)//todo wait for sunday, and other logics
    {
        return;
    }
    ex.TryToDefine1And4();

    if(ex.macroRef1-2*ex.macroChannelSize > ex.entryPoint4)//break through above
    {
        ex.entryPoint3 = ex.entryPoint1;
        ex.entryPoint4 = ex.entryPoint2;

        if(ex.recentOperationEntryPoint == "entryPoint2")
        {ex.recentOperationEntryPoint = "entryPoint4";}
        else if(ex.recentOperationEntryPoint == "entryPoint4")
        {ex.recentOperationEntryPoint = "entryPoint2";}
    }
    if(ex.macroRef2+2*ex.macroChannelSize < ex.entryPoint1)//break through bellow
    {
        ex.entryPoint2 = ex.entryPoint4;
        ex.entryPoint1 = ex.entryPoint3;

        if(ex.recentOperationEntryPoint == "entryPoint3")
        {ex.recentOperationEntryPoint = "entryPoint1";}
        else if(ex.recentOperationEntryPoint == "entryPoint1")
        {ex.recentOperationEntryPoint = "entryPoint3";}
    }
    if(ex.PriceBellow50()){
        ex.UnlockEntryPoints();
    }
    if(ex.PriceAbove50()){
        ex.UnlockEntryPoints();
    }
}

void FimatheForexOperation::UpdateMicroChannel(){
    if(todayIsTheFirstWeekDay.Verify() && StringSubstr(TimeToString(TimeCurrent()),11,8) == "06:00:00")
    {ex.CreateNewMicroChannel();}
    else{ex.UpdateMicroChannel();}
}

void FimatheForexOperation::WaitForPositionEntryPoint(){
    
    double close = ex.GetLastClosePriceM15();
    if(close > ex.entryPoint3 && ex.entryPoint3 != 0 && ex.entryPoint3 != -1 && PositionsTotal() == false)
    {
        ex.entryPointRefPrice = ex.entryPoint3;
        trade.Buy(ex.volume,Symbol(),0.0,
        ex.microChannelSize*-ex.stopLossMultiplier,
        (ex.takeProfitType==TakeProfitType(0) ? 
        0.0 : ex.microChannelSize*TakeProfitTypeToNumber()),NULL);
    }
    if(close < ex.entryPoint2 && ex.entryPoint2 != 0 && ex.entryPoint2 != -1 && PositionsTotal() == false)
      {
        ex.entryPointRefPrice = ex.entryPoint2;
        trade.Sell(ex.volume,Symbol(),0.0,
        ex.microChannelSize*ex.stopLossMultiplier,
        (ex.takeProfitType == TakeProfitType(0) ? 
        0.0 : ex.microChannelSize*-TakeProfitTypeToNumber()),NULL);
      }   
}

int FimatheForexOperation::TakeProfitTypeToNumber() {
    if(ex.takeProfitType == TakeProfitType(1))
    {return 1;}
    if(ex.takeProfitType == TakeProfitType(2))
    {return 2;}
    if(ex.takeProfitType == TakeProfitType(3))
    {return 3;}
    if(ex.takeProfitType == TakeProfitType(4))
    {return 4;}
    return NULL;
}

