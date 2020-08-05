     H Option(*srcstmt:*nodebugio)
     H Debug
     H Actgrp(*NEW) Dftactgrp(*NO)

     FQSYSPRT   O    F  132        Printer

      *
      * Passed Parameters - Request
      *
     D  FullCmd        S             32A

      *
      * Passed Parameters - Response
      *
     D  Eod            S               N
     D  Eoa            S               N
     D  NoData         S               N

      *
      * Passed Parameter - both Request & Response
      *
     D  DataLen        S              5P 0
     D  DataBuf        S            512A

      *
      * Passed Pararmers for API call
      *
      /copy icndbapi.rpgleinc

      * Local Variables
     D HttpSts         S             10I 0

     D MsgDta          S            132A

     D Psds           SDS                  Qualified
     D MsgId                  40     46A
     D ExcpDta                91    170A

      * Constants
     D Cmd             C                   Const('getjoke')

      *
      *****************************************************************
      * Interfaces
      *****************************************************************
      *
     D DspJkR          PR                  Extpgm('DSPJKR')
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
      *
     D DspJkR          PI
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A

      * Include EccSndReq & EccRcvReq prototypes
      /copy ecnctc.rpgleinc

      *
     D Write_Msg1      PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_Msg2      PR
     D  In_HttpSts                         Const Like(R_HttpSts)
     D  In_Type                            Const Like(R_Type)
     D  In_Value                           Const Like(R_Value)

     D Write_Msg3      PR
     D  In_Joke                            Like(R2_Joke) Const

     D Write_Msg4      PR
     D  In_HttpSts                         Const Like(R3_HttpSts)
     D  In_Error                           Const Like(R3_Error)

     D Write_Excp      PR
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const


      *****************************************************************
      * Main Line
      *****************************************************************

      // Assign Data To Variables

         FullCmd = Cmd;
         D_Ctgry = 'nerdy';
         DataLen = %len(Data);
         DataBuf = Data;

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
           CallP Write_Msg1(MsgDta);
           Return;
         EndSl;


      // Receive response

         DataLen = %len(RetData);
         DataBuf = '';
         CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                            DataLen:DataBuf);
         if %error;
           CallP Write_Excp('EccRcvRes':Psds);
           return;
         endif;

         If (NoData);
           MsgDta = 'Timeout Waiting On Response: ' + In_ReqKey;
           CallP Write_Msg1(MsgDta);
           Return;
         EndIf;


      // Display The Result

         RetData = DataBuf;
         if (R_HttpSts = '200');
           CallP Write_Msg2(R_HttpSts:R_Type:R_Value);
           if (R_type <> 'success');
             return;
           endif;
         else;
           RetData3 = DataBuf;
           CallP Write_Msg4(R3_HttpSts:R3_Error);
           return;
         endif;

      //   HttpSts = %Dec(R_HttpSts:10:0);
      //   If (HttpSts < 200) or (HttpSts >= 300);
      //     Return;
      //   EndIf;

      // Receive and display the remaining lines, if any
         Eod = '0';
         DoW not Eod;
             DataLen = %len(RetData2);
             DataBuf = '';
             CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                                DataLen:DataBuf);
             if %error;
               CallP Write_Excp('EccRcvRes':Psds);
               return;
             endif;

             If (NoData);
               Return;
             Else;
               RetData2 = DataBuf;
               CallP Write_Msg3(R2_Joke);
             EndIf;
         EndDo;

         Return;

         *InLr = *On;

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Msg1
      * Purpose.......:   Write Message
      * Returns.......:   None
      * Parameters....:   Message Data
      ***-----------------------------------------------------------***
     P Write_Msg1      B

     D Write_Msg1      PI
     D  MsgDta                      132A   Const

     D Text            DS           132
     D  Msg                         132A

       Msg = MsgDta;

       Write QSysPrt Text;

       Return;

     P Write_Msg1      E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Msg2
      * Purpose.......:   Write Message
      * Returns.......:   None
      * Parameters....:   Message Data
      ***-----------------------------------------------------------***
     P Write_Msg2      B

     D Write_Msg2      PI
     D  In_HttpSts                         Const Like(R_HttpSts)
     D  In_Type                            Const Like(R_Type)
     D  In_Value                           Const Like(R_Value)

     D Text            DS           132
     D  Sts                           3A
     D  Sep                           3A   Inz(' - ')
     D  Type                         16A
     D  Sep2                          3A   Inz(' - ')
     D  Value                        61A

       Sts = In_HttpSts;
       Type = In_Type;
       Value = In_Value;

       Write QSysPrt Text;

       Return;

     P Write_Msg2      E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Msg3
      * Purpose.......:   Write Message
      * Returns.......:   None
      * Parameters....:   Message Data
      ***-----------------------------------------------------------***
     P Write_Msg3      B

     D Write_Msg3      PI
     D  In_Joke                            Like(R2_Joke) Const

     D Text            DS           132
     D  Joke                         80A

       Joke = In_Joke;

       Write QSysPrt Text;

       Return;

     P Write_Msg3      E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Msg4
      * Purpose.......:   Write Message
      * Returns.......:   None
      * Parameters....:   Message Data
      ***-----------------------------------------------------------***
     P Write_Msg4      B

     D Write_Msg4      PI
     D  In_HttpSts                         Const Like(R3_HttpSts)
     D  In_Error                           Const Like(R3_Error)

     D Text            DS           132
     D  Sts                           3A
     D  Sep                           3A   Inz(' - ')
     D  Error                        77A

       Sts = In_HttpSts;
       Error = In_Error;

       Write QSysPrt Text;

       Return;

     P Write_Msg4      E

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
     D  Sep                           1A   Inz(' ')
     D  ExcpDta                      80A

       MsgDta = 'Error calling ' + In_ProcNm;
       CallP Write_Msg1(MsgDta);

       MsgId = In_Psds.MsgId;
       ExcpDta = In_Psds.ExcpDta;

       Write QSysPrt Text;

       Return;

     P Write_Excp      E
