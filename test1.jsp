�ο� 
https://docs.docker.com/install/linux/docker-ce/centos/
һ �� ж��
  sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
�� ����
1 				  
  sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
2 sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
3 ע�� Optional�ɲ�ִ��
�� ��װs
$ sudo yum install docker-ce

Ȼ������ sudo systemctl start docker
$docker version  �鿴�汾
-------------
ip netns list  �鿴 networknamespace
ip netns delete test1 ɾ��test1
ip netns add test1 ����test1
ip netns exec test1 ip a  ��test1����ִ��ip a����
ip link 
-------��������namespace--------����һ������Ҫ����һ��������network namespace
����һ�� Veth pair��Ȼ��ֱ����namespace test1 ��namespace test2����
$ip link add veth-test1 type veth peer name veth-test2  ���һ��link
$ip link �ῴ������һ�Խӿ�
$ip link set veth-test1 netns test1
$ip netns exec test1 ip link �����������һ���˿�veth-test1
ͬ��test2
$ip netns exec test1 ip addr add 192.168.1.1/24 dev veth-test1 ����ip
$ip netns exec test2 ip addr add 192.168.1.2/24 dev veth-test1 ����ip
$ip netns exec test1 ip link set dev veth-test1 up �����˿ڣ�ͬ������veth-test2
$ip netns exec test1 ip a �Ѿ���ip��
$ip netns exec test2 ping 192.168.1.1  ����ͨ�ˣ�ͬ��test1��ping 192.168.1.2
-------------ÿ����һ�������ͻᴴ��һ��veth ��docker0ͨѶ������->docker0->NAT->eth0 ��������
$docker network ls �鿴docker����Щ����
$docker network inspect [networkid] �����һ��Containers ���Կ������������Ǹ�����������bridge

$yum install bridge-utils
$brctl show  �鿴bridge
$docker network create -d bridge my-bridge ������һ������
$docker network ls
$brctl show
$docker run -d --name my-bridge busybox ָ��bridge
$docker run --name web -d -p 80:80 nginx web���������80�˿�ӳ�䵽linux 80�˿���
--------docker-compose.yml�������-----
Servicesһ��service����һ��container����������image�����ģ����ߴӱ��ص�Dockerfile build������image������ 
        Ҳ������ȡ���˴����õģ�service����������docker run������ָ��network��Volume������
Networks
Volume
------docker compose��װ-------https://docs.docker.com/compose/install/
$curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$chmod +x /usr/local/bin/docker-compose
$docker-compose --version
$docker-compose up  Ĭ���ҵ�ǰĿ¼��docker-compose.yml�ļ� ��ִ̨��$docker-compose up     
$docker-compose -f docker-compose.yml up ͬ��
$docker-compose up --scale web=3 -d ��web���service����3��
$docker ps  �鿴��������
$docker-compose ps ��ӡ��ǰcompose����Щservice
$docler-compse stop ֹͣ�����down��ֹͣ��ɾ��
------k8s-------
$vi rc_nginx.yml  --����apiVersion: v1 kind��ReplicationController
$kubectl create -f rc_nginx.yml 
$kubectl get rc �鿴 3���Ѿ�ready
$kubectl get pods �ɿ���3��
$kubectl scale rc nginx --replicas=2 ������2
$kubectl get pods -o wide �鿴�Ƚ���ϸ
$kubectl delete -f pod_nginx.yml ִ�к�pod��������ʧ
$kubectl get pods 
$kubetl scale rc nginx --replicas=2

$vi rs_nginx.yml  --����apiVersion: apps/v1 kind��ReplicaSet
$kubectl create -f rs_nginx.yml  ����
$kubectl get rs
$kubectl scale rs nginx --replicas=2 

$vi rs_nginx.yml  --����apiVersion: apps/v1 kind��Deployment
$kubectl create -f deployment_nginx.yml  ����
$kubectl get deployment 
$kubectl get rs �����治һ��
$kubectl get deployment -o wide 
$kubectl set image deployment nginx-deployment nginx=nginx:1.13 ����image
$kubectl rollout history deployment nginx-deployment �鿴��ʷ

------���-------
��Ⱥ��� Heapster + grafana + influxDB
��Ⱥ��� prometheus
*************������*************************
https://hub.docker.com/_/centos?tab=tags
$docker pull openjdk:8 ����8-jdk  8u181    ����centos:7
$docker run -it --entrypoint bash openjdk:8

$docker build -t user-service:latest .   #���ݵ�ǰĿ¼�µ�dockerfile����image
$docker run -it user-service:latest ����
-------------
�˺� stevenliu2020  xiangcheng100 ���� qq https://hub.docker.com/
$docker login Ȼ�������û���������

-----------------------------------------
docker run -d -p 5000:5000 --restart always --name registry registry:2
docker run -d -p 5000:5000 registry:2 Ҳ����
docker ps

docker build -t 192.168.220.95:5000/hello-world
docker image ls  
$vi /etc/docker/daemon.json ������ͬ��������һ��json
$more /etc/docker/daemon.json  {"insecure-registries":["192.168.220.95:5000"]}
$service docker restart
docker push 192.168.220.95:5000/hello-world:1.0
�鿴�Ƿ�push�ɹ� 192.168.220.95:5000/v2/_catalog
-----------��������ʹ��-------------------
������ https://github.com/goharbor/harbor/releases
Harbor offline installer
*************************************************
-------------
-------------
-------------
-------------

