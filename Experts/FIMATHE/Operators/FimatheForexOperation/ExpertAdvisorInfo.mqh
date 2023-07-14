#include "Enums/TakeProfitType.mqh"

class ExpertAdvisorInfo {
public:
  double volume;
  TakeProfitType takeProfitType;
  double stopLossMultiplier;
  int stopPosition = 0;
  double channelDivider;
  bool firstCdPastLine = false;
  double firstCdPastLineClose;

  double macroRef1;
  double macroRef2;
  double microRef1;
  double microRef2;
  double microChannelSize;
  double macroChannelSize;

  double entryPoint1;
  double entryPoint2;
  double entryPoint3;
  double entryPoint4;
  double recentOperationEntryPoint;
  double entryPointPrice;

  double GetLastClosePriceM15(void);
  double GetPositionEntryPrice(void);
  void CreateNewMicroChannel(void);
  void UpdateMicroChannel(void);
  void UpdateMacroChannel(void);
  void UnlockEntryPoints(void);
  void PriceBellow50(void);
  void PriceAbove50(void);
  void VerifyToLockEntryPoint(void);
  void TryToDefine1And4(void);
  
protected:
  double midValue;
  void LockRecentOperationEntryPoint(void);
  void UndefineRecentOperationEntryPoint(void);
};

double ExpertAdvisorInfo::GetLastClosePriceM15(void) {
    double Close[1];
    CopyClose(Symbol(), PERIOD_M15, 1, 1, Close);
    return Close[0];
}

void ExpertAdvisorInfo::CreateNewMicroChannel() {
    
    double rangeOfCalculation = 1.5;
    double maxMicroChannelSize = macroRef1-macroRef2/(channelDivider-rangeOfCalculation);
    double minMicroChannelSize = macroRef1-macroRef2/(channelDivider+rangeOfCalculation);

    double out[];

    MqlRates rates[];
    CopyRates(Symbol(),PERIOD_M15,0,24,rates);//24 cds behind
    for (int i=0; i<24; i++)
    {
        ArrayResize(out, ArraySize(out) + 1);
        out[ArraySize(out) - 1] = rates[i].open;
        
        ArrayResize(out, ArraySize(out) + 1);
        out[ArraySize(out) - 1] = rates[i].high;
        
        ArrayResize(out, ArraySize(out) + 1);
        out[ArraySize(out) - 1] = rates[i].low;
        
        ArrayResize(out, ArraySize(out) + 1);
        out[ArraySize(out) - 1] = rates[i].close;
    }
    ArraySort(out);//sorted array with all prices between 0 to 6 oclock
    int repeatedClosePrices = 10;
    double leastDiff = out[repeatedClosePrices-1] - out[0];

    int indexCorrection = repeatedClosePrices - 1;
    for (int i=1; i<ArraySize(out)-repeatedClosePrices-1; i++)
    {
        
        if(out[i+indexCorrection]-out[i]<leastDiff)
        {
            leastDiff = out[i+indexCorrection]-out[i];//this gets the least diff of repeatedClosePrices number of prices that are near
            midValue = (out[i+indexCorrection]+out[i])/2;//gets the selected range mid value
        }
    }
    leastDiff = MathAbs((midValue)-out[0]);
    for (int i=1; i<ArraySize(out); i++)
    {
        if(MathAbs((midValue)-out[i]) < leastDiff)
        {microRef1 = out[i];}//finds the real price near the midvalue
    }

    double firstRangeTofindSecondRef[];
    double secondRangeTofindSecondRef[];
    double out2[];
    firstRangeTofindSecondRef[0] = microRef1 + minMicroChannelSize;
    firstRangeTofindSecondRef[1] = microRef1 + maxMicroChannelSize;
    secondRangeTofindSecondRef[0] = microRef1 - minMicroChannelSize;
    secondRangeTofindSecondRef[1] = microRef1 - maxMicroChannelSize;
    for (int i=0; i<ArraySize(out); i++)
    {
        if(out[i] >= firstRangeTofindSecondRef[0] && out[i] <= firstRangeTofindSecondRef[1]){
            ArrayResize(out2, ArraySize(out2) + 1);
            out2[ArraySize(out2) - 1] = out[i];
        }
        else if(out[i] >= secondRangeTofindSecondRef[0] && out[i] <= secondRangeTofindSecondRef[1]){
            ArrayResize(out2, ArraySize(out2) + 1);
            out2[ArraySize(out2) - 1] = out[i];//now array out2 has the prices inside the ranges to find the sec microref
        }
    }
    indexCorrection = repeatedClosePrices-1-6;
    leastDiff = out2[repeatedClosePrices-1-6] - out2[0];
    for (int i=1; i<ArraySize(out)-repeatedClosePrices-1-6; i++)
    {
      if(out2[i+indexCorrection]-out2[i]<leastDiff)
      {
        leastDiff = out2[i+indexCorrection]-out2[i];//this gets the least diff of repeatedClosePrices number of prices that are near
        midValue = (out2[i+indexCorrection]+out2[i])/2;//gets the selected range mid value
      }
    }
    leastDiff = MathAbs((midValue)-out2[0]);
    for (int i=1; i<ArraySize(out2); i++)
    {
        if(MathAbs((midValue)-out2[i]) < leastDiff)
        {microRef2 = out2[i];}//finds the real price near the midvalue
    }
    
    if(microRef1 < microRef2)
    {
        double v = microRef1;
        microRef1 = microRef2;
        microRef2 = v;
    }

    UpdateMicroChannel();
}

void ExpertAdvisorInfo::UpdateMicroChannel() {

    microChannelSize = microRef1-microRef2;
    double close = GetLastClosePriceM15();

    if(microRef1 < close)
    {
        while (microRef1 < close)
        {microRef1 += microChannelSize;}
        microRef2 = microRef1 - microChannelSize;
    }

    if(microRef2 > close)
    {
        while (microRef2 > close)
        {microRef2 -= microChannelSize;}
        microRef1 = microRef2 + microChannelSize;
    }

    microChannelSize = microRef1-microRef2;
}

void ExpertAdvisorInfo::UpdateMacroChannel() {

    macroChannelSize = macroRef1-macroRef2;
    double close = GetLastClosePriceM15();
    
    if(macroRef1 < close)
    {
        while (macroRef1 < close)
        {macroRef1 += macroChannelSize;}
        macroRef2 = macroRef1 - macroChannelSize;
    }

    if(macroRef2 > close)
    {
        while (macroRef2 > close)
        {macroRef2 -= macroChannelSize;}
        macroRef1 = macroRef2 + macroChannelSize;
    }
}

void ExpertAdvisorInfo::UnlockEntryPoints(void) {
    if(entryPoint1 == -1){
        entryPoint1 = 0;
    }
    if(entryPoint2 == -1){
        entryPoint2 = 0;
    }
    if(entryPoint3 == -1){
        entryPoint3 = 0;
    }
    if(entryPoint4 == -1){
        entryPoint4 = 0;
    }
}

void ExpertAdvisorInfo::VerifyToLockEntryPoint(void) {
    if(PriceBellow50())
        {
            UndefineRecentOperationEntryPoint();
            TryToDefine1And4();
        }
    else if(PriceAbove50())
        {
            UndefineRecentOperationEntryPoint();
            TryToDefine1And4();
        }
    else{LockRecentOperationEntryPoint();}
    
}

void ExpertAdvisorInfo::LockRecentOperationEntryPoint(void) {
    if(recentOperationEntryPoint = "entryPoint1")
        {entryPoint1 = -1;}
    if(recentOperationEntryPoint = "entryPoint2")
        {entryPoint2 = -1;}
    if(recentOperationEntryPoint = "entryPoint3")
        {entryPoint3 = -1;}
    if(recentOperationEntryPoint = "entryPoint4")
        {entryPoint4 = -1;}
}

void ExpertAdvisorInfo::UndefineRecentOperationEntryPoint(void) {
    if(recentOperationEntryPoint = "entryPoint1")
        {entryPoint1 = 0;}
    if(recentOperationEntryPoint = "entryPoint2")
        {entryPoint2 = 0;}
    if(recentOperationEntryPoint = "entryPoint3")
        {entryPoint3 = 0;}
    if(recentOperationEntryPoint = "entryPoint4")
        {entryPoint4 = 0;}
}

void ExpertAdvisorInfo::PriceBellow50(void) {
    if(recentOperationEntryPoint = "entryPoint1" && GetLastClosePriceM15()<(macroRef1+macroRef2/2) ||
       recentOperationEntryPoint = "entryPoint2" && GetLastClosePriceM15()<(macroRef1+macroRef2/2))
        {return true;}
    else{return false;}
}
void ExpertAdvisorInfo::PriceAbove50(void) {
    if(recentOperationEntryPoint = "entryPoint3" && GetLastClosePriceM15()>(macroRef1+macroRef2/2) ||
       recentOperationEntryPoint = "entryPoint4" && GetLastClosePriceM15()>(macroRef1+macroRef2/2))
        {return true;}
    else{return false;}
}

void ExpertAdvisorInfo::TryToDefine1And4(void) {
    if(entryPoint1 == 0) 
    {
        entryPoint1 = microRef1;

        while (entryPoint1 < macroRef1 + microChannelSize*2)
        {entryPoint1 += microChannelSize;}
    }
    if(entryPoint4 == 0) 
    {
        entryPoint1 = microRef2;

        while (entryPoint4 > macroRef2 - microChannelSize*2)
        {entryPoint4 -= microChannelSize;}
    }
}