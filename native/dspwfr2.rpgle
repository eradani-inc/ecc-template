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
      /copy wthfrcapi

      * Local Variables
     D HttpStatusN     S             10I 0

     D MsgDta          S            132A

     D Psds           SDS                  Qualified
     D MsgId                  40     46A
     D ExcpDta                91    170A

      * Constants
     D Cmd             C                   Const('getweatherforecast')
      *
      *****************************************************************
      * Interfaces
      *****************************************************************
      *
     D DspWfR          PR                  Extpgm('DSPWFR')
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Lat                       10A
     D  In_Lon                       10A
      *
     D DspWfR          PI
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Lat                       10A
     D  In_Lon                       10A

      * Include EccSndReq & EccRcvReq prototypes
      /copy ecnctc

      *
     D Write_Msg1      PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_Result    PR
     D  In_Result                          LikeDS(Result) Const

     D Write_Forecast  PR
     D  In_Forecast                        LikeDS(Forecast) Const

     D Write_Excp      PR
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const


      *****************************************************************
      * Main Line
      *****************************************************************

      // Assign Data To Variables

         FullCmd = Cmd;
         Location.Lat = In_Lat;
         Location.Lon = In_Lon;
         DataLen = %len(Location);
         DataBuf = Location;

      // Send request

         Select;
           When In_Mode = '*SNDRCV';
                CallP(e) EccSndReq(FullCmd:DataLen:DataBuf:In_ReqKey);
                if %error;
                  CallP Write_Excp('EccSndReq':Psds);
                  *InLr = *On;
                  Return;
                endif;
           When In_Mode = '*RCVONLY';
           Other;
             MsgDta = 'Invalid Mode';
             CallP Write_Msg1(MsgDta);
             *InLr = *On;
             Return;
         EndSl;


      // Receive response

         DataLen = %len(Result);
         DataBuf = '';
         CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                            DataLen:DataBuf);
         if %error;
           CallP Write_Excp('EccRcvRes':Psds);
           *InLr = *On;
           Return;
         endif;

         If (Eod and EoA And NoData);
           MsgDta = 'Timeout Waiting On Response: ' + In_ReqKey;
           CallP Write_Msg1(MsgDta);
           *InLr = *On;
           Return;
         EndIf;


      // Display The Result

         Result = DataBuf;
         CallP Write_Result(Result);

         HttpStatusN = %Dec(Result.HttpStatus:10:0);
         If (HttpStatusN < 200) or (HttpStatusN >= 300);
           *InLr = *On;
           Return;
         EndIf;

         DoU Eoa;
             DataLen = %len(Forecast);
             DataBuf = '';
             CallP(e) EccRcvRes(In_WaitTm:In_ReqKey:Eod:Eoa:NoData:
                                DataLen:DataBuf);
             if %error;
               CallP Write_Excp('EccRcvRes':Psds);
               *InLr = *On;
               Return;
             endif;

             If (NoData);
               *InLr = *On;
               Return;
             Else;
               Forecast = DataBuf;
               CallP Write_Forecast(Forecast);
             EndIf;
         EndDo;

         *InLr = *On;
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
      * Procedure Name:   Write_Result
      * Purpose.......:   Write result status of web service request
      * Returns.......:   None
      * Parameters....:   Result data structure
      ***-----------------------------------------------------------***
     P Write_Result    B

     D Write_Result    PI
     D  In_Result                          LikeDS(Result) Const

     D Text            DS           132    Qualified
     D  Sts                           3A
     D                                3A   Inz(' - ')
     D  Message                      77A

       Text.Sts = In_Result.HttpStatus;
       Text.Message = In_Result.Message;

       Write QSysPrt Text;

       Return;

     P Write_Result    E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Forecast
      * Purpose.......:   Write weather forecast
      * Returns.......:   None
      * Parameters....:   Forecast data structure
      ***-----------------------------------------------------------***
     P Write_Forecast  B

     D Write_Forecast  PI
     D  In_Forecast                        LikeDS(Forecast) Const

     D Text            DS           132    Qualified
     D                                6A   Inz('Date: ')
     D  Date                         10A
     D                                7A   Inz(', Min: ')
     D  Min                           6A
     D                                7A   Inz(', Max: ')
     D  Max                           6A
     D                                8A   Inz(', Desc: ')
     D  Desc                         58A

       Text.Date = In_Forecast.Date;
       Text.Min = In_Forecast.Min;
       Text.Max = In_Forecast.Max;
       Text.Desc = In_Forecast.Desc;

       Write QSysPrt Text;

       Return;

     P Write_Forecast  E

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
       CallP Write_Msg1(MsgDta);

       MsgId = In_Psds.MsgId;
       ExcpDta = In_Psds.ExcpDta;

       Write QSysPrt Text;

       Return;

     P Write_Excp      E
