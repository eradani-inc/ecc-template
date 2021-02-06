DSPWF:CMD PROMPT('Test WF API')

  PARM KWD(MODE) TYPE(*CHAR) LEN(10) RSTD(*YES) +
       VALUES(*SNDRCV *RCVONLY) DFT('*SNDRCV') +
       PROMPT('Run mode')

  PARM KWD(WAITTM) TYPE(*DEC) LEN(5 0) DFT(5) +
       PROMPT('Wait time')

  PARM KWD(REQKEY) TYPE(*CHAR) LEN(6) DFT('0     ') +
       PROMPT('Request key')

  PARM KWD(LAT) TYPE(*DEC) LEN(9 6) DFT(35.803635) +
       PROMPT('Latitude')

  PARM KWD(LONG) TYPE(*DEC) LEN(9 6) DFT(-83.584213) +
       PROMPT('Longitude')
