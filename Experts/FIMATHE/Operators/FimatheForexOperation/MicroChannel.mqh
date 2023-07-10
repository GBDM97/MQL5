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
    CopyRates(Symbol(),PERIOD_M15,0,24,rates);
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
    ArraySort(out);
    int repeatedClosePrices = 10;
    double leastDiff1 = out[repeatedClosePrices-1] - out[0];
    double medianValue;
    for (int i=1; i<ArraySize(out)-repeatedClosePrices-1; i++)
    {
      if(out[i+9]-out[i]<leastDiff1)
      {
        leastDiff1 = out[i+9]-out[i];
        medianValue = (out[i+9]+out[i])/2;
      }
    }
    double leastDiff2 = MathAbs((medianValue)-out[0]);
    double outValue;
    for (int i=1; i<ArraySize(out); i++)
    {
        if(MathAbs((medianValue)-out[i]) < leastDiff2)
        {outValue = out[i]}
    }


}
    return 0.0; //todo
