
#include "StocksFinder.mqh"

StocksFinder sf

void OnStart()
{
   string tickerNames[] = {
   "ABEV3","ALOS3","ALPA4","ARZZ3","ASAI3","AURE3","AZUL4","B3SA3","BBAS3","BBDC3","BBDC4","BBSE3","BEEF3","BHIA3","BOVA11","BOVV11","BPAC11","BRAP4","BRFS3","BRKM5","CBAV3","CCRO3","CIEL3","CMIG4","CMIN3","COGN3","CPLE6","CSAN3","CSNA3","CVCB3","CYRE3","EGIE3","ELET3","ELET6","EMBR3","ENAT3","ENEV3","EQTL3","EZTC3","GFSA3","GGBR4","GOAU4","GOLL4","HAPV3","HYPE3","IRBR3","ITSA4","ITUB4","JBSS3","KLBN11","LREN3","LWSA3","MGLU3","MRFG3","MRVE3","MULT3","NTCO3","PCAR3","PETR3","PETR4","PETZ3","PRIO3","QUAL3","RADL3","RAIL3","RAIZ4","RDOR3","RENT3","RRRP3","SANB11","SBSP3","SEQL3","SMAL11","SOMA3","SUZB3","TAEE11","TRPL4","UGPA3","USIM5","VALE3","VBBR3","VIVT3","WEGE3","YDUQ3"
   };
   int ma_handle = iMA(_Symbol,_Period, 144, 0, MODE_SMA, PRICE_CLOSE);
   double ma_buffer[];
   CopyBuffer(ma_handle, 0, 0, 1, ma_buffer);
   Print(NormalizeDouble(ma_buffer[0],3));
   IndicatorRelease(ma_handle);
   Print(tickerNames[2]);
}
