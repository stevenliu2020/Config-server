参考 
https://docs.docker.com/install/linux/docker-ce/centos/
一 先 卸载
  sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
二 步骤
1 				  
  sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
2 sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
3 注意 Optional可不执行
三 安装s
$ sudo yum install docker-ce

然后启动 sudo systemctl start docker
$docker version  查看版本
-------------
ip netns list  查看 networknamespace
ip netns delete test1 删除test1
ip netns add test1 新增test1
ip netns exec test1 ip a  在test1里面执行ip a命令
ip link 
-------连接两个namespace--------创建一个容器要创建一个独立的network namespace
创建一对 Veth pair，然后分别放在namespace test1 和namespace test2里面
$ip link add veth-test1 type veth peer name veth-test2  添加一对link
$ip link 会看到多了一对接口
$ip link set veth-test1 netns test1
$ip netns exec test1 ip link 发现里面多了一个端口veth-test1
同理test2
$ip netns exec test1 ip addr add 192.168.1.1/24 dev veth-test1 分配ip
$ip netns exec test2 ip addr add 192.168.1.2/24 dev veth-test1 分配ip
$ip netns exec test1 ip link set dev veth-test1 up 启动端口，同理启动veth-test2
$ip netns exec test1 ip a 已经有ip了
$ip netns exec test2 ping 192.168.1.1  可以通了，同理test1可ping 192.168.1.2
-------------每创建一个容器就会创建一对veth 与docker0通讯，容器->docker0->NAT->eth0 访问外网
$docker network ls 查看docker有哪些网络
$docker network inspect [networkid] 输出有一块Containers 可以看到容器连到那个网络这里是bridge

$yum install bridge-utils
$brctl show  查看bridge
$docker network create -d bridge my-bridge 创建另一个网络
$docker network ls
$brctl show
$docker run -d --name my-bridge busybox 指定bridge
$docker run --name web -d -p 80:80 nginx web这个容器的80端口映射到linux 80端口上
--------docker-compose.yml三大概念-----
Services一个service代表一个container，容器来着image创建的，或者从本地的Dockerfile build出来的image来创建 
        也可以拉取别人创建好的，service的启动类似docker run，可以指定network和Volume的引用
Networks
Volume
------docker compose安装-------https://docs.docker.com/compose/install/
$curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$chmod +x /usr/local/bin/docker-compose
$docker-compose --version
$docker-compose up  默认找当前目录下docker-compose.yml文件 后台执行$docker-compose up     
$docker-compose -f docker-compose.yml up 同上
$docker-compose up --scale web=3 -d 把web这个service扩容3个
$docker ps  查看多了容器
$docker-compose ps 打印当前compose有哪些service
$docler-compse stop 停止，如果down是停止并删除
------k8s-------
$vi rc_nginx.yml  --里面apiVersion: v1 kind：ReplicationController
$kubectl create -f rc_nginx.yml 
$kubectl get rc 查看 3个已经ready
$kubectl get pods 可看到3个
$kubectl scale rc nginx --replicas=2 扩容至2
$kubectl get pods -o wide 查看比较详细
$kubectl delete -f pod_nginx.yml 执行后pod会慢慢消失
$kubectl get pods 
$kubetl scale rc nginx --replicas=2

$vi rs_nginx.yml  --里面apiVersion: apps/v1 kind：ReplicaSet
$kubectl create -f rs_nginx.yml  创建
$kubectl get rs
$kubectl scale rs nginx --replicas=2 

$vi rs_nginx.yml  --里面apiVersion: apps/v1 kind：Deployment
$kubectl create -f deployment_nginx.yml  创建
$kubectl get deployment 
$kubectl get rs 与上面不一样
$kubectl get deployment -o wide 
$kubectl set image deployment nginx-deployment nginx=nginx:1.13 升级image
$kubectl rollout history deployment nginx-deployment 查看历史

------监控-------
集群监控 Heapster + grafana + influxDB
集群监控 prometheus
*************【镜像】*************************
https://hub.docker.com/_/centos?tab=tags
$docker pull openjdk:8 或者8-jdk  8u181    或者centos:7
$docker run -it --entrypoint bash openjdk:8

$docker build -t user-service:latest .   #根据当前目录下的dockerfile构建image
$docker run -it user-service:latest 启动
-------------
账号 stevenliu2020  xiangcheng100 邮箱 qq https://hub.docker.com/
$docker login 然后输入用户名和密码

-----------------------------------------
docker run -d -p 5000:5000 --restart always --name registry registry:2
docker run -d -p 5000:5000 registry:2 也可以
docker ps

docker build -t 192.168.220.95:5000/hello-world
docker image ls  
$vi /etc/docker/daemon.json 与下面同就是增加一个json
$more /etc/docker/daemon.json  {"insecure-registries":["192.168.220.95:5000"]}
$service docker restart
docker push 192.168.220.95:5000/hello-world:1.0
查看是否push成功 192.168.220.95:5000/v2/_catalog
-----------生产环境使用-------------------
先下载 https://github.com/goharbor/harbor/releases
Harbor offline installer
*************************************************
-------------
-------------
-------------
-------------

