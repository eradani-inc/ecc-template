     H Option(*srcstmt:*nodebugio)
     H Debug

      *****************************************************************
      * File Definition Section
      *****************************************************************

     FQSYSPRT   O    F  132        Printer

      * Include EccSndReq & EccRcvReq prototypes
      /copy ecnctc

      * Include data structs and buffer conversion prototypes
      /copy trfcapi_h

      *****************************************************************
      * Data Definition Section
      *****************************************************************
      *
      * Passed Parameters - Request
      *
     D  FullCmd        S             32A
     D  MyCompare      DS                  LikeDS(Compare)

      *
      * Passed Parameters - Response
      *
     D  Eod            S               N
     D  Eoa            S               N
     D  NoData         S               N
     D  MyEccResult    DS                  LikeDS(EccResult)
     D  MyTraffic      DS                  LikeDS(Traffic)

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
     D Cmd             C                   Const('traffic.getdata')
      *
      *****************************************************************
      * Interfaces
      *****************************************************************
      *
     D DspTrfc         PR                  Extpgm('DSPTRFC')
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Type                      10A
      *
     D DspTrfc         PI
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Type                      10A

      *
     D Write_Msg       PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_EccMsg    PR
     D  In_EccResult                       LikeDS(EccResult) Const

     D Write_Traffic   PR
     D  In_Traffic                         LikeDS(Traffic) Const

     D Write_Excp      PR
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const


      *****************************************************************
      * Main Line
      *****************************************************************

         *InLr = *On;

      // Assign Data To Variables

         FullCmd = Cmd;
         MyCompare.Type = In_Type;
         DataLen = CompareLen;
         CompareToBuf(MyCompare:DataBuf);

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


      // Display The Result

         BufToEccResult(DataBuf:MyEccResult);

         If MyEccResult.MsgId <> 'ECC0000';
           Write_EccMsg(MyEccResult);
           Return;
         EndIf;

         DoU Eoa;
             DataLen = TrafficLen;
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
               BufToTraffic(DataBuf:MyTraffic);
               Write_Traffic(MyTraffic);
             EndIf;
         EndDo;

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
      * Purpose.......:   Write result status of web service request
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
      * Procedure Name:   Write_Traffic
      * Purpose.......:   Write traffic report
      * Returns.......:   None
      * Parameters....:   Traffic data structure
      ***-----------------------------------------------------------***
     P Write_Traffic   B

     D Write_Traffic   PI
     D  In_Traffic                         LikeDS(Traffic) Const

     D Text            DS           132    Qualified
     D                                6A   Inz('Rank: ')
     D  Rank                          2A
     D                               10A   Inz(', Street: ')
     D  Street                       30A
     D                               13A   Inz(', Avg speed: ')
     D  AvgSpd                        7A
     D                               10A   Inz(', Length: ')
     D  Length                        7A
     D                               14A   Inz(', Jam factor: ')
     D  JamFct                        8A
     D                               14A   Inz(', Confidence: ')
     D  Cnfdnc                        3A

       Text.Rank   = %char(In_Traffic.TRank);
       Text.Street = In_Traffic.TStrtNm;
       Text.AvgSpd = %char(In_Traffic.TAvgSpd);
       Text.Length = %char(In_Traffic.TLength);
       Text.JamFct = %char(In_Traffic.TJamFct);
       Text.Cnfdnc = %char(In_Traffic.TCnfdnc);

       Write QSysPrt Text;

       Return;

     P Write_Traffic   E

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
