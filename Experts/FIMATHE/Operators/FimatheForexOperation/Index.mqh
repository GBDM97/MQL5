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
    void WaitForPositionEntryPoint(double volume,double microChannelSize,TakeProfitType takeProfitType,double stopLossMultiplier,double[] entryPoints);
    string UpdateMicroChannelInTheBeginningOfTheWeek(double macroInitRef1,double macroInitRef2,double lastClosePrice,double channelDivider);
public:
    void Update(double volume,TakeProfitType takeProfitType,double stopLossMultiplier,double macroInitRef1,double macroInitRef2,double channelDivider);
};

void FimatheForexOperation::Update(double volume,TakeProfitType takeProfitType,double stopLossMultiplier,double macroInitRef1,double macroInitRef2,double channelDivider) {
    double lastClosePrice = lastClosePriceClass.M15();
    string outArray[];
    bool recentPosition;
    double entryPoints[4];
    double microChannelRefs[];

    StringSplit(UpdateMicroChannelInTheBeginningOfTheWeek(macroInitRef1,macroInitRef2,lastClosePrice,channelDivider),"|",outArray);
    microChannelRefs[0] = StringToDouble(outArray[0]);
    microChannelRefs[1] = StringToDouble(outArray[1]);
    
    if(PositionsTotal()) 
    {
        recentPosition = true;
        if(takeProfitType == SURF){
            ManageTrailingStop();//todo
        }else{return;}
    }else if(!PositionsTotal() && recentPosition == true){
        //todo mark specific entryPoints undefined
        RiskManager.AnalizeResults(); //todo
        recentPosition = false;
    }

    if(entryPoints[0] == -1 || entryPoints[1] == -1 || entryPoints[2] == -1 || entryPoints[3] == -1){
        CheckWhereToOpenNextOrder(volume,takeProfitType,stopLossMultiplier,macroInitRef1,macroInitRef2,channelDivider);
    }

    if(entryPoints[0] != -1 || entryPoints[1] != -1 || entryPoints[2] != -1 || entryPoints[3] != -1){
        WaitForPositionEntryPoint(volume,microChannelRefs[0]-microChannelRefs[1],takeProfitType,stopLossMultiplier,entryPoints);
    }
}

void FimatheForexOperation::ManageTrailingStop(void) {
    //todo
}

void FimatheForexOperation::CheckWhereToOpenNextOrder(double volume,TakeProfitType takeProfitType,double stopLossMultiplier,double macroInitRef1,double macroInitRef2) {
    if(riskManager.AuthorizeOperations() == false)//todo wait for sunday, and other logics
    {
        return;
    }
    //todo logic to 50% return, after position opened and get or dont get entryPoints
    if(entryPoints[0] == -1) 
    {
        entryPoints[0] = getEntryPoint.First();//todo
    }

    if(entryPoints[1] == -1) 
    {
        entryPoints[1] = getEntryPoint.Second();//todo
    }
    
    if(entryPoints[2] == -1) 
    {
        entryPoints[2] = getEntryPoint.Third();//todo
    }
    
    if(entryPoints[3] == -1) 
    {
        entryPoints[3] = getEntryPoint.Fourth();//todo
    }
    
}

string FimatheForexOperation::UpdateMicroChannelInTheBeginningOfTheWeek(double macroInitRef1,double macroInitRef2,double lastClosePrice,double channelDivider){
    if(todayIsTheFirstWeekDay.Verify() && StringSubstr(TimeCurrent(),11,8) == "06:00:00")
    {
        return microChannel.GetRefs(macroInitRef1,macroInitRef2,lastClosePrice,channelDivider);
    }
}

void FimatheForexOperation::WaitForPositionEntryPoint(double volume,double microChannelSize,TakeProfitType takeProfitType,double stopLossMultiplier,double[] entryPoints){ //todo define params
    

    if(lastClosePrice > entryPoints[0])//todo this logic is wrong
    {
        trade.Buy(volume,Symbol(),0.0,microChannelSize*-stopLossMultiplier,
        (takeProfitType==SURF ? 0.0 : microChannelSize*TakeProfitTypeToNumber(takeProfitType)),NULL);
    }
    if(lastClosePrice < entryPoints[1])//todo this logic is wrong
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

