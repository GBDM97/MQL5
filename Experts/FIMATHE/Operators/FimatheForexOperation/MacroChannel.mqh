class MacroChannel {
public:
    string GetCurrent(double macroRef1,double macroInitRef2,double lastClosePrice);
};

string MacroChannel::GetCurrent(double macroRef1,double macroRef2,double close) {
    double channelSize = macroRef1-macroRef2;
    
    if(macroRef1 > close && macroRef2 < close)
    {return DoubleToString(macroRef1)+"|"+DoubleToString(macroRef2);}

    if(macroRef1 < close)
    {
        while (macroRef1 < close)
        {macroRef1 += channelSize;}
        macroRef2 = macroRef1 - channelSize;
        return DoubleToString(macroRef1)+"|"+DoubleToString(macroRef2);
    }

    if(macroRef2 > close)
    {
        while (macroRef2 > close)
        {macroRef2 -= channelSize;}
        macroRef1 = macroRef2 + channelSize;
        return DoubleToString(macroRef1)+"|"+DoubleToString(macroRef2);
    }
    return NULL;
}



