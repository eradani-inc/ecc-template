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
      /copy trfcapi.rpgleinc

      * Local Variables
     D HttpStatusN     S             10I 0

     D MsgDta          S            132A

     D Psds           SDS                  Qualified
     D MsgId                  40     46A
     D ExcpDta                91    170A

      * Constants
     D Cmd             C                   Const('gettrafficdata')
      *
      *****************************************************************
      * Interfaces
      *****************************************************************
      *
     D DspTrfcR        PR                  Extpgm('DSPTRFCR')
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Type                      10A
      *
     D DspTrfcR        PI
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Type                      10A

      * Include EccSndReq & EccRcvReq prototypes
      /copy ecnctc.rpgleinc

      *
     D Write_Msg       PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_Response  PR
     D  In_Response                        LikeDS(Response) Const

     D Write_Traffic   PR
     D  In_Traffic                         LikeDS(Traffic) Const

     D Write_Excp      PR
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const


      *****************************************************************
      * Main Line
      *****************************************************************

      // Assign Data To Variables

         FullCmd = Cmd;
         Compare.Type = In_Type;
         DataLen = %len(Compare);
         DataBuf = Compare;

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

         DataLen = %len(Response);
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

         Response = DataBuf;
         CallP Write_Response(Response);

         HttpStatusN = %Dec(Response.HttpSts:10:0);
         If (HttpStatusN < 200) or (HttpStatusN >= 300);
           Return;
         EndIf;

         DoU Eoa;
             DataLen = %len(Traffic);
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
               Traffic = DataBuf;
               CallP Write_Traffic(Traffic);
             EndIf;
         EndDo;

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
      * Procedure Name:   Write_Response
      * Purpose.......:   Write result status of web service request
      * Returns.......:   None
      * Parameters....:   Response data structure
      ***-----------------------------------------------------------***
     P Write_Response  B

     D Write_Response  PI
     D  In_Response                        LikeDS(Response) Const

     D Text            DS           132    Qualified
     D  Sts                           3A
     D                                3A   Inz(' - ')
     D  Message                      77A

       Text.Sts = In_Response.HttpSts;
       Text.Message = In_Response.Message;

       Write QSysPrt Text;

       Return;

     P Write_Response  E

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

       Text.Rank   = In_Traffic.TRank;
       Text.Street = In_Traffic.TStrtNm;
       Text.AvgSpd = In_Traffic.TAvgSpd;
       Text.Length = In_Traffic.TLength;
       Text.JamFct = In_Traffic.TJamFct;
       Text.Cnfdnc = In_Traffic.TCnfdnc;

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
       CallP Write_Msg(MsgDta);

       MsgId = In_Psds.MsgId;
       ExcpDta = In_Psds.ExcpDta;

       Write QSysPrt Text;

       Return;

     P Write_Excp      E
