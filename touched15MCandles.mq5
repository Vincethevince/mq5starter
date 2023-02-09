MqlDateTime datetime_now;
input int x = 500; // number of 15M candles to check
input double price_a = 15400; // price to be touched
datetime lastMonday = 0; // buffer2B filled - last Monday 0am
int candleCount = 0; // counter for number of candles that touched priceA
int numberOfBars = 0; // counter for number of candles between 2 timestamps
int OnInit()
  {
   lastMonday = getLastMonday();
   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
  datetime time = TimeCurrent();
   if(isNewCandle(time))
      {
         lastMonday = getLastMonday();
         int adjustedNumberToCheck = x;
         int finishedBars = 1;
         candleCount = 0;
         
         if(time - x*900 < lastMonday)
           {
            adjustedNumberToCheck = (time-lastMonday)/900;
            //Print("There's more than x 15M candles since last Monday 0am.");
           }
         Print("Timestamp: ",time);
         
         for(int i=0;i < adjustedNumberToCheck;i++)
         {
            //get number of bars between start and end of the 15M candle to check -- if gap in chart (numberOfBars == 0) jump to next 15M candle
            numberOfBars = Bars(_Symbol,PERIOD_M1,time-(i+1)*900,time-60-i*900);
            if(numberOfBars == 0)
              {
                  continue;
              }
            
            //get high and low between start and end of the 15M candle to check
            double high = iHigh(_Symbol,PERIOD_M1,iHighest(_Symbol,PERIOD_M1,MODE_HIGH,numberOfBars,finishedBars));
            double low = iLow(_Symbol,PERIOD_M1,iLowest(_Symbol,PERIOD_M1,MODE_LOW,numberOfBars,finishedBars));
            finishedBars += numberOfBars;
            
            if(high>= price_a && low <= price_a)
            {
               candleCount++;
            }
          }
          
          Print("Number of 15M candles touched: ", candleCount); 
          //ulong end = GetMicrosecondCount();
          //Print("Took: ", end);
       }
   
  }

bool isNewCandle(datetime t)
  {
    // start of a new 15-minute candle? 15m*60s 
    // log instead of % ?
    return (t % (15 * 60) == 0);
  }

datetime getLastMonday()
  {
    // Current day of the week
    TimeCurrent(datetime_now);
    int dayOfWeek = datetime_now.day_of_week;
    // Calculate last Monday
    datetime lastMonday = TimeCurrent() - (dayOfWeek - 1) * 86400;
    //Monday 0am
    lastMonday = MathFloor(lastMonday / 86400) * 86400;
    return lastMonday;
  }
