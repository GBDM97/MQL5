int h;

void OnInit()
{
      h = FileOpen("optimization_results.csv",FILE_CSV|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_COMMON,",");
}

void OnTick() 
{
    FileWrite(h,"helloHELLOhello"); //The files go to "Users\AppData\Roaming\MetaQuotes\Terminal\Common\Files"
}

void OnDeInit() 
{
    FileClose(h);
}