     H Nomain

      ************************************
      * Module: trfcapi
      * Generated RPG conversion procedures
      * Do not modify
      ************************************

      /include trfcapi_h

      ************************************
      * Global variables
      ************************************
     DBufPtr           S               *
     DCharBuf          S            500A   Based(BufPtr)

      ************************************
      * Convert Compare to buffer
      ************************************
     PCompareToBuf     B                   Export

     DCompareToBuf     PI
     DDataStruct                           LikeDS(Compare)
     D                                     Const
     DBuffer                        500A

       // Initialize to beginning of buffer
       BufPtr = %addr(Buffer);

       // Write fields from DS to buffer
       %subst(CharBuf:1:10) = DataStruct.Type;
       BufPtr += 10;

       return ;

     PCompareToBuf     E

      ************************************
      * Convert buffer to Traffic
      ************************************
     PBufToTraffic     B                   Export

     DBufToTraffic     PI
     DBuffer                        500A
     DDataStruct                           LikeDS(Traffic)

       // Initialize to begining of buffer
       BufPtr = %addr(Buffer);

       // Read fields from buffer into DS
       DataStruct.TRank = %dec(%subst(CharBuf:1:4):2:0);
       BufPtr += 4;
       DataStruct.TStrtNm = %subst(CharBuf:1:30);
       BufPtr += 30;
       DataStruct.TAvgSpd = %dec(%subst(CharBuf:1:6):4:1);
       BufPtr += 6;
       DataStruct.TLength = %dec(%subst(CharBuf:1:9):7:5);
       BufPtr += 9;
       DataStruct.TJamFct = %dec(%subst(CharBuf:1:10):8:5);
       BufPtr += 10;
       DataStruct.TCnfdnc = %dec(%subst(CharBuf:1:5):3:0);
       BufPtr += 5;

       return ;

     PBufToTraffic     E
