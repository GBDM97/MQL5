
int timeIndex = 2;
bool exportRunning=false;
int assetIndex;
int d = FileDelete("LiquidStocksInfo.csv", FILE_COMMON);
int fileHandle = FileOpen("LiquidStocksInfo.csv", FILE_CSV|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_COMMON,",");
int w = FileWrite(fileHandle,"<TICKER,PERIOD> <SMA_17> <SMA_34> <SMA_72> <SMA_144> <LAST_CLOSE>");
string liquidList[] = {
   "ABEV3","ALOS3","ALPA4","ARZZ3","ASAI3","AURE3","AZUL4","B3SA3","BBAS3","BBDC3","BBDC4","BBSE3","BEEF3","BHIA3","BOVA11","BOVV11","BPAC11","BRAP4","BRFS3","BRKM5","CBAV3","CCRO3","CIEL3","CMIG4","CMIN3","COGN3","CPLE6","CSAN3","CSNA3","CVCB3","CYRE3","EGIE3","ELET3","ELET6","EMBR3","ENAT3","ENEV3","EQTL3","EZTC3","GFSA3","GGBR4","GOAU4","GOLL4","HAPV3","HYPE3","IRBR3","ITSA4","ITUB4","JBSS3","KLBN11","LREN3","LWSA3","MGLU3","MRFG3","MRVE3","MULT3","NTCO3","PCAR3","PETR3","PETR4","PETZ3","PRIO3","QUAL3","RADL3","RAIL3","RAIZ4","RDOR3","RENT3","RRRP3","SANB11","SBSP3","SEQL3","SMAL11","SOMA3","SUZB3","TAEE11","TRPL4","UGPA3","USIM5","VALE3","VBBR3","VIVT3","WEGE3","YDUQ3"
};

ENUM_TIMEFRAMES inputTimeList[] = {
  PERIOD_H4, PERIOD_D1, PERIOD_W1
};

string toTimeSTR(ENUM_TIMEFRAMES t){
  if(t == PERIOD_H4){return "H4";};
  if(t == PERIOD_D1){return "D1";};
  if(t == PERIOD_W1){return "W1";};
  return "";
}

void Export(){
  exportRunning = !exportRunning;
  if(exportRunning){
    
    Print("Exporting data");};
  if(!exportRunning){Print("Export Stopped");};
}

void PrintInfo(){
  int p[] = {17,34,72,144};
  double MA[4];
  for(int i=0; i<4; i++)
    {
      double b[];
      int h = iMA(liquidList[assetIndex], inputTimeList[timeIndex], p[i], 0, MODE_SMA, PRICE_CLOSE);
      CopyBuffer(h,0,0,1,b);
      MA[i] = b[0];
      IndicatorRelease(h);
    }
  double CLOSE = iClose(liquidList[assetIndex], inputTimeList[timeIndex],0);
  const string outstr = liquidList[assetIndex]+","+toTimeSTR(inputTimeList[timeIndex])+" | "+
        "17= "+MA[0]+" | "+
        "34= "+MA[1]+" | "+
        "72= "+MA[2]+" | "+
        "144= "+MA[3]+" | "+
        "Price= "+CLOSE;
  Print(outstr);
  
  if(exportRunning){FileWrite(fileHandle,outstr);}
}
void NextAsset(){
  if(assetIndex < liquidList.Size()-1)
  {
    assetIndex++;
    PrintInfo();
  };
  ChartSetSymbolPeriod(0, liquidList[assetIndex],inputTimeList[timeIndex]);
  ChartRedraw();
}
void PreviousAsset(){
  if(assetIndex > 0)
  {
    assetIndex--;
    PrintInfo();
  };
  ChartSetSymbolPeriod(0, liquidList[assetIndex],inputTimeList[timeIndex]);
  ChartRedraw();
}
void NextTime(){
  if(timeIndex < inputTimeList.Size()-1)
  {
    timeIndex++;
    PrintInfo();
  };
  ChartSetSymbolPeriod(0, liquidList[assetIndex],inputTimeList[timeIndex]);
  ChartRedraw();
}
void PreviousTime(){
  if(timeIndex > 0)
  {
    timeIndex--;
    PrintInfo();
  };
  ChartSetSymbolPeriod(0, liquidList[assetIndex],inputTimeList[timeIndex]);
  ChartRedraw();
}

int IndexOfCurrentAsset(string code){
  for(int i = 0; i<liquidList.Size()-1; i++)
  {
    if(liquidList[i] == code){return i;}
  }
  return 0;
}

int OnInit()
  {
    ChartRedraw();
    return INIT_SUCCEEDED;
  }

void OnChartEvent(const int id,         
                  const long& lparam,   
                  const double& dparam, 
                  const string& sparam)
  {
      if(id == CHARTEVENT_KEYDOWN)
      {
        if(sparam == 17)
        {
          NextTime();
        }
        if(sparam == 31)
        {
          PreviousTime();
        }
        if(sparam == 32)
        {
          NextAsset();
        }
        if(sparam == 30)
        {
          PreviousAsset();
        }
        if(sparam == 18)
        {
          Export();
        }
        if(sparam == 45)
        {
          Print("======= Stopping Execution =======");
          ExpertRemove();
        }
        
      };
      if(CHARTEVENT_CHART_CHANGE)
      {assetIndex = IndexOfCurrentAsset(_Symbol);}
      // Print("id = "+id,"lparam = "+lparam,"dparam = "+dparam,"sparam = "+sparam);
  }
  
void OnDeinit(){FileClose(fileHandle);}
