
double currentClose;
double breakOutPrice = 144.250;


  
void OnTick()
  {
      return;
      double Close[1];
      CopyClose("USDJPY", PERIOD_M1, 1, 1, Close);
      
      if (Close[0] < breakOutPrice)
         {
         currentClose = Close[0];
         SendNotification("USDJPY BreakOut! ===> " + breakOutPrice);
         ExpertRemove();
         } 
  }