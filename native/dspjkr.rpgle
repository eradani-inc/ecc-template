     H Option(*srcstmt:*nodebugio)
     H Debug

     FQSYSPRT   O    F  132        Printer

      * Include EccSndReq & EccRcvReq prototypes
      /copy ecnctc.rpgleinc

      * Include data structs and buffer conversion prototypes
      /copy icndbapi.rpgleinc

      *
      * Passed Parameters - Request
      *
     D  FullCmd        S             32A
     D  MyData         DS                  LikeDS(Data)

      *
      * Passed Parameters - Response
      *
     D  Eod            S               N
     D  Eoa            S               N
     D  NoData         S               N
     D  MyRetData      DS                  LikeDS(RetData)
     D  MyRetData2     DS                  LikeDS(RetData2)
     D  MyRetData3     DS                  LikeDS(RetData3)

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

      *
     D Write_Msg1      PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_RetData   PR
     D  In_RetData                         Const LikeDS(RetData)

     D Write_RetData2  PR
     D  In_RetData2                        LikeDS(RetData2) Const

     D Write_RetData3  PR
     D  In_RetData3                        Const LikeDS(RetData3)

     D Write_Excp      PR
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const


      *****************************************************************
      * Main Line
      *****************************************************************

         *InLr = *On;

      // Assign Data To Variables

         FullCmd = Cmd;
         MyData.Ctgry = 'nerdy';
         DataLen = 80;
         DataToBuf(MyData:DataBuf);

      // Send request

         Select;
           When In_Mode = '*SNDRCV';
                CallP(e) EccSndReq(FullCmd:DataLen:DataBuf:In_ReqKey);
                if %error;
                  CallP Write_Excp('EccSndReq':Psds);
                  Return;
                endif;
           When In_Mode = '*RCVONLY';
         Other;
           MsgDta = 'Invalid Mode';
           CallP Write_Msg1(MsgDta);
           Return;
         EndSl;


      // Receive response

         DataLen = 80;
         DataBuf = '';
         CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                            DataLen:DataBuf);
         if %error;
           CallP Write_Excp('EccRcvRes':Psds);
           Return;
         endif;

         If (NoData);
           MsgDta = 'Timeout Waiting On Response: ' + In_ReqKey;
           CallP Write_Msg1(MsgDta);
           Return;
         EndIf;


      // Display The Result

         BufToRetData(DataBuf:MyRetData);
         if (MyRetData.HttpSts = 200);
           CallP Write_RetData(MyRetData);
           if (MyRetData.Type <> 'success');
             Return;
           endif;
         else;
           BufToRetData3(DataBuf:MyRetData3);
           CallP Write_RetData3(MyRetData3);
           Return;
         endif;

      // Receive and display the remaining lines, if any
         Eod = '0';
         DoW not Eod;
             DataLen = 80;
             DataBuf = '';
             CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                                DataLen:DataBuf);
             if %error;
               CallP Write_Excp('EccRcvRes':Psds);
               Return;
             endif;

             If (NoData);
               Return;
             Else;
               BufToRetData2(DataBuf:MyRetData2);
               CallP Write_RetData2(MyRetData2);
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
      * Procedure Name:   Write_RetData
      * Purpose.......:   Write Message
      * Returns.......:   None
      * Parameters....:   RetData data structure
      ***-----------------------------------------------------------***
     P Write_RetData   B

     D Write_RetData   PI
     D  In_RetData                         Const LikeDS(RetData)

     D Text            DS           132
     D  Sts                           3A
     D  Sep                           3A   Inz(' - ')
     D  Type                         16A
     D  Sep2                          3A   Inz(' - ')
     D  Value                        61A

       Sts = %char(In_RetData.HttpSts);
       Type = In_RetData.Type;
       Value = In_RetData.Value;

       Write QSysPrt Text;

       Return;

     P Write_RetData   E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_RetData2
      * Purpose.......:   Write Message
      * Returns.......:   None
      * Parameters....:   RetData2 data structure
      ***-----------------------------------------------------------***
     P Write_RetData2  B

     D Write_RetData2  PI
     D  In_RetData2                        LikeDS(RetData2) Const

     D Text            DS           132
     D  Joke                         80A

       Joke = In_RetData2.Joke;

       Write QSysPrt Text;

       Return;

     P Write_RetData2  E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_RetData3
      * Purpose.......:   Write Message
      * Returns.......:   None
      * Parameters....:   RetData3 data structure
      ***-----------------------------------------------------------***
     P Write_RetData3  B

     D Write_RetData3  PI
     D  In_RetData3                        Const LikeDS(RetData3)

     D Text            DS           132
     D  Sts                           3A
     D  Sep                           3A   Inz(' - ')
     D  Error                        77A

       Sts = %char(In_RetData3.HttpSts);
       Error = In_RetData3.Error;

       Write QSysPrt Text;

       Return;

     P Write_RetData3  E

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
