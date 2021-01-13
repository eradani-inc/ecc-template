#!/QOpenSys/pkgs/bin/bash
NODE_HOME=/QOpenSys/pkgs/bin
ECNCT_HOME=/QOpenSys/opt/eradani/ecc-template

NODE_ENV=development
export NODE_ENV

PATH=$NODE_HOME:$PATH

cd $ECNCT_HOME
node src/app.js