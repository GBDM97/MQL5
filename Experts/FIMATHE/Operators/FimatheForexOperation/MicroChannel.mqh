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
    double leastDiff1 = out[repeatedClosePrices-1] - out[0];
    double midValue;
    for (int i=1; i<ArraySize(out)-repeatedClosePrices-1; i++)
    {
      if(out[i+9]-out[i]<leastDiff1)
      {
        leastDiff1 = out[i+9]-out[i];//this gets the least diff of repeatedClosePrices number of prices that are near
        midValue = (out[i+9]+out[i])/2;//gets the selected range mid value
      }
    }
    double leastDiff2 = MathAbs((midValue)-out[0]);
    double microChannelRef1;
    for (int i=1; i<ArraySize(out); i++)
    {
        if(MathAbs((midValue)-out[i]) < leastDiff2)
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


}
    return 0.0; //todo
