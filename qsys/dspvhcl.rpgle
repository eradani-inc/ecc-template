     H Option(*srcstmt:*nodebugio)
     H Debug

      *****************************************************************
      * File Definition Section
      *****************************************************************

     FQSYSPRT   O    F  132        Printer

      * Include EccSndReq & EccRcvReq prototypes
      /copy ecnctc

      * Include data structs and buffer conversion prototypes
      /copy vinapi_h

      *****************************************************************
      * Data Definition Section
      *****************************************************************
      *
      * Passed Parameters - Request
      *
     D  FullCmd        S             32A
     D  MyVinData      DS                  LikeDS(VinData)

      *
      * Passed Parameters - Response
      *
     D  Eod            S               N
     D  Eoa            S               N
     D  NoData         S               N
     D  MyEccResult    DS                  LikeDS(EccResult)
     D  MyVinInfo      DS                  LikeDS(VinInfo)

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
     D Cmd             C                   Const('vehicle.getdata')
      *
      *****************************************************************
      * Interfaces
      *****************************************************************
      *
     D DspVhcl         PR                  Extpgm('DSPVHCL')
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Vin                       17A
     D  In_Year                       4P 0
      *
     D DspVhcl         PI
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Vin                       17A
     D  In_Year                       4P 0

      *
     D Write_Msg       PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_EccMsg    PR
     D  In_EccResult                       LikeDS(EccResult) Const

     D Write_VinInfo   PR
     D  In_VinInfo                         LikeDS(VinInfo) Const

     D Write_Excp      PR
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const


      *****************************************************************
      * Main Line
      *****************************************************************

         *InLr = *On;

      // Assign Data To Variables

         FullCmd = Cmd;
         MyVinData.Vin = In_Vin;
         MyVinData.Year = In_Year;
         DataLen = VinDataLen;
         VinDataToBuf(MyVinData:DataBuf);

      // Send request

         Select;
           When In_Mode = '*SNDRCV';
                CallP(e) EccSndReq(FullCmd:DataLen:DataBuf:In_ReqKey);
                if %error;
                  Write_Excp('EccSndReq':Psds);
                  return;
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


      // Display The Result

         BufToEccResult(DataBuf:MyEccResult);

         If MyEccResult.MsgId <> 'ECC0000';
           Write_EccMsg(MyEccResult);
           Return;
         EndIf;

         DataLen = VinInfoLen;
         DataBuf = '';
         CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                            DataLen:DataBuf);
         if %error;
           Write_Excp('EccRcvRes':Psds);
           Return;
         endif;

         BufToVinInfo(DataBuf:MyVinInfo);
         Write_VinInfo(MyVinInfo);

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
     D  Message                            LikeDS(EccResult) Const

     D Text            DS           132    Qualified
     D  TmStmp                       23A
     D                                3A   Inz('  ')
     D  Id                            7A
     D                                3A   Inz('  ')
     D  Desc                         50A


       Text.TmStmp = %char(Message.MsgTime);
       Text.Id = Message.MsgId;
       Text.Desc = Message.MsgDesc;

       Write QSysPrt Text;

       Return;

     P Write_EccMsg    E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_VinInfo
      * Purpose.......:   Write result
      * Returns.......:   None
      * Parameters....:   Result data structure
      ***-----------------------------------------------------------***
     P Write_VinInfo   B

     D Write_VinInfo   PI
     D  In_VinInfo                         LikeDS(VinInfo) Const

     D Text1           DS           132    Qualified
     D                               25A   Inz('Electrification level: ')
     D  ElecLvl                      35A

     D Text2           DS           132    Qualified
     D                               14A   Inz('Primary fuel: ')
     D  FlTypPrim                    25A
     D                               18A   Inz(', Secondary fuel: ')
     D  FlTypSec                     25A

       Text1.ElecLvl = In_VinInfo.ElecLvl;
       Text2.FlTypPrim = In_VinInfo.FlTypPrim;
       Text2.FlTypSec = In_VinInfo.FlTypSec;

       Write QSysPrt Text1;
       Write QSysPrt Text2;

       Return;

     P Write_VinInfo   E

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
