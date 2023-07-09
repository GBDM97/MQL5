class MacroChannel {
protected:
    string GetCurrent(double macroRef1,double macroInitRef2,double lastClosePrice);
public:
    double GetRef1(double macroRef1,double macroInitRef2,double lastClosePrice);
    double GetRef2(double macroRef1,double macroInitRef2,double lastClosePrice);

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

double MacroChannel::GetRef1(double macroRef1,double macroRef2,double close) {
    string refstr = GetCurrent(macroRef1,macroRef2,close);
    string outputArray[2];
    StringSplit(refstr,124,outputArray);
    return StringToDouble(outputArray[0]);

}

double MacroChannel::GetRef2(double macroRef1,double macroRef2,double close) {
    string refstr = GetCurrent(macroRef1,macroRef2,close);
    string outputArray[2];
    StringSplit(refstr,124,outputArray);
    return StringToDouble(outputArray[1]);
}



