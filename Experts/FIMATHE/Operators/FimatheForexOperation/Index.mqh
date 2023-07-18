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
    void ManageTrailingStop(ExpertAdvisorInfo& ex);
    void CheckWhereToOpenNextOrder(ExpertAdvisorInfo& ex);
    int TakeProfitTypeToNumber(ExpertAdvisorInfo& ex);
    void WaitForPositionEntryPoint(ExpertAdvisorInfo& ex);
    void UpdateMicroChannel(ExpertAdvisorInfo& ex);

    bool recentPosition;
public:
    void Update(ExpertAdvisorInfo& ex);
};

void FimatheForexOperation::Update(ExpertAdvisorInfo& ex) {

   ex.StopHere();
    UpdateMicroChannel(ex);
    if(ex.microRef1 == 0){return;}
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
        {ManageTrailingStop(ex);}
        //(ex.takeProfitType == TakeProfitType(0) ? 
        //0.0 : ex.entryPointRefPrice-(ex.microChannelSize*-2*TakeProfitTypeToNumber(ex)))
        PositionSelect(Symbol());
        if(PositionGetDouble(POSITION_PROFIT) == NULL)
        {
            if(PositionGetInteger(POSITION_TYPE) == 0)//buy
            {
                trade.PositionModify(PositionGetInteger(POSITION_TICKET),
                PositionGetDouble(POSITION_PRICE_OPEN)+(ex.microChannelSize*2*TakeProfitTypeToNumber(ex)),0);
            }
            if(PositionGetInteger(POSITION_TYPE) == 1)//sell
            {
                trade.PositionModify(PositionGetInteger(POSITION_TICKET),
                PositionGetDouble(POSITION_PRICE_OPEN)-(ex.microChannelSize*-2*TakeProfitTypeToNumber(ex)),0);
            }
        }
    }else if(!PositionsTotal() && recentPosition == true){
        ex.stopPosition = 0;
        ex.firstCdPastLine = false;
        ex.VerifyToLockEntryPoint();
        riskManager.AnalizeResults(); //todo
        recentPosition = false;
    }

    if(ex.PriceBelow50()){
        ex.UnlockEntryPoints();
    }
    if(ex.PriceAbove50()){
        ex.UnlockEntryPoints();
    }
      
    if(ex.upBreakThrough == true)//break through above
    {
        ex.entryPoint3 = ex.entryPoint1;
        ex.entryPoint1 = 0;
        ex.entryPoint4 = ex.entryPoint2;
        ex.entryPoint2 = 0;
        ex.upBreakThrough = false;

        if(ex.recentOperationEntryPoint == "entryPoint1")
        {ex.recentOperationEntryPoint = "entryPoint3";}
        else if(ex.recentOperationEntryPoint == "entryPoint2")
        {ex.recentOperationEntryPoint = "entryPoint4";}
        else if(ex.recentOperationEntryPoint == "entryPoint3")
        {ex.recentOperationEntryPoint = "entryPoint1";}
        else if(ex.recentOperationEntryPoint == "entryPoint4")
        {ex.recentOperationEntryPoint = "entryPoint2";}
        
    }
    if(ex.downBreakThrough == true)//break through bellow
    {
        ex.entryPoint2 = ex.entryPoint4;
        ex.entryPoint4 = 0;
        ex.entryPoint1 = ex.entryPoint3;
        ex.entryPoint3 = 0;
        ex.downBreakThrough = false;

        if(ex.recentOperationEntryPoint == "entryPoint1")
        {ex.recentOperationEntryPoint = "entryPoint3";}
        else if(ex.recentOperationEntryPoint == "entryPoint2")
        {ex.recentOperationEntryPoint = "entryPoint4";}
        else if(ex.recentOperationEntryPoint == "entryPoint3")
        {ex.recentOperationEntryPoint = "entryPoint1";}
        else if(ex.recentOperationEntryPoint == "entryPoint4")
        {ex.recentOperationEntryPoint = "entryPoint2";}

    }

    if(ex.entryPoint1 == 0 || ex.entryPoint2 == 0 || 
    ex.entryPoint3 == 0 || ex.entryPoint4 == 0){
        CheckWhereToOpenNextOrder(ex);
    }

    if((ex.entryPoint1 != 0 && ex.entryPoint1 != -1) || (ex.entryPoint2 != 0 && ex.entryPoint2 != -1) || 
    (ex.entryPoint3 != 0 && ex.entryPoint3 != -1) || (ex.entryPoint4 != 0 && ex.entryPoint4 != -1)){
        WaitForPositionEntryPoint(ex);
    }
}

void FimatheForexOperation::ManageTrailingStop(ExpertAdvisorInfo& ex) {
    PositionSelect(Symbol());
    if(PositionGetInteger(POSITION_TYPE) == 0) //buy
    {
        if(ex.GetLastClosePriceM15() > PositionGetDouble(POSITION_PRICE_OPEN) + ex.microChannelSize 
        )
        {
            if(ex.firstCdPastLine == true && ex.stopPosition == 0)
            {
                if (ex.GetLastClosePriceM15() > ex.firstCdPastLineClose)
                {
                    ex.stopPosition = 1;
                    trade.PositionModify(PositionGetInteger(POSITION_TICKET),PositionGetDouble(POSITION_PRICE_OPEN),0);
                }

            }else if(ex.stopPosition == 0){
                ex.firstCdPastLine = true;
                ex.firstCdPastLineClose = ex.GetLastClosePriceM15();
            }

            if(ex.GetLastClosePriceM15() > ex.entryPointRefPrice +
             (ex.microChannelSize*2) && ex.stopPosition == 1 &&
             ex.takeProfitType == TakeProfitType(0))
            {
                    ex.stopPosition = 2;
                    trade.PositionModify(PositionGetInteger(POSITION_TICKET),0.75*ex.microChannelSize + ex.entryPointRefPrice,0);

            }else if(ex.GetLastClosePriceM15() > PositionGetDouble(POSITION_SL) + 
            (2.25*ex.microChannelSize) && ex.stopPosition == 2 &&
             ex.takeProfitType == TakeProfitType(0))
            {
                trade.PositionModify(PositionGetInteger(POSITION_TICKET),PositionGetDouble(POSITION_SL)+ex.microChannelSize,0);
            }  
        }
    }else if(PositionGetInteger(POSITION_TYPE) == 1) //sell
    {
        if(ex.GetLastClosePriceM15() < PositionGetDouble(POSITION_PRICE_OPEN) - ex.microChannelSize)
        {
            if(ex.firstCdPastLine == true && ex.stopPosition == 0)
            {
                if (ex.GetLastClosePriceM15() < ex.firstCdPastLineClose)
                {
                    ex.stopPosition = 1;
                    trade.PositionModify(PositionGetInteger(POSITION_TICKET),PositionGetDouble(POSITION_PRICE_OPEN),0);
                }

            }else if(ex.stopPosition == 0){
                ex.firstCdPastLine = true;
                ex.firstCdPastLineClose = ex.GetLastClosePriceM15();
            }

            if(ex.GetLastClosePriceM15() < ex.entryPointRefPrice -
             (ex.microChannelSize*2) && ex.stopPosition == 1 &&
             ex.takeProfitType == TakeProfitType(0))
            {
                    ex.stopPosition = 2;
                    trade.PositionModify(PositionGetInteger(POSITION_TICKET),ex.entryPointRefPrice - 0.75*ex.microChannelSize,0);

            }else if(ex.GetLastClosePriceM15() < PositionGetDouble(POSITION_SL) - 
            (2.25*ex.microChannelSize) && ex.stopPosition == 2 &&
             ex.takeProfitType == TakeProfitType(0))
            {
                trade.PositionModify(PositionGetInteger(POSITION_TICKET),PositionGetDouble(POSITION_SL) - ex.microChannelSize,0);
            }  
        }
    }
}

void FimatheForexOperation::CheckWhereToOpenNextOrder(ExpertAdvisorInfo& ex) {
    if(riskManager.AuthorizeOperations() == false)//todo wait for sunday, and other logics
    {
        return;
    }
    ex.TryToDefine1And4();

}

void FimatheForexOperation::UpdateMicroChannel(ExpertAdvisorInfo& ex){
    if(todayIsTheFirstWeekDay.Verify() && StringSubstr(TimeToString(TimeCurrent()),11,2) == "06")
    {ex.CreateNewMicroChannel();}
    else if(ex.microRef1 != 0){ex.UpdateMicroChannel();}
    else{return;}
}

void FimatheForexOperation::WaitForPositionEntryPoint(ExpertAdvisorInfo& ex){
    
    double close = ex.GetLastClosePriceM15();
    if((close > ex.entryPoint3) && (ex.entryPoint3 != 0) && (ex.entryPoint3 != -1) && (PositionsTotal() == false))
    {
        ex.entryPointRefPrice = ex.entryPoint3;
        ex.recentOperationEntryPoint = "entryPoint3";
        trade.Buy(ex.volume,Symbol(),0.0,
        ex.entryPointRefPrice-ex.microChannelSize*ex.stopLossMultiplier,
        (ex.takeProfitType==TakeProfitType(0) ? 
        0.0 : ex.entryPointRefPrice+(ex.microChannelSize*2*TakeProfitTypeToNumber(ex))),NULL);
    }
    if((close < ex.entryPoint2) && (ex.entryPoint2 != 0) && (ex.entryPoint2 != -1) && (PositionsTotal() == false))
      {
        ex.entryPointRefPrice = ex.entryPoint2;
        ex.recentOperationEntryPoint = "entryPoint2";
        trade.Sell(ex.volume,Symbol(),0.0,
        ex.microChannelSize*ex.stopLossMultiplier+ex.entryPointRefPrice,
        0.0,NULL);
      }   
}

int FimatheForexOperation::TakeProfitTypeToNumber(ExpertAdvisorInfo& ex) {
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

