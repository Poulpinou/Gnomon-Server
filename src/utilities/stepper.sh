#!/bin/sh

STEP=0;
STEP_COUNT=0

incrementStep(){
    STEP=$((++STEP))
}

resetStep(){
    STEP=0
}

newStep(){
    local message=$1
    incrementStep
    echo -e "${s_bold}Step $STEP : ${s_normal} $message"
}