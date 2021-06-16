     H Option(*srcstmt:*nodebugio)
     H Debug

      *****************************************************************
      * File Definition Section
      *****************************************************************

     FQSYSPRT   O    F  132        Printer

      * Include EccSndReq & EccRcvReq prototypes
      /copy ecnctc

      * Include data structs and buffer conversion prototypes
      /copy wthfcapi_h

      *****************************************************************
      * Data Definition Section
      *****************************************************************
      *
      * Passed Parameters - Request
      *
     D  FullCmd        S             32A
     D  MyLocation     DS                  LikeDS(Location)

      *
      * Passed Parameters - Response
      *
     D  Eod            S               N
     D  Eoa            S               N
     D  NoData         S               N
     D  MyEccResult    DS                  LikeDS(EccResult)
     D  MyWeather      DS                  LikeDS(Weather)

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
     D Cmd             C                   Const('weather.getforecast')
      *
      *****************************************************************
      * Interfaces
      *****************************************************************
      *
     D DspWf           PR                  Extpgm('DSPWF')
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Lat                        9P 6
     D  In_Lon                        9P 6
      *
     D DspWf           PI
     D  In_Mode                      10A
     D  In_WaitTm                     5P 0
     D  In_ReqKey                     6A
     D  In_Lat                        9P 6
     D  In_Lon                        9P 6

      *
     D Write_Msg1      PR
     D  In_MsgDta                          Like(MsgDta) Const

     D Write_EccMsg    PR
     D  In_EccResult                       LikeDS(EccResult) Const

     D Write_Weather   PR
     D  In_Weather                         LikeDS(Weather) Const

     D Write_Excp      PR
     D  In_ProcNm                    32A   Const
     D  In_Psds                            LikeDs(Psds) Const


      *****************************************************************
      * Main Line
      *****************************************************************

         *InLr = *On;

      // Assign Data To Variables

         FullCmd = Cmd;
         MyLocation.Lat = In_Lat;
         MyLocation.Lon = In_Lon;
         DataLen = LocationLen;
         LocationToBuf(MyLocation:DataBuf);

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

         If (Eod and EoA And NoData);
           MsgDta = 'Timeout Waiting On Response: ' + In_ReqKey;
           Write_Msg1(MsgDta);
           Return;
         EndIf;


      // Display The Result

         BufToEccResult(DataBuf:MyEccResult);

         If MyEccResult.MsgId <> 'ECC0000';
           Write_EccMsg(MyEccResult);
           Return;
         EndIf;

         DataLen = WeatherLen;
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
           BufToWeather(DataBuf:MyWeather);
           Write_Weather(MyWeather);
         EndIf;

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
      * Procedure Name:   Write_EccMsg
      * Purpose.......:   Write result status of web service request
      * Returns.......:   None
      * Parameters....:   EccMsg data structure
      ***-----------------------------------------------------------***
     P Write_EccMsg    B

     D Write_EccMsg    PI
     D  In_EccResult                       LikeDS(EccResult) Const

     D Text            DS           132    Qualified
     D  TmStmp                       23A
     D                                3A   Inz('  ')
     D  Id                            7A
     D                                3A   Inz('  ')
     D  Desc                         50A


       Text.TmStmp = %char(In_EccResult.MsgTime);
       Text.Id = In_EccResult.MsgId;
       Text.Desc = In_EccResult.MsgDesc;

       Write QSysPrt Text;

       Return;

     P Write_EccMsg    E

      ***-----------------------------------------------------------***
      * Procedure Name:   Write_Weather
      * Purpose.......:   Write weather forecast
      * Returns.......:   None
      * Parameters....:   Weather data structure
      ***-----------------------------------------------------------***
     P Write_Weather   B

     D Write_Weather   PI
     D  In_Weather                         LikeDS(Weather) Const

     D i               S             10U 0
     D Text            DS           132    Qualified
     D                                6A   Inz('Date: ')
     D  Date                         10A
     D                                7A   Inz(', Min: ')
     D  Min                           6A
     D                                7A   Inz(', Max: ')
     D  Max                           6A
     D                                8A   Inz(', Desc: ')
     D  Desc                         58A

       for i = 1 to %elem(In_Weather.Forecasts);
         Text.Date = %char(In_Weather.Forecasts(i).Date);
         Text.Min = %char(In_Weather.Forecasts(i).Min);
         Text.Max = %char(In_Weather.Forecasts(i).Max);
         Text.Desc = In_Weather.Forecasts(i).Desc;

         Write QSysPrt Text;
       endfor;

       Return;

     P Write_Weather   E

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
       Write_Msg1(MsgDta);

       MsgId = In_Psds.MsgId;
       ExcpDta = In_Psds.ExcpDta;

       Write QSysPrt Text;

       Return;

     P Write_Excp      E
