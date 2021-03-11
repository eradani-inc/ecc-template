     H Nomain

      ************************************
      * Module: lblapi
      * Generated RPG conversion procedures
      * Do not modify
      ************************************

      /include lblapi_h

      ************************************
      * Global variables
      ************************************
     DBufPtr           S               *
     DCharBuf          S            500A   Based(BufPtr)

      ************************************
      * Convert LabelData to buffer
      ************************************
     PLabelDataToBuf   B                   Export

     DLabelDataToBuf   PI
     DDataStruct                           LikeDS(LabelData)
     D                                     Const
     DBuffer                        500A

       // Initialize to beginning of buffer
       BufPtr = %addr(Buffer);

       // Write fields from DS to buffer
       %subst(CharBuf:1:16) = DataStruct.Name;
       BufPtr += 16;
       %subst(CharBuf:1:20) = DataStruct.Addr;
       BufPtr += 20;
       %subst(CharBuf:1:10) = DataStruct.City;
       BufPtr += 10;
       %subst(CharBuf:1:2) = DataStruct.State;
       BufPtr += 2;
       %subst(CharBuf:1:5) = DataStruct.Zip;
       BufPtr += 5;
       %subst(CharBuf:1:3) = DataStruct.Country;
       BufPtr += 3;
       %subst(CharBuf:1:5) = DataStruct.Wgt;
       BufPtr += 5;
       %subst(CharBuf:1:2) = DataStruct.WgtUnts;
       BufPtr += 2;
       %subst(CharBuf:1:5) = DataStruct.Height;
       BufPtr += 5;
       %subst(CharBuf:1:5) = DataStruct.Width;
       BufPtr += 5;
       %subst(CharBuf:1:5) = DataStruct.Length;
       BufPtr += 5;
       %subst(CharBuf:1:2) = DataStruct.DimUnts;
       BufPtr += 2;

       return ;

     PLabelDataToBuf   E

      ************************************
      * Convert buffer to ShipInfo
      ************************************
     PBufToShipInfo    B                   Export

     DBufToShipInfo    PI
     DBuffer                        500A
     DDataStruct                           LikeDS(ShipInfo)

       // Initialize to begining of buffer
       BufPtr = %addr(Buffer);

       // Read fields from buffer into DS
       DataStruct.LblSts = %subst(CharBuf:1:10);
       BufPtr += 10;
       DataStruct.ShipId = %subst(CharBuf:1:11);
       BufPtr += 11;
       DataStruct.LblId = %subst(CharBuf:1:11);
       BufPtr += 11;
       DataStruct.ShipCost = %dec(%subst(CharBuf:1:12):10:2);
       BufPtr += 12;
       DataStruct.ShipCur = %subst(CharBuf:1:3);
       BufPtr += 3;
       DataStruct.InsCost = %dec(%subst(CharBuf:1:12):10:2);
       BufPtr += 12;
       DataStruct.InsCur = %subst(CharBuf:1:3);
       BufPtr += 3;

       return ;

     PBufToShipInfo    E

      ************************************
      * Convert buffer to Label
      ************************************
     PBufToLabel       B                   Export

     DBufToLabel       PI
     DBuffer                        500A
     DDataStruct                           LikeDS(Label)

       // Initialize to begining of buffer
       BufPtr = %addr(Buffer);

       // Read fields from buffer into DS
       DataStruct.TrackNbr = %subst(CharBuf:1:30);
       BufPtr += 30;
       DataStruct.LblPdf = %subst(CharBuf:1:23);
       BufPtr += 23;
       DataStruct.LblZpl = %subst(CharBuf:1:23);
       BufPtr += 23;

       return ;

     PBufToLabel       E
