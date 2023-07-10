#include "MacroChannel.mqh";

class MicroChannel {
public:
    double GetSize(double macroInitRef1,double macroInitRef2,double lastClosePrice,double channelDivider);
protected:
    double rangeOfCalculation;
};

double MicroChannel::GetSize(double macroInitRef1,double macroInitRef2,double lastClosePrice,double channelDivider) {
    
    double maxMicroChannelSize = macroInitRef1-macroInitRef2/(channelDivider-rangeOfCalculation);
    double minMicroChannelSize = macroInitRef1-macroInitRef2/(channelDivider+rangeOfCalculation);
    double rangeOfCalculation = 1.5;

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
    double midValue;
    double indexCorrection = repeatedClosePrices - 1;
    for (int i=1; i<ArraySize(out)-repeatedClosePrices-1; i++)
    {
      if(out[i+indexCorrection]-out[i]<leastDiff)
      {
        leastDiff = out[i+indexCorrection]-out[i];//this gets the least diff of repeatedClosePrices number of prices that are near
        midValue = (out[i+indexCorrection]+out[i])/2;//gets the selected range mid value
      }
    }
    leastDiff = MathAbs((midValue)-out[0]);
    double microChannelRef1;
    for (int i=1; i<ArraySize(out); i++)
    {
        if(MathAbs((midValue)-out[i]) < leastDiff)
        {microChannelRef1 = out[i]}//finds the real price near the midvalue
    }

    double firstRangeTofindSecondRef[];
    double secondRangeTofindSecondRef[];
    double out2[];
    firstRangeTofindSecondRef[0] = microChannelRef1 + minMicroChannelSize;
    firstRangeTofindSecondRef[1] = microChannelRef1 + maxMicroChannelSize;
    secondRangeTofindSecondRef[0] = microChannelRef1 - minMicroChannelSize;
    secondRangeTofindSecondRef[1] = microChannelRef1 - maxMicroChannelSize;
    for (int=0; i<ArraySize(out); i++)
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
    double microChannelRef2;
    for (int i=1; i<ArraySize(out2); i++)
    {
        if(MathAbs((midValue)-out2[i]) < leastDiff)
        {microChannelRef2 = out2[i]}//finds the real price near the midvalue
    }
    
    if(microChannelRef1 < microChannelRef2)
    {
        double v = microChannelRef1;
        microChannelRef1 = microChannelRef2;
        microChannelRef2 = v;
    }

    return microChannelRef1-macroInitRef2;
}
    
