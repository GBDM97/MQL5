//+------------------------------------------------------------------+
//|                                              MyExpertAdvisor.mq5 |
//|                        Copyright 2022, Your Company Name          |
//|                                              https://www.example.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Your Company Name"
#property link      "https://www.example.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Expert Advisor initialization function                           |
//+------------------------------------------------------------------+
int OnInit()
{
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert Advisor tick function                                      |
//+------------------------------------------------------------------+
void OnTick()
{
//--- Send the message
    string message = "test";
    bool res = SendNotification(message);

    if (!res)
    {
        Print("Message sending failed");
    }
    else
    {
        Print("Message sent");
    }

    return;
    // EA logic goes here
}

//+------------------------------------------------------------------+
