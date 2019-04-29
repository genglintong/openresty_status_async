#!/bin/bash
# 压力测试

# 计算随机数
function rand(){
        min=$1
        max=$(($2-$min+1))
        num=$(($RANDOM+1000000000))
        echo $(($num%$max+$min))
}

tim=$(date "+%Y-%m-%d %H:%M:%S")
rnd=$(rand 5000 10000)
rndN=$[ $rnd * 10 ]

echo -e "\n\n开始时间:"$tim"\t并发次数: "$rnd"\t总调用次数: "$rndN"\n" >> ../stressTest/abtest.data
ab -n$rndN -c$rnd -r http://ip/api/123 | grep -v 'ApacheBench' | grep -v 'Copyright' | grep -v 'Licensed' >> ../stressTest/abtest.data