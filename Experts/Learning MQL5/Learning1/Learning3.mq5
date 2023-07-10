int h;
void OnTick()

{
  if(StringSubstr(TimeCurrent(),11,8) == "06:00:00")
  {
    MqlRates rates[];
    CopyRates("USDJPY",PERIOD_M15,0,24,rates);
    for (int i=0; i<24; i++)
    {
        Print(FileWrite(h, DoubleToString(rates[i].open)));
      
        Print(FileWrite(h, DoubleToString(rates[i].high)));
        
        Print(FileWrite(h, DoubleToString(rates[i].low)));

        Print(FileWrite(h, DoubleToString(rates[i].close)));
        
    }
    FileClose(h);
    Print("error=====>>>", GetLastError());
    ExpertRemove();
  }
  
}

void OnInit(){
  h= FileOpen("data.csv",FILE_WRITE|FILE_ANSI|FILE_CSV);
    
    }
