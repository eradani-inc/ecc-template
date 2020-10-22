PRTLBLC:CMD PROMPT('Get USPS Shipping Label')

  PARM KWD(MODE) TYPE(*CHAR) LEN(10) RSTD(*YES) +
       VALUES(*SNDRCV *RCVONLY) DFT('*SNDRCV') +
       PROMPT('Run mode')

  PARM KWD(WAITTM) TYPE(*DEC) LEN(5 0) DFT(5) +
       PROMPT('Wait time')

  PARM KWD(REQKEY) TYPE(*CHAR) LEN(6) DFT('0     ') +
       PROMPT('Request key')

  PARM KWD(IN_TO_NM) TYPE(*CHAR) LEN(16) +
       PROMPT('Ship To Name')

  PARM KWD(IN_TO_ADR) TYPE(*CHAR) LEN(20) +
       PROMPT('Ship To Address')

  PARM KWD(IN_TO_CTY) TYPE(*CHAR) LEN(10) +
       PROMPT('Ship To City')

  PARM KWD(IN_TO_STT) TYPE(*CHAR) LEN(2) +
       PROMPT('Ship To State')

  PARM KWD(IN_TO_ZIP) TYPE(*CHAR) LEN(5) +
       PROMPT('Ship To Zip')

  PARM KWD(IN_TO_CTR) TYPE(*CHAR) LEN(3) +
       PROMPT('Ship To Country')

  PARM KWD(IN_WGT) TYPE(*CHAR) LEN(5) +
       PROMPT('Package Weight')

  PARM KWD(IN_WGT_U) TYPE(*CHAR) LEN(2) +
       VALUES(OZ) RSTD(*YES) DFT('OZ') +
       PROMPT('Package Weight Units')

  PARM KWD(IN_DIM_H) TYPE(*CHAR) LEN(5) +
       PROMPT('Package Height')

  PARM KWD(IN_DIM_W) TYPE(*CHAR) LEN(5) +
       PROMPT('Package Width')

  PARM KWD(IN_DIM_L) TYPE(*CHAR) LEN(5) +
       PROMPT('Package Length')

  PARM KWD(IN_DIM_U) TYPE(*CHAR) LEN(2) +
       VALUES(IN) RSTD(*YES) DFT('IN') +
       PROMPT('Package Dimension Units')
