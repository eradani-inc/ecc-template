CNFSMSC:CMD PROMPT('Request Confirmation Via SMS')

  PARM KWD(MODE) TYPE(*CHAR) LEN(10) RSTD(*YES) +
       VALUES(*SNDRCV *RCVONLY) DFT('*SNDRCV') +
       PROMPT('Run mode')

  PARM KWD(WAITTM) TYPE(*DEC) LEN(5 0) DFT(5) +
       PROMPT('Wait time')

  PARM KWD(REQKEY) TYPE(*CHAR) LEN(6) DFT('0     ') +
       PROMPT('Request key')

  PARM KWD(NBR) TYPE(*CHAR) LEN(15) +
       PROMPT('Send To Number')
       
  PARM KWD(REASON) TYPE(*CHAR) LEN(65) +
       PROMPT('Request Reason')
