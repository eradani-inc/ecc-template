     H Option(*srcstmt:*nodebugio)
     H Debug

     FQSYSPRT   O    F  132        Printer

      * Include EccSndReq & EccRcvReq prototypes
      /copy ecnctc

      * Include data structs and buffer conversion prototypes
      /copy icndbapi_h

      *
      * Passed Parameters - Request
      *
     D  FullCmd        S             32A
     D  MyReqData      DS                  LikeDS(ReqData)

      *
      * Passed Parameters - Response
      *
     D  Eod            S               N
     D  Eoa            S               N
     D  NoData         S               N
     D  MyEccResult    DS                  LikeDS(EccResult)
     D  MyResData      DS                  LikeDS(ResData)

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
     D Cmd             C                   Const('jokes.getjoke')

      *
      *****************************************************************
      * Interfaces
      *****************************************************************
      *
     D DspJk           PR                  ExtPgm('DSPJK')
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
      *
     D DspJk           PI
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A

      *
     D Write_Msg1      PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_Joke      PR
     D  In_ResData                         LikeDS(ResData) Const

     D Write_EccMsg    PR
     D  In_Message                         Const LikeDS(EccResult)

     D Write_Excp      PR
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const


      *****************************************************************
      * Main Line
      *****************************************************************

         *InLr = *On;

      // Assign Data To Variables

         FullCmd = Cmd;
         MyReqData.Category = 'nerdy';
         DataLen = ReqDataLen;
         ReqDataToBuf(MyReqData:DataBuf);

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
           Write_Msg1(MsgDta);
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

         If (NoData);
           MsgDta = 'Timeout Waiting On Response: ' + In_ReqKey;
           Write_Msg1(MsgDta);
           Return;
         EndIf;


      // Display The Result

         BufToEccResult(DataBuf:MyEccResult);
         if (MyEccResult.MsgId <> 'ECC0000');
           Write_EccMsg(MyEccResult);
           Return;
         endif;

      // Receive and display the remaining lines, if any
         Eod = *Off;
         DoW not Eod;
             DataLen = ResDataLen;
             DataBuf = '';
             CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                                DataLen:DataBuf);
             if %error;
               Write_Excp('EccRcvRes':Psds);
               Return;
             endif;

             If (NoData);
               Return;
             Else;
               BufToResData(DataBuf:MyResData);
               Write_Joke(MyResData);
             EndIf;
         EndDo;

         Return;


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
      * Procedure Name:   Write_Joke
      * Purpose.......:   Write joke
      * Returns.......:   None
      * Parameters....:   ResData data structure
      ***-----------------------------------------------------------***
     P Write_Joke      B

     D Write_Joke      PI
     D  Data                               LikeDS(ResData) Const

     D i               S             10U 0
     D begin           S             10U 0
     D end             S             10U 0
     D Text            DS           132
     D  Joke                        100A

       for i = 1 to 10;
         Joke = %subst(Data.Joke: (i - 1) * 100 + 1: 100);
         Write QSysPrt Text;
       endfor;

       Return;

     P Write_Joke      E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_EccMsg
      * Purpose.......:   Write Message
      * Returns.......:   None
      * Parameters....:   EccResult data structure
      ***-----------------------------------------------------------***
     P Write_EccMsg    B

     D Write_EccMsg    PI
     D  Message                            Const LikeDS(EccResult)

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
       Write_Msg1(MsgDta);

       MsgId = In_Psds.MsgId;
       ExcpDta = In_Psds.ExcpDta;

       Write QSysPrt Text;

       Return;

     P Write_Excp      E
