class TodayIsTheFirstWeekDay {
public:
    double Verify(void);
};

double TodayIsTheFirstWeekDay::Verify(void) {
    MqlRates rates[];
    CopyRates(Symbol(),PERIOD_D1,1,1,rates);
    if(StringSubstr(TimeToString(rates[0].time),0,10) == StringSubstr(TimeToString(TimeCurrent()-3*PeriodSeconds(PERIOD_D1)),0,10))
    {
    return true;
    }else{return false;};
}
