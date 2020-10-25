     H Option(*srcstmt:*nodebugio)
     H Debug
     H Actgrp(*NEW) Dftactgrp(*NO)

      *****************************************************************
      * File Definition Section
      *****************************************************************

     FQSYSPRT   O    F  132        Printer

      *****************************************************************
      * Data Definition Section
      *****************************************************************
      *
      * Passed Parameters - Request
      *
     D  FullCmd        S             32A
     D  DataLen        S              5P 0

      *
      * Passed Parameters - Response
      *
     D  Eod            S               N
     D  Eoa            S               N
     D  NoData         S               N

      *
      * Passed Parameter - both Request & Response
      *
     D  DataBuf        S            512A

      *
      * Passed Pararmers for API call
      *
      /copy lblapi.rpgleinc

      * Local Variables
     D HttpStatusN     S             10I 0

     D MsgDta          S            132A

     D Psds           SDS                  Qualified
     D MsgId                  40     46A
     D ExcpDta                91    170A

      * Constants
     D Cmd             C                   Const('getshippinglabel')
      *
      *****************************************************************
      * Interfaces
      *****************************************************************
      *
     D PrtLblR         PR                  Extpgm('PRTLBLR')
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Name                      16A
     D  In_Addr                      20A
     D  In_City                      10A
     D  In_State                      2A
     D  In_Zip                        5A
     D  In_Country                    3A
     D  In_Wgt                        5A
     D  In_WgtUnts                    2A
     D  In_Height                     5A
     D  In_Width                      5A
     D  In_Length                     5A
     D  In_DimUnts                    2A
      *
     D PrtLblR         PI
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Name                      16A
     D  In_Addr                      20A
     D  In_City                      10A
     D  In_State                      2A
     D  In_Zip                        5A
     D  In_Country                    3A
     D  In_Wgt                        5A
     D  In_WgtUnts                    2A
     D  In_Height                     5A
     D  In_Width                      5A
     D  In_Length                     5A
     D  In_DimUnts                    2A

      * Include EccSndReq & EccRcvReq prototypes
      /copy ecnctc.rpgleinc

      *
     D Write_Msg       PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_Error     PR
     D  In_Error                           LikeDS(Error) Const

     D Write_Result    PR
     D  In_Result                          LikeDS(Result) Const

     D Write_Label     PR
     D  In_Label                           LikeDS(Label) Const

     D Write_Excp      PR
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const


      *****************************************************************
      * Main Line
      *****************************************************************

      // Assign Data To Variables

         FullCmd = Cmd;
         LabelData.Name = In_Name;
         LabelData.Addr = In_Addr;
         LabelData.City = In_City;
         LabelData.State = In_State;
         LabelData.Zip = In_Zip;
         LabelData.Country = In_Country;
         LabelData.Wgt = In_Wgt;
         LabelData.WgtUnts = In_WgtUnts;
         LabelData.Height = In_Height;
         LabelData.Width = In_Width;
         LabelData.Length = In_Length;
         LabelData.DimUnts = In_DimUnts;
         DataLen = %len(LabelData);
         DataBuf = LabelData;

      // Send request

         Select;
           When In_Mode = '*SNDRCV';
                CallP(e) EccSndReq(FullCmd:DataLen:DataBuf:In_ReqKey);
                if %error;
                  CallP Write_Excp('EccSndReq':Psds);
                  return;
                endif;
           When In_Mode = '*RCVONLY';
           Other;
             MsgDta = 'Invalid Mode';
             CallP Write_Msg(MsgDta);
             Return;
         EndSl;


      // Receive response

         DataLen = %len(Result);
         DataBuf = '';
         CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                            DataLen:DataBuf);
         if %error;
           CallP Write_Excp('EccRcvRes':Psds);
           return;
         endif;

         If (Eod and EoA And NoData);
           MsgDta = 'Timeout Waiting On Response: ' + In_ReqKey;
           CallP Write_Msg(MsgDta);
           Return;
         EndIf;


      // Display The Result

         Result = DataBuf;

         HttpStatusN = %Dec(Result.HttpSts:10:0);
         If (HttpStatusN < 200) or (HttpStatusN >= 300);
           Error = DataBuf;
           CallP Write_Error(Error);
           Return;
         EndIf;

         CallP Write_Result(Result);

         DataLen = %len(Label);
         DataBuf = '';
         CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                            DataLen:DataBuf);
         if %error;
           CallP Write_Excp('EccRcvRes':Psds);
           return;
         endif;

         Label = DataBuf;
         CallP Write_Label(Label);

         Return;

         *InLr = *On;

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Msg
      * Purpose.......:   Write Message
      * Returns.......:   None
      * Parameters....:   Message Data
      ***-----------------------------------------------------------***
     P Write_Msg       B

     D Write_Msg       PI
     D  MsgDta                      132A   Const

     D Text            DS           132
     D  Msg                         132A

       Msg = MsgDta;

       Write QSysPrt Text;

       Return;

     P Write_Msg       E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Error
      * Purpose.......:   Write error status of web service request
      * Returns.......:   None
      * Parameters....:   Error data structure
      ***-----------------------------------------------------------***
     P Write_Error     B

     D Write_Error     PI
     D  In_Error                           LikeDS(Error) Const

     D Text            DS           132    Qualified
     D  Sts                           3A
     D                                3A   Inz(' - ')
     D  Message                      77A

       Text.Sts = In_Error.HttpSts2;
       Text.Message = In_Error.Message;

       Write QSysPrt Text;

       Return;

     P Write_Error     E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Result
      * Purpose.......:   Write result
      * Returns.......:   None
      * Parameters....:   Result data structure
      ***-----------------------------------------------------------***
     P Write_Result    B

     D Write_Result    PI
     D  In_Result                          LikeDS(Result) Const

     D Text1           DS           132    Qualified
     D                                8A   Inz('Status: ')
     D  Status                        3A
     D                               16A   Inz(', Label status: ')
     D  LblSts                       10A
     D                               15A   Inz(', Shipping ID: ')
     D  ShipId                       11A
     D                               12A   Inz(', Label ID: ')
     D  LblId                        11A

     D Text2           DS           132    Qualified
     D                               15A   Inz('Shipping cost: ')
     D  ShipCost                     10A
     D                               21A   Inz(', Shipping currency: ')
     D  ShipCur                       3A
     D                               18A   Inz(', Insurance cost: ')
     D  InsCost                      10A
     D                               25A   Inz(', Insurance currency: ')
     D  InsCur                        3A

       Text1.Status = In_Result.HttpSts;
       Text1.LblSts = In_Result.LblSts;
       Text1.ShipId = In_Result.ShipId;
       Text1.LblId = In_Result.LblId;
       Text2.ShipCost = In_Result.ShipCost;
       Text2.ShipCur = In_Result.ShipCur;
       Text2.InsCost = In_Result.InsCost;
       Text2.InsCur = In_Result.InsCur;

       Write QSysPrt Text1;
       Write QSysPrt Text2;

       Return;

     P Write_Result    E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Label
      * Purpose.......:   Write label
      * Returns.......:   None
      * Parameters....:   Label data structure
      ***-----------------------------------------------------------***
     P Write_Label     B

     D Write_Label     PI
     D  In_Label                           LikeDS(Label) Const

     D Text1           DS           132    Qualified
     D                               17A   Inz('Tracking number: ')
     D  TrackNbr                     30A

     D Text2           DS           132    Qualified
     D                               20A   Inz('Label PDF filename: ')
     D  LblPdf                       23A

     D Text3           DS           132    Qualified
     D                               20A   Inz('Label ZPL filename: ')
     D  LblZpl                       23A

       Text1.TrackNbr = In_Label.TrackNbr;
       Text2.LblPdf = In_Label.LblPdf;
       Text3.LblZpl = In_Label.LblZpl;

       Write QSysPrt Text1;
       Write QSysPrt Text2;
       Write QSysPrt Text3;

       Return;

     P Write_Label     E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Excp
      * Purpose.......:   Write Exception Message
      * Returns.......:   None
      * Parameters....:   Program Status Data Structure
      ***-----------------------------------------------------------***
     P Write_Excp      B

     D Write_Excp      PI
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const

     D Text            DS           132
     D  MsgId                         7A
     D                                1A   Inz(' ')
     D  ExcpDta                      80A

       MsgDta = 'Error calling ' + In_ProcNm;
       CallP Write_Msg(MsgDta);

       MsgId = In_Psds.MsgId;
       ExcpDta = In_Psds.ExcpDta;

       Write QSysPrt Text;

       Return;

     P Write_Excp      E
