PRTCDEC:CMD PROMPT('Generate Barcode Label')

  PARM KWD(MODE) TYPE(*CHAR) LEN(10) RSTD(*YES) +
       VALUES(*SNDRCV *RCVONLY) DFT('*SNDRCV') +
       PROMPT('Run mode')

  PARM KWD(WAITTM) TYPE(*DEC) LEN(5 0) DFT(5) +
       PROMPT('Wait time')

  PARM KWD(REQKEY) TYPE(*CHAR) LEN(6) DFT('0     ') +
       PROMPT('Request key')

  PARM KWD(CUST) TYPE(*CHAR) LEN(16) +
       PROMPT('Customer')

  PARM KWD(ADDR) TYPE(*CHAR) LEN(20) +
       PROMPT('Address')

  PARM KWD(CITY) TYPE(*CHAR) LEN(10) +
       PROMPT('City')

  PARM KWD(STATE) TYPE(*CHAR) LEN(2) +
       PROMPT('State')

  PARM KWD(ZIP) TYPE(*CHAR) LEN(5) +
       PROMPT('Zip')

  PARM KWD(PRD) TYPE(*CHAR) LEN(12) +
       PROMPT('Product')

  PARM KWD(QTY) TYPE(*CHAR) LEN(3) +
       PROMPT('Quantity')

  PARM KWD(CODE) TYPE(*CHAR) LEN(12) +
       PROMPT('Code')
