class MicroChannel {
public:
    string GetRefs(double macroRef1,double macroRef2,double lastClosePrice,double channelDivider);
    string GetCurrent(double microRef1,double microRef2,double close);
};

string MicroChannel::GetRefs(double macroRef1,double macroRef2,double lastClosePrice,double channelDivider) {
    
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
    double midValue;
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
    double microRef1;
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
    double microRef2;
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

    return GetCurrent(microRef1,microRef2,lastClosePrice);
}

string MicroChannel::GetCurrent(double microRef1,double microRef2,double close) {

    double channelSize = microRef1-microRef2;
    
    if(microRef1 > close && microRef2 < close)
    {return DoubleToString(microRef1)+"|"+DoubleToString(microRef2);}

    if(microRef1 < close)
    {
        while (microRef1 < close)
        {microRef1 += channelSize;}
        microRef2 = microRef1 - channelSize;
        return DoubleToString(microRef1)+"|"+DoubleToString(microRef2);
    }

    if(microRef2 > close)
    {
        while (microRef2 > close)
        {microRef2 -= channelSize;}
        microRef1 = microRef2 + channelSize;
        return DoubleToString(microRef1)+"|"+DoubleToString(microRef2);
    }
    return NULL;
}
    
