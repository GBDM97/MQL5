int timeIndex;
int assetIndex;
string inputTickerList[] = {
   "ABEV3","ALOS3","ALPA4","ARZZ3","ASAI3","AURE3","AZUL4","B3SA3","BBAS3","BBDC3","BBDC4","BBSE3","BEEF3","BHIA3","BOVA11","BOVV11","BPAC11","BRAP4","BRFS3","BRKM5","CBAV3","CCRO3","CIEL3","CMIG4","CMIN3","COGN3","CPLE6","CSAN3","CSNA3","CVCB3","CYRE3","EGIE3","ELET3","ELET6","EMBR3","ENAT3","ENEV3","EQTL3","EZTC3","GFSA3","GGBR4","GOAU4","GOLL4","HAPV3","HYPE3","IRBR3","ITSA4","ITUB4","JBSS3","KLBN11","LREN3","LWSA3","MGLU3","MRFG3","MRVE3","MULT3","NTCO3","PCAR3","PETR3","PETR4","PETZ3","PRIO3","QUAL3","RADL3","RAIL3","RAIZ4","RDOR3","RENT3","RRRP3","SANB11","SBSP3","SEQL3","SMAL11","SOMA3","SUZB3","TAEE11","TRPL4","UGPA3","USIM5","VALE3","VBBR3","VIVT3","WEGE3","YDUQ3"
};
ENUM_TIMEFRAMES inputTimeList[] = {
  PERIOD_H4, PERIOD_D1, PERIOD_W1
};
void NextAsset(){
  if(assetIndex < inputTickerList.Size()-1)
  {assetIndex++;};
  ChartSetSymbolPeriod(0, inputTickerList[assetIndex],inputTimeList[timeIndex]);
  ChartRedraw();
}
void PreviousAsset(){
  if(assetIndex > 0)
  {assetIndex--;};
  ChartSetSymbolPeriod(0, inputTickerList[assetIndex],inputTimeList[timeIndex]);
  ChartRedraw();
}
void NextTime(){
  if(timeIndex < inputTimeList.Size()-1)
  {timeIndex++;};
  ChartSetSymbolPeriod(0, inputTickerList[assetIndex],inputTimeList[timeIndex]);
  ChartRedraw();
}
void PreviousTime(){
  if(timeIndex > 0)
  {timeIndex--;};
  ChartSetSymbolPeriod(0, inputTickerList[assetIndex],inputTimeList[timeIndex]);
  ChartRedraw();
}

int OnInit()
  {
   ChartRedraw();
   return INIT_SUCCEEDED;
  }

void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
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
          // InsertRefPrice()
        }
      // Print("id = "+id,"lparam = "+lparam,"dparam = "+dparam,"sparam = "+sparam);
      };
  }
