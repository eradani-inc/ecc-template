     H Option(*srcstmt:*nodebugio)
     H Debug

      *****************************************************************
      * File Definition Section
      *****************************************************************

     FQSYSPRT   O    F  132        Printer

      * Include EccSndReq & EccRcvReq prototypes
      /copy ecnctc.rpgleinc

      * Include data structs and buffer conversion prototypes
      /copy vinapi.rpgleinc

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
     D  MyResult       DS                  LikeDS(Result)
     D  MyError        DS                  LikeDS(Error)

      *
      * Passed Parameter - both Request & Response
      *
     D  DataLen        S              5P 0
     D  DataBuf        S            512A

      * Local Variables
     D MsgDta          S            132A

     D Psds           SDS                  Qualified
     D MsgId                  40     46A
     D ExcpDta                91    170A

      * Constants
     D Cmd             C                   Const('getvehicledata')
      *
      *****************************************************************
      * Interfaces
      *****************************************************************
      *
     D DspVhclR        PR                  Extpgm('DSPVHCLR')
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Vin                       17A
     D  In_Year                       4P 0
      *
     D DspVhclR        PI
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Vin                       17A
     D  In_Year                       4P 0

      *
     D Write_Msg       PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_Error     PR
     D  In_Error                           LikeDS(Error) Const

     D Write_Result    PR
     D  In_Result                          LikeDS(Result) Const

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
         DataLen = 100;
         VinDataToBuf(MyVinData:DataBuf);

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

         DataLen = 100;
         DataBuf = '';
         CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                            DataLen:DataBuf);
         if %error;
           CallP Write_Excp('EccRcvRes':Psds);
           Return;
         endif;

         If (Eod and EoA And NoData);
           MsgDta = 'Timeout Waiting On Response: ' + In_ReqKey;
           CallP Write_Msg(MsgDta);
           Return;
         EndIf;


      // Display The Result

         BufToResult(DataBuf:MyResult);

         If (MyResult.HttpSts < 200) or (MyResult.HttpSts >= 300);
           BufToError(DataBuf:MyError);
           CallP Write_Error(MyError);
           Return;
         EndIf;

         CallP Write_Result(MyResult);

         Dsply 'end of program';
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

       Text.Sts = %char(In_Error.HttpSts);
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
     D                               25A   Inz(', Electrification level: ')
     D  ElecLvl                      35A

     D Text2           DS           132    Qualified
     D                               14A   Inz('Primary fuel: ')
     D  FlTypPrim                    25A
     D                               18A   Inz(', Secondary fuel: ')
     D  FlTypSec                     25A

       Text1.Status = %char(In_Result.HttpSts);
       Text1.ElecLvl = In_Result.ElecLvl;
       Text2.FlTypPrim = In_Result.FlTypPrim;
       Text2.FlTypSec = In_Result.FlTypSec;

       Write QSysPrt Text1;
       Write QSysPrt Text2;

       Return;

     P Write_Result    E

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
