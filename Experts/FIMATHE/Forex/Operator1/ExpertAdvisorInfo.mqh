#include "Enums/TakeProfitType.mqh"

class ExpertAdvisorInfo {
public:
  int fileHandle;
  double volume;
  TakeProfitType takeProfitType;
  double stopLossMultiplier;
  int stopPosition;
  double channelDivider;
  bool firstCdPastLine;
  double firstCdPastLineClose;
  bool upBreakThrough;
  bool downBreakThrough;
  bool correctionOfFirstBreakThrough;
  
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
  string recentOperationEntryPoint;
  double entryPointRefPrice;

  double GetLastClosePriceM15(void);
  double GetPositionEntryPrice(void);
  bool PriceBelow50(void);
  bool PriceAbove50(void);
  void CreateNewMicroChannel(void);
  void UpdateMicroChannel(void);
  void UpdateMacroChannel(void);
  void UnlockEntryPoints(void);
  void VerifyToLockEntryPoint(void);
  void TryToDefine1And4(void);
  void StopHere(void);
  
  ExpertAdvisorInfo() {
    stopPosition = 0; 
    firstCdPastLine = false;
    correctionOfFirstBreakThrough = true;
  }
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
    macroChannelSize = macroRef1-macroRef2;
    microRef1 = macroRef1 + (macroChannelSize/channelDivider);
    microRef2 = macroRef1;
    
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
}

void ExpertAdvisorInfo::UpdateMacroChannel() {

    double close = GetLastClosePriceM15();
    
    if(macroRef1 < close)
    {
        if(correctionOfFirstBreakThrough == false)
            {upBreakThrough = true;}
        correctionOfFirstBreakThrough = false;
        while (macroRef1 < close)
        {macroRef1 += macroChannelSize;}
        macroRef2 = macroRef1 - macroChannelSize;
    }

    if(macroRef2 > close)
    {
        if(correctionOfFirstBreakThrough == false)
            {downBreakThrough = true;}
        correctionOfFirstBreakThrough = false;
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
    if(PriceBelow50())
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
    if(recentOperationEntryPoint == "entryPoint1")
        {entryPoint1 = -1;}
    if(recentOperationEntryPoint == "entryPoint2")
        {entryPoint2 = -1;}
    if(recentOperationEntryPoint == "entryPoint3")
        {entryPoint3 = -1;}
    if(recentOperationEntryPoint == "entryPoint4")
        {entryPoint4 = -1;}
}

void ExpertAdvisorInfo::UndefineRecentOperationEntryPoint(void) {
    if(recentOperationEntryPoint == "entryPoint1")
        {entryPoint1 = 0;}
    if(recentOperationEntryPoint == "entryPoint2")
        {entryPoint2 = 0;}
    if(recentOperationEntryPoint == "entryPoint3")
        {entryPoint3 = 0;}
    if(recentOperationEntryPoint == "entryPoint4")
        {entryPoint4 = 0;}
}

bool ExpertAdvisorInfo::PriceBelow50(void) {
    if((recentOperationEntryPoint == "entryPoint1" && GetLastClosePriceM15()<(macroRef1+macroRef2)/2 &&
        entryPoint1 != 0 && upBreakThrough == false && downBreakThrough == false) ||
       (recentOperationEntryPoint == "entryPoint2" && GetLastClosePriceM15()<(macroRef1+macroRef2)/2 &&
        entryPoint2 != 0 && upBreakThrough == false && downBreakThrough == false))
        {return true;}
    else{return false;}
}
bool ExpertAdvisorInfo::PriceAbove50(void) {
    if((recentOperationEntryPoint == "entryPoint3" && GetLastClosePriceM15()>(macroRef1+macroRef2)/2 &&
        entryPoint3 != 0 && upBreakThrough == false && downBreakThrough == false) ||
       (recentOperationEntryPoint == "entryPoint4" && GetLastClosePriceM15()>(macroRef1+macroRef2)/2) &&
        entryPoint4 != 0 && upBreakThrough == false && downBreakThrough == false)
        {return true;} 
    else{return false;}
}

void ExpertAdvisorInfo::TryToDefine1And4(void) {
    if(entryPoint1 == 0) 
    {
        entryPoint1 = macroRef1 + 2*microChannelSize;;

        while (entryPoint1 < macroRef1 + microChannelSize*2)
        {entryPoint1 += microChannelSize;}
    }
    if(entryPoint4 == 0) 
    {
        entryPoint4 = macroRef2 - 2*microChannelSize;

        while (entryPoint4 > macroRef2 - microChannelSize*2)
        {entryPoint4 -= microChannelSize;}
    }
}

void ExpertAdvisorInfo::StopHere(void) {
    if(StringSubstr(TimeToString(TimeCurrent()),5,11) == "01.18 01:15")//todo mm.dd hh:mm
    {
    bool b;
    b=1;
    return;
    }
}