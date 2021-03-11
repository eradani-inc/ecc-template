     H Nomain

      ************************************
      * Module: wthfrcapi
      * Generated RPG conversion procedures
      * Do not modify
      ************************************

      /include wthfcapi_h

      ************************************
      * Global variables
      ************************************
     DBufPtr           S               *
     DCharBuf          S            500A   Based(BufPtr)

      ************************************
      * Convert Location to buffer
      ************************************
     PLocationToBuf    B                   Export

     DLocationToBuf    PI
     DDataStruct                           LikeDS(Location)
     D                                     Const
     DBuffer                        500A

       // Initialize to beginning of buffer
       BufPtr = %addr(Buffer);

       // Write fields from DS to buffer
       %subst(CharBuf:1:11) = %char(DataStruct.Lat);
       BufPtr += 11;
       %subst(CharBuf:1:11) = %char(DataStruct.Lon);
       BufPtr += 11;

       return ;

     PLocationToBuf    E

      ************************************
      * Convert buffer to Forecast
      ************************************
     PBufToForecast    B                   Export

     DBufToForecast    PI
     DBuffer                        500A
     DDataStruct                           LikeDS(Forecast)

       // Initialize to begining of buffer
       BufPtr = %addr(Buffer);

       // Read fields from buffer into DS
       DataStruct.Date = %date(%subst(CharBuf:1:10):*ISO);
       BufPtr += 10;
       DataStruct.Min = %dec(%subst(CharBuf:1:7):5:2);
       BufPtr += 7;
       DataStruct.Max = %dec(%subst(CharBuf:1:7):5:2);
       BufPtr += 7;
       DataStruct.Desc = %subst(CharBuf:1:58);
       BufPtr += 58;

       return ;

     PBufToForecast    E
