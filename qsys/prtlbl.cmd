PRTLBL:CMD PROMPT('Get USPS Shipping Label')

  PARM KWD(MODE) TYPE(*CHAR) LEN(10) RSTD(*YES) +
       VALUES(*SNDRCV *RCVONLY) DFT('*SNDRCV') +
       PROMPT('Run mode')

  PARM KWD(WAITTM) TYPE(*DEC) LEN(5 0) DFT(5) +
       PROMPT('Wait time')

  PARM KWD(REQKEY) TYPE(*CHAR) LEN(6) DFT('0     ') +
       PROMPT('Request key')

  PARM KWD(NAME) TYPE(*CHAR) LEN(16) +
       PROMPT('Ship To Name')

  PARM KWD(ADDR) TYPE(*CHAR) LEN(20) +
       PROMPT('Ship To Address')

  PARM KWD(CITY) TYPE(*CHAR) LEN(10) +
       PROMPT('Ship To City')

  PARM KWD(STATE) TYPE(*CHAR) LEN(2) +
       PROMPT('Ship To State')

  PARM KWD(ZIP) TYPE(*CHAR) LEN(5) +
       PROMPT('Ship To Zip')

  PARM KWD(COUNTRY) TYPE(*CHAR) LEN(3) +
       PROMPT('Ship To Country')

  PARM KWD(WGT) TYPE(*CHAR) LEN(5) +
       PROMPT('Package Weight')

  PARM KWD(WGTUNTS) TYPE(*CHAR) LEN(2) +
       VALUES(OZ) RSTD(*YES) DFT('OZ') +
       PROMPT('Package Weight Units')

  PARM KWD(HEIGHT) TYPE(*CHAR) LEN(5) +
       PROMPT('Package Height')

  PARM KWD(WIDTH) TYPE(*CHAR) LEN(5) +
       PROMPT('Package Width')

  PARM KWD(LENGTH) TYPE(*CHAR) LEN(5) +
       PROMPT('Package Length')

  PARM KWD(DIMUNTS) TYPE(*CHAR) LEN(2) +
       VALUES(IN) RSTD(*YES) DFT('IN') +
       PROMPT('Package Dimension Units')
