int h;

void OnInit()
{
      h = FileOpen("optimization_results.csv",FILE_CSV|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_COMMON,",");
}

void OnTick() 
{
    FileWrite(h,"helloHELLOhello"); //The files go to "Users\AppData\Roaming\MetaQuotes\Terminal\Common\Files"
    
}

void OnDeinit(const int reason) 
{
    FileClose(h);
    //Print(FileDelete(TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\Common\\optimization_results.csv"),"THIS IS THE OUTPUT" ); //NOT WORKING!
    FileDelete("optimization_results.csv",FILE_COMMON);
}