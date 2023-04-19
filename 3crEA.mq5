//+------------------------------------------------------------------+
//|                                                        3crEA.mq5 |
//|                                                    Vincethevince |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Vincethevince"
#property link      "https://www.mql5.com"
#property version   "1.00"

double botReversalToBreak;
double botReversalCancelation;
double topReversalToBreak;
double topReversalCancelation;
bool topReversalFlag;
bool botReversalFlag;
int cntBot;
int cntTop;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   botReversalToBreak = 0;
   botReversalCancelation = 0;
   botReversalFlag = false;
   topReversalCancelation = 0;
   topReversalToBreak = 0;
   topReversalFlag = false;
   cntBot = 0;
   cntTop = 0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime time = TimeCurrent();
   if(isNewCandle(time))
      {
         //if top Reversal or Bot reversal in play (=flag true) - look for latest close,
         if(botReversalFlag)
           {
               botReverse();
           }
         
         if(topReversalFlag)
           {
               topReverse();
           }
         
         //only if flag is not set
         botReversalFlag = possibleBotReversal();
         Print("BotRevFlag: ", botReversalFlag);
         topReversalFlag = possibleTopReversal();
         Print("TopRevFlag: ", topReversalFlag);
         /*if(possibleBotReversal())
           {
               ObjectCreate(0,"BotRev",OBJ_ARROW_BUY,0,TimeCurrent(),SymbolInfoDouble(_Symbol,SYMBOL_ASK));
           }
         if(possibleTopReversal())
           {
               ObjectCreate(0,"TopRev",OBJ_ARROW_SELL,0,TimeCurrent(),SymbolInfoDouble(_Symbol,SYMBOL_ASK));
           }
           */
         
          
      }
   
  }
//+------------------------------------------------------------------+


bool isNewCandle(datetime t)
{   
   int seconds = PeriodSeconds(_Period);
   return (t % seconds == 0);
}

bool possibleTopReversal()
{
   //check for candles 1 and 2, set flag if True
   
   double HH = iHigh(_Symbol,_Period,1); //higher High of last candle
   double LH = iHigh(_Symbol,_Period,2); // lower High of 2nd last candle
   double HL = iLow(_Symbol,_Period,1); //higher low of last candle
   double LL = iLow(_Symbol,_Period,2); // lower Low of 2nd last candle
   double prevClose = iClose(_Symbol,_Period,3); // close of 3rd last candle
   double prevOpen = iOpen(_Symbol,_Period,3); //open of 3rd last candle to make sure that 3rd last candle was green -> trend reversal
   
   if(HH > LH && HL > LL && prevClose > prevOpen)
     {
         topReversalCancelation = HH;
         topReversalToBreak = LL;
         return true;
     }
   return false;
}

bool possibleBotReversal()
{
   //check for candles 1 and 2, set flag if True
   
   double HH = iHigh(_Symbol,_Period,2); //higher High of 2nd last candle
   double LH = iHigh(_Symbol,_Period,1); // lower High of last candle
   double HL = iLow(_Symbol,_Period,2); //higher low of 2nd last candle
   double LL = iLow(_Symbol,_Period,1); // lower Low of last candle
   double prevClose = iClose(_Symbol,_Period,3); // close of 3rd last candle
   double prevOpen = iOpen(_Symbol,_Period,3); //open of 3rd last candle to make sure that 3rd last candle was red -> trend reversal
   
   
   if(HH > LH && HL > LL && prevClose < prevOpen)
     {
         botReversalToBreak = HH;
         botReversalCancelation = LL;
         return true;
     }
   return false;
}

void botReverse()
{
   //gets called when 2 candles formed a possible bot reversal, this should look out if the last candle closed above/under break/cancelation
   double prevClose = iClose(_Symbol,_Period,1);
   //////////////////////need to check prev High/Low as well?
   
   if(prevClose < botReversalCancelation)
     {
         botReversalFlag = false; 
         return;
     }
   if(prevClose > botReversalToBreak)
     {   
         //buy, TP = last close + (break - cancelation), SL = cancelaction
         string name;
         StringConcatenate(name, "BotRev",IntegerToString(cntBot));
         ObjectCreate(0,name,OBJ_ARROW_BUY,0,TimeCurrent(),SymbolInfoDouble(_Symbol,SYMBOL_ASK));
         cntBot++;
         Print("Debug cancel: ", botReversalCancelation);
         Print("Debug break: ", botReversalToBreak);
         botReversalFlag = false;
     }
}

void topReverse()
{
    //gets called when 2 candles formed a possible top reversal, this should look out if the last candle closed above/under cancelation/break
    double prevClose = iClose(_Symbol,_Period,1);
    ///////////////////////////need to check prev High/Low as well?
    
    if(prevClose > topReversalCancelation)
      {
         topReversalFlag = false;
         return;
      }
    
    if(prevClose < topReversalToBreak)
      {
         //sell, TP = last close - (cancelation - break), SL = cancelaction
         string name;
         StringConcatenate(name, "TopRev",IntegerToString(cntTop));
         ObjectCreate(0,name,OBJ_ARROW_SELL,0,TimeCurrent(),SymbolInfoDouble(_Symbol,SYMBOL_ASK));
         cntTop++;
         Print("Debug cancel: ", topReversalCancelation);
         Print("Debug break: ", topReversalToBreak);
         topReversalFlag = false;
      }
}

//buffer - if insideCandles, check if latest High/Low of outside Candle was broken
//buffer if 3rd candle Reversal is possible