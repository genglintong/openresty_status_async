## OPENRESTY-高性能WEB
> 用于同步消息等

### 搭建
openresty openresty/1.13.6.2

安装pomelo插件<br>
`opm --install-dir=./resty_modules get anjia0532/lua-resty-redis-util`

项目启动/重启/结束<br>
```
# 启动
openresty -p openrestyDir -c openrestyDir/conf/nginx.conf

# 重启
openresty -p openrestyDir -c openrestyDir/conf/nginx.conf -s reload

# 结束
openresty -p openrestyDir -c openrestyDir/conf/nginx.conf -s quit
```

日志crontab <br>
`0 0 * * * cd openrestyDir/script && sh +x spiltLog.sh >>/dev/null 2>&1`

### 性能测试
[博客](https://www.jianshu.com/p/19721edbc6be)

#### siege 压力测试
[安装](https://centos.pkgs.org/6/repoforge-x86_64/siege-2.72-1.el6.rf.x86_64.rpm.html)
```
wget http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el6/en/x86_64/rpmforge/RPMS/siege-2.72-1.el6.rf.x86_64.rpm
sudo rpm -Uvh siege-2.72-1.el6.rf.x86_64.rpm
sudo yum install siege

# 压力测试
# -r 测试轮数
# -c 并发数  siege超过1000会报错
siege http://test.com/api/123 -r 20 -c 2000
```
并发超过1000会出错

#### ab 压力测试
```
# 只安装 ab工具包
yum -y install httpd-tools

# 测试是否安装成功
ab -V

# 1W 并发 10W 请求
ab -n100000 -c10000 http://test.com/api/123
ab -r # 默认跳过报错
```

- helloworld接口

| 总次数 | 并发数 | 失败数 | 成功率 | 最大时长(ms) | 大概率时长(90%) |
| ---- | ---- | ---- | ---- | --- | --- |
|100000|100|0|100%| 17 | 5 | 
|100000|1000|0|100%| 3043 | 62 |
|100000|5000|0|100%| 3342 | 419 |
|100000|10000|0|100%| 4180 | 1490 |
|100000|20000|0|100%| 5118 | 1650 |

- 读redis 接口

| 总次数 | 并发数 | 失败数 | 成功率 | 最大时长(ms) | 大概率时长(90%) |
| ---- | ---- | ---- | ---- | --- | --- |
|100000|100|0|100%| 29 | 12 | 
|100000|1000|0|100%| 8769 | 26 |
|100000|5000|0|100%| 15779 | 1577 |
|100000|10000|99|100%| 9231 | 3057 |
|100000|10000|105|100%| 8803 | 2416 |
|100000|10000|0|100%| 8388| 2343 |
|1000000|10000|1|100%| 17535| 2723 |
|100000|20000|0|100%| 21464 | 6463 |
|100000|20000|0|100%| 14434 | 6916 |
|1000000|20000|1|100%| 10494 | 8520 |

#### 优化
- worker_connections被打满<br>
[NGINX最大并发max_clients计算](http://blog.51cto.com/liuqunying/1420556)<br>
NGINX作为http服务器时:<br>
max_clients = worker_process * worker_conections<br>
NGINX作为反向代理时:<br>
max_clients = worker_process * worker_conections / 4<br>
由以上计算得，原来最大clients = 2 * 10240 = 20480<br>
在测试并发2W以上,会报连接数被打满。修改worker_connnections为20480,解决此问题。<br>

- lua tcp socket connect timed out<br>
    redis 连接超时<br>
    - 修改方案1-将超时时间设置为20s(原来2s)<br>
    结果: 超时操作明显减少<br>
    - 修改方案2-[使用连接池](https://www.the5fire.com/golang+redis-vs-nginx+lua+redis.html)<br>
    两W并发 100W请求下 连接池对比<br>
    
    |连接池数|超时数|
    | ---- | --- |
    |100|4434|
    |100|3777|
    |1000|4295|
    |1000|2579|
    |10000|2252|
    |10000|5106|
    发现,加大连接池数并没有减少超时，因此采用加大超时时间+设置100连接池(减少资源消耗)。<br>
2W并发 100W请求超时数为0.<br>
- 优化后结果

  | 总次数 | 并发数 | 失败数 | 成功率 | 最大时长(ms) | 大概率时长  (90%) |
  | ---- | ---- | ---- | ---- | --- | --- |
  |165270|16527|0|100%|9051|4899|
  |104490|10449|0|100%|16109|2515|
  |90590|9059|0|100%|4759|2164|
  |132460|13246|0|100%|8670|3210|
