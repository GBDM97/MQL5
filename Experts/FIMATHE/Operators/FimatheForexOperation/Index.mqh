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
    if(PositionsTotal()) 
    {
        if(takeProfitType == SURF){
            ManageTrailingStop();//todo
        }else{return;}
    }else{

        CheckWhereToOpenNextOrder(volume,takeProfitType,stopLossMultiplier,macroInitRef1,macroInitRef2,channelDivider);
    }
}

void FimatheForexOperation::ManageTrailingStop(void) {
    //todo
}

void FimatheForexOperation::CheckWhereToOpenNextOrder(double volume,TakeProfitType takeProfitType,double stopLossMultiplier,double macroInitRef1,double macroInitRef2,double channelDivider) {
    if(riskManager.AuthorizeOperations() == false)//todo
    {
        return;
    }
    double lastClosePrice = lastClosePriceClass.M15();

    if(todayIsTheFirstWeekDay.Verify() && StringSubstr(TimeCurrent(),11,8) == "06:00:00")
    {
        StringSplit(microChannel.GetRefs(macroInitRef1,macroInitRef2,lastClosePrice,channelDivider),"|",outArray);
        microChannelRefs[0] = StringToDouble(outArray[0]);
        microChannelRefs[1] = StringToDouble(outArray[1]);
        microChannelSize = microChannelRefs[0]-microChannelRefs[1];
    }
    if(EntryPoints[0] == -1 && EntryPoints[1] == -1) 
    {
        EntryPoints[0] = getEntryPoint.Above();//todo
        EntryPoints[1] = getEntryPoint.Bellow();//todo
    }

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

