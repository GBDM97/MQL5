void OnTick()

{ double out[];
  if(StringSubstr(TimeCurrent(),11,8) == "06:00:00")
  {
    MqlRates rates[];
    CopyRates("USDJPY",PERIOD_M15,0,24,rates);
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
    double leastDifference = out[repeatedClosePrices-1] - out[0];
    double medianValue;
    for (int i=1; i<ArraySize(out)-repeatedClosePrices-1; i++)
    {
      if(out[i+9]-out[i]<leastDifference)
      {
        leastDifference = out[i+9]-out[i];
        medianValue = (out[i+9]+out[i])/2;
      }
    }
    Print("MedianValue of the 10 closest elements is ========>>>>", medianValue);
    ExpertRemove();
  }
  
}
