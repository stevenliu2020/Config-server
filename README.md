# Config-server
apollo 开发流程
1 增加yml配置文件 3行
2 写一个配置类，apollo的key定义get和set方法，这里是ApplicationConfigs
3 定义一个@Component 配置apollo listener 这里是ApplicationConfigRefresher
4 使用是直接@Autowired 2 直接使用

-----------------------------------
$yum -y install gcc
$cd /u01/redis
$tar xzf redis-5.0.3.tar.gz
$mkdir 7001 7002 7003 7004 7005 7006
$cd redis-5.0.3
$make 
$make install 没执行这个
$cp redis.conf /u01/redis/7001/  
$ vi /u01/redis/7001/redis.conf    #下面设置完后，copy另外5个目录
$cp /u01/redis/7001/redis.conf /u01/redis/7002/redis.conf
------------ 
port 7001  #端口    ********
bind 192.168.220.94  #需要
#dir /usr/local/redis-cluster/3680 #指定文件存放路径 先不用
cluster-enabled yes #启用集群模式  放开
cluster-config-file nodes-7001.conf   #集群启动时创建 放开 *****按端口号
cluster-node-timeout 5000 #超时时间  放开   注意vi下查找 /cluster-config  回车即可
appendonly yes
daemonize yes #后台运行
protected-mode no #非保护模式
pidfile  /u01/redis/7001/redis.pid  #***********
------------
启动6个 
/u01/redis/
$/u01/redis/redis-5.0.3/src/redis-server  /u01/redis/7001/redis.conf

启动集群
$/u01/redis/redis-5.0.3/src/redis-cli --cluster create 192.168.220.94:7001 192.168.220.94:7002 192.168.220.94:7003 192.168.220.94:7004 192.168.220.94:7005 192.168.220.94:7006 --cluster-replicas 1

修改
$cd redis-5.0.3\utils\create-cluster
$vi create-cluster
port 为 7000 / NODES=6
修改后
$create-cluster stop
$create-cluster start
----------集群启动脚本----------------------
#!/bin/sh
/u01/redis/redis-5.0.3/src/redis-server  /u01/redis/7001/redis.conf
/u01/redis/redis-5.0.3/src/redis-server  /u01/redis/7002/redis.conf
/u01/redis/redis-5.0.3/src/redis-server  /u01/redis/7003/redis.conf
/u01/redis/redis-5.0.3/src/redis-server  /u01/redis/7004/redis.conf
/u01/redis/redis-5.0.3/src/redis-server  /u01/redis/7005/redis.conf
/u01/redis/redis-5.0.3/src/redis-server  /u01/redis/7006/redis.conf

/u01/redis/redis-5.0.3/src/redis-cli --cluster create 192.168.220.94:7001 192.168.220.94:7002 192.168.220.94:7003 192.168.220.94:7004 192.168.220.94:7005 192.168.220.94:7006 --cluster-replicas 1
--------------------------------------------
$cd /u01/redis/redis-5.0.3/src/
$./redis-cli -c -h 192.168.220.94 -p 7001  $set name aaa $get name 测试
$cluster info
$cluster nodes




