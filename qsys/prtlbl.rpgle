     H Option(*srcstmt:*nodebugio)
     H Debug

      *****************************************************************
      * File Definition Section
      *****************************************************************

     FQSYSPRT   O    F  132        Printer

      * Include EccSndReq & EccRcvRes prototypes
      /copy ecnctc

      * Include data structs and buffer conversion prototypes
      /copy lblapi_h

      *****************************************************************
      * Data Definition Section
      *****************************************************************
      *
      * Passed Parameters - Request
      *
     D  FullCmd        S             32A
     D  MyLabelData    DS                  LikeDS(LabelData)

      *
      * Passed Parameters - Response
      *
     D  Eod            S               N
     D  Eoa            S               N
     D  NoData         S               N
     D  MyEccResult    DS                  LikeDS(EccResult)
     D  MyShipInfo     DS                  LikeDS(ShipInfo)
     D  MyLabel        DS                  LikeDS(Label)

      *
      * Passed Parameter - both Request & Response
      *
     D  DataLen        S              5P 0
     D  DataBuf        S          32767A

      * Local Variables
     D MsgDta          S            132A

     D Psds           SDS                  Qualified
     D MsgId                  40     46A
     D ExcpDta                91    170A

      * Constants
     D Cmd             C                   Const('shipping.getlabel')
      *
      *****************************************************************
      * Interfaces
      *****************************************************************
      *
     D PrtLbl          PR                  Extpgm('PRTLBL')
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
     D PrtLbl          PI
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
     D Write_Msg       PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_EccMsg    PR
     D  In_EccMsg                          LikeDS(EccResult) Const

     D Write_ShipInfo  PR
     D  In_ShipInfo                        LikeDS(ShipInfo) Const

     D Write_Label     PR
     D  In_Label                           LikeDS(Label) Const

     D Write_Excp      PR
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const


      *****************************************************************
      * Main Line
      *****************************************************************

         *InLr = *On;

      // Assign Data To Variables

         FullCmd = Cmd;
         MyLabelData.Name = In_Name;
         MyLabelData.Addr = In_Addr;
         MyLabelData.City = In_City;
         MyLabelData.State = In_State;
         MyLabelData.Zip = In_Zip;
         MyLabelData.Country = In_Country;
         MyLabelData.Wgt = In_Wgt;
         MyLabelData.WgtUnts = In_WgtUnts;
         MyLabelData.Height = In_Height;
         MyLabelData.Width = In_Width;
         MyLabelData.Length = In_Length;
         MyLabelData.DimUnts = In_DimUnts;
         DataLen = LabelDataLen;
         LabelDataToBuf(MyLabelData:DataBuf);

      // Send request

         Select;
           When In_Mode = '*SNDRCV';
                CallP(e) EccSndReq(FullCmd:DataLen:DataBuf:In_ReqKey);
                if %error;
                  Write_Excp('EccSndReq':Psds);
                  Return;
                endif;
           When In_Mode = '*RCVONLY';
           Other;
             MsgDta = 'Invalid Mode';
             Write_Msg(MsgDta);
             Return;
         EndSl;


      // Receive response

         DataLen = EccResultLen;
         DataBuf = '';
         CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                            DataLen:DataBuf);
         if %error;
           Write_Excp('EccRcvRes':Psds);
           Return;
         endif;

         If (Eod and EoA And NoData);
           MsgDta = 'Timeout Waiting On Response: ' + In_ReqKey;
           Write_Msg(MsgDta);
           Return;
         EndIf;



         BufToEccResult(DataBuf:MyEccResult);

         If MyEccResult.MsgId <> 'ECC0000';
           Write_EccMsg(MyEccResult);
           Return;
         EndIf;

      // Display the shipping info

         DataLen = ShipInfoLen;
         DataBuf = '';
         CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                            DataLen:DataBuf);
         if %error;
           Write_Excp('EccRcvRes':Psds);
           Return;
         endif;

         BufToShipInfo(DataBuf:MyShipInfo);
         Write_ShipInfo(MyShipInfo);

         DataLen = LabelLen;
         DataBuf = '';
         CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                            DataLen:DataBuf);
         if %error;
           Write_Excp('EccRcvRes':Psds);
           Return;
         endif;

         BufToLabel(DataBuf:MyLabel);
         Write_Label(MyLabel);

         Return;


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
      * Procedure Name:   Write_EccMsg
      * Purpose.......:   Write error status of web service request
      * Returns.......:   None
      * Parameters....:   EccResult data structure
      ***-----------------------------------------------------------***
     P Write_EccMsg    B

     D Write_EccMsg    PI
     D  In_EccRslt                         LikeDS(EccResult) Const

     D Text            DS           132    Qualified
     D  TmStmp                       23A
     D                                3A   Inz('  ')
     D  Id                            7A
     D                                3A   Inz('  ')
     D  Desc                         50A


       Text.TmStmp = %char(In_EccRslt.MsgTime);
       Text.Id = In_EccRslt.MsgId;
       Text.Desc = In_EccRslt.MsgDesc;

       Write QSysPrt Text;

       Return;

     P Write_EccMsg    E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_ShipInfo
      * Purpose.......:   Write shipping inforamation
      * Returns.......:   None
      * Parameters....:   ShipInfo data structure
      ***-----------------------------------------------------------***
     P Write_ShipInfo  B

     D Write_ShipInfo  PI
     D  In_ShipInfo                          LikeDS(ShipInfo) Const

     D Text1           DS           132    Qualified
     D                               16A   Inz('Label status: ')
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

       Text1.LblSts = In_ShipInfo.LblSts;
       Text1.ShipId = In_ShipInfo.ShipId;
       Text1.LblId = In_ShipInfo.LblId;
       Text2.ShipCost = %char(In_ShipInfo.ShipCost);
       Text2.ShipCur = In_ShipInfo.ShipCur;
       Text2.InsCost = %char(In_ShipInfo.InsCost);
       Text2.InsCur = In_ShipInfo.InsCur;

       Write QSysPrt Text1;
       Write QSysPrt Text2;

       Return;

     P Write_ShipInfo  E

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
       Write_Msg(MsgDta);

       MsgId = In_Psds.MsgId;
       ExcpDta = In_Psds.ExcpDta;

       Write QSysPrt Text;

       Return;

     P Write_Excp      E
