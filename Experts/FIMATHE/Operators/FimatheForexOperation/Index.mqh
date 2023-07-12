#include <Trade/Trade.mqh>
#include "Utils/LastClosePrice.mqh"
#include "Utils/TodayIsTheFirstWeekDay.mqh"
#include "RiskManager.mqh"
#include "GetEntryPoint.mqh"
#include "MicroChannel.mqh"

CTrade trade;
LastClosePrice lastClosePriceClass;
RiskManager riskManager;
GetEntryPoint getEntryPoint;
MicroChannel microChannel;
TodayIsTheFirstWeekDay todayIsTheFirstWeekDay;

class FimatheForexOperation {
protected:
    double EntryPoints[2];
    double microChannelRefs[];
    double microChannelSize;
    string outArray[];
    bool recentPosition;
    enum TakeProfitType {
        SURF, 
        ONE_LEVEL,
        TWO_LEVELS,
        THREE_LEVELS,
        FOUR_LEVELS
    };

    void ManageTrailingStop(void);
    void CheckWhereToOpenNextOrder(double volume,TakeProfitType takeProfitType,double stopLossMultiplier,double macroInitRef1,double macroInitRef2,double channelDivider);
    int TakeProfitTypeToNumber(TakeProfitType takeProfitType);
public:
    void Update(double volume,TakeProfitType takeProfitType,double stopLossMultiplier,double macroInitRef1,double macroInitRef2,double channelDivider);
};

void FimatheForexOperation::Update(double volume,TakeProfitType takeProfitType,double stopLossMultiplier,double macroInitRef1,double macroInitRef2,double channelDivider) {
    UpdateMicroChannelInTheBeginningOfTheWeek();
    if(PositionsTotal()) 
    {
        recentPosition = true;
        if(takeProfitType == SURF){
            ManageTrailingStop();//todo
        }else{return;}
    }else if(!PositionsTotal() && recentPosition == true){
        //todo mark specific EntryPoints undefined
        RiskManager.AnalizeResults(); //todo
        recentPosition = false;
    }
    if(EntryPoints[0] == -1 || EntryPoints[1] == -1 || EntryPoints[2] == -1 || EntryPoints[3] == -1){
        CheckWhereToOpenNextOrder(volume,takeProfitType,stopLossMultiplier,macroInitRef1,macroInitRef2,channelDivider);
    }
    if(EntryPoints[0] != -1 || EntryPoints[1] != -1 || EntryPoints[2] != -1 || EntryPoints[3] != -1){
        WaitForPositionEntryPoint();
    }
}

void FimatheForexOperation::ManageTrailingStop(void) {
    //todo
}

void FimatheForexOperation::CheckWhereToOpenNextOrder(double volume,TakeProfitType takeProfitType,double stopLossMultiplier,double macroInitRef1,double macroInitRef2,double channelDivider) {
    if(riskManager.AuthorizeOperations() == false)//todo wait for sunday, and other logics
    {
        return;
    }
    //todo logic to 50% return, after position opened and get or dont get EntryPoints
    if(EntryPoints[0] == -1) 
    {
        EntryPoints[0] = getEntryPoint.First();//todo
    }

    if(EntryPoints[1] == -1) 
    {
        EntryPoints[1] = getEntryPoint.Second();//todo
    }
    
    if(EntryPoints[2] == -1) 
    {
        EntryPoints[2] = getEntryPoint.Third();//todo
    }
    
    if(EntryPoints[3] == -1) 
    {
        EntryPoints[3] = getEntryPoint.Fourth();//todo
    }
    
}

void FimatheForexOperation::UpdateMicroChannelInTheBeginningOfTheWeek(){ //todo write the correct params, and try to put some as global vars
    double lastClosePrice = lastClosePriceClass.M15();
    if(todayIsTheFirstWeekDay.Verify() && StringSubstr(TimeCurrent(),11,8) == "06:00:00")
    {
        StringSplit(microChannel.GetRefs(macroInitRef1,macroInitRef2,lastClosePrice,channelDivider),"|",outArray);
        microChannelRefs[0] = StringToDouble(outArray[0]);
        microChannelRefs[1] = StringToDouble(outArray[1]);
        microChannelSize = microChannelRefs[0]-microChannelRefs[1];
    }
}

void FimatheForexOperation::WaitForPositionEntryPoint(){ //todo define params
    if(lastClosePrice > EntryPoints[0])//todo this logic is wrong
    {
        trade.Buy(volume,Symbol(),0.0,microChannelSize*-stopLossMultiplier,
        (takeProfitType==SURF ? 0.0 : microChannelSize*TakeProfitTypeToNumber(takeProfitType)),NULL);
    }
    if(lastClosePrice < EntryPoints[1])//todo this logic is wrong
      {
        trade.Sell(volume,Symbol(),0.0,microChannelSize*stopLossMultiplier,
        (takeProfitType==SURF ? 0.0 : microChannelSize*-TakeProfitTypeToNumber(takeProfitType)),NULL);
      }   
}

int FimatheForexOperation::TakeProfitTypeToNumber(TakeProfitType takeProfitType) {
    if(takeProfitType == ONE_LEVEL)
    {return 1;}
    if(takeProfitType == TWO_LEVELS)
    {return 2;}
    if(takeProfitType == THREE_LEVELS)
    {return 3;}
    if(takeProfitType == FOUR_LEVELS)
    {return 4;}
    return NULL;
}

