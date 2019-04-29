#!/bin/bash

# 按天切割日志

#日志目录
LOG_PATH=../logs

#昨天日期
#YESTERDAY=$(date "+%Y-%m-%d_%H:%M:%S")
YESTERDAY=$(date "+%Y-%m-%d" -d "-1day")

#分割日志
for a in ` find  ${LOG_PATH} -name "*access.log" `;do cp $a $a-${YESTERDAY};echo ""  >$a;done
for e in ` find  ${LOG_PATH} -name "*error.log" `;do cp $e $e-${YESTERDAY};echo ""  >$e;done