     H Nomain

      ************************************
      * Module: icndbapi
      * Generated RPG conversion procedures
      * Do not modify
      ************************************

      /include icndbapi_h

      ************************************
      * Global variables
      ************************************
     DBufPtr           S               *
     DCharBuf          S            500A   Based(BufPtr)

      ************************************
      * Convert ReqData to buffer
      ************************************
     PReqDataToBuf     B                   Export

     DReqDataToBuf     PI
     DDataStruct                           LikeDS(ReqData)
     D                                     Const
     DBuffer                        500A

       // Initialize to beginning of buffer
       BufPtr = %addr(Buffer);

       // Write fields from DS to buffer
       %subst(CharBuf:1:15) = DataStruct.Category;
       BufPtr += 15;

       return ;

     PReqDataToBuf     E

      ************************************
      * Convert buffer to ResData
      ************************************
     PBufToResData     B                   Export

     DBufToResData     PI
     DBuffer                        500A
     DDataStruct                           LikeDS(ResData)

       // Initialize to begining of buffer
       BufPtr = %addr(Buffer);

       // Read fields from buffer into DS
       DataStruct.Joke = %subst(CharBuf:1:80);
       BufPtr += 80;

       return ;

     PBufToResData     E
