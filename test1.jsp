
$java -version 查看版本
$vi /etc/profile  里面  /u01/jdk
$rpm -qa|grep jdk   查询系统已安装jdk 可以不用
$su root 切换到管理员权限  123qweASD
$uname -a  查看内核
$cat /proc/version
$more /etc/redhat-release

$cd u01/sofeware
$tar -zxvf jdk-8u201-linux-x64.tar.gz -C /u01/  目录必须存在
$cd ..
$mv jdk1.8.0_201 jdk64-1.82 【改名】 
  
添加java ---------------------------#
--$JAVA_HOME=/u01/jdk64-1.82
--$PATH=$JAVA_HOME/bin:$PATH
--$CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar 
$:qt! 保存并退出
source /etc/profile
上面是我以前的，下面是新安装的也可以，还是采用上面的
$vi etc/proflie.d/java.sh 添加
export JAVA_HOME=/u01/jdk64-1.8
export CLASSPATH=$JAVA_HOME/lib
export PATH=$JAVA_HOME/bin:$PATH
$chmod 755 /etc/profile.d/java.sh  分配权限
$source /etc/profile.d/java.sh  立即生效   没发现原来放什么地方了
----------------------------------
echo $JAVA_HOME
echo $PATH
echo $CLASSPATH
----------1关闭防火墙-----------------
systemctl disable firewalld.service
systemctl stop firewalld.service
$vi /etc/selinux/config  SELINUX="" 为 disabled 这个修改好的
--$yum install iptables-services 
--$systemctl stop iptables && systemctl disable iptables
----------2 -----------------
1 sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
2 	sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2	
3 sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo 把这条替换成
$yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

$yum list docker-ce --showduplicates | sort -r
4 sudo yum install docker-ce	
  yum -y install docker-ce-18.06.1.ce-3.el7 这里无法使用，用下面的离线安装
安装前更新yum 方法是
$more /etc/yum.repos.d/  查看文件
$cd /etc/yum.repos.d/
$wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 下载文件 这里不能下载
$yum clean all 
$yum makecache fast   #注意这里把rhel.repo移除了
			
下面离线安装 rpm 下载地址 http://rpm.pbone.net/index.php3  https://cbs.centos.org/koji/buildinfo?buildID=10408
转到soft文件夹
---$yum install docker-ce-18.06.1.ce-3.el7.x86_64.rpm	不能执行
$rpm -ivh container-selinux-2.9-4.el7.noarch.rpm
$rpm -ivh libseccomp-2.3.0-1.el7.x86_64.rpm  
$yum update libseccomp-2.3.0-1.el7.x86_64.rpm  --执行上面一条必须执行update

$yum install -y ./docker-ce-18.06.1.ce-3.el7.x86_64.rpm
$systemctl start docker 启动
$systemctl enable docker 开机启动
$ps -ef |grep docker
$docker version	
$docker run hello-world 测试  这里不能上网	
$service stop docker

$
************K8S*************************
192.168.220.93 ngds-node1  kubelet、docker、kube_proxy
192.168.220.94 ngds-node2  kubelet、docker、kube_proxy
192.168.220.95 ngds-master etcd、kube-apiserver、kube-controller-manager、kube-scheduler  

$vi /etc/hosts
192.168.220.93 ngds-node1  hosts
192.168.220.94 ngds-node2
192.168.220.95 ngds-master NGDS-22095
---------master安装------------------
-----1 cfssl安装--------
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
$mkdir /u01/k8s/
$chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64
$mv cfssl_linux-amd64 /usr/local/bin/cfssl
$mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
$mv cfssl-certinfo_linux-amd64 /usr/bin/cfssl-certinfo
创建证书  #rm -rf /u01/k8s 
--$mkdir /u01/k8s/etcd/{bin,cfg,ssl} -p
$mkdir -p /u01/k8s/kubernetes/{ssl,bin,cfg} -p 
$mkdir -p /u01/k8s/etcd/ssl  用这个就可以了
$cd /u01/k8s/etcd/ssl/ 
ca配置---ca-config.json
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
ca证书---ca-csr.json
{
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "ShangHai",
            "ST": "ShangHai",
			"O": "k8s",
            "OU": "System"
        }
    ]
}
etcd server证书------etcd-csr.json
{
    "CN": "kubernetes",
    "hosts": [
	"127.0.0.1",    --这个好像不需要
    "192.168.220.95",
    "192.168.220.93",
    "192.168.220.94"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "ShangHai",
            "ST": "ShangHai",
			"O": "k8s",
            "OU": "System"
        }
    ]
}

$cd /u01/k8s/kubernetes/cfg  3个文件拷到这个目录 
----生成etcd ca证书和私钥 初始化ca 当前目录3个文件 
$cfssl gencert -initca ca-csr.json | cfssljson -bare ca
$cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd etcd-csr.json | cfssljson -bare etcd
执行完成后会把 *.pem的4个文件分发到etcd机器上
$cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
制作apiserver证书
$cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
制作kube-proxy证书
$cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy

注意 /u01/k8s/kubernetes/ssl/ ca*.pem  我认为4个文件都拷这个地方就可以了
     /u01/k8s/etcd/ssl/       etcd*.pem
#rm -rf /u01/k8s 
-----2etcd 主节点------
1 安装到/usr/bin/ 
$tar  xvf etcd-v3.3.10-linux-amd64.tar.gz
$cd etcd-v3.3.10-linux-amd64
$cp etcd etcdctl /usr/bin/ 
$mkdir /var/lib/etcd
$mkdir /etc/etcd
$mkdir -p /var/lib/etcd/etcd
$mkdir -p /u01/k8s/etcd/ssl
$cd /usr/bin/
$chmod 755 etcd
--新建两个文件
2 
$vi /etc/etcd/etcd.conf
3 设置服务文件etcd.service

$vi /usr/lib/systemd/system/etcd.service  
-----------------------
[Unit]
Description=etcd server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=-/etc/etcd/etcd.conf
ExecStart=/bin/bash -c "GOMAXPROCS=$(nproc) /usr/bin/etcd --name ngdsetcd1 --data-dir=/var/lib/etcd/etcd --listen-peer-urls https://192.168.220.95:2380 --listen-client-urls https://192.168.220.95:2379,http://127.0.0.1:2379 --advertise-client-urls https://192.168.220.95:2379 --initial-advertise-peer-urls https://192.168.220.95:2380 --initial-cluster-token etcd-cluster --initial-cluster ngdsetcd1=https://192.168.220.95:2380,ngdsetcd2=https://192.168.220.93:2380,ngdsetcd3=https://192.168.220.94:2380 --initial-cluster-state new --cert-file /u01/k8s/etcd/ssl/etcd.pem --key-file /u01/k8s/etcd/ssl/etcd-key.pem --trusted-ca-file /u01/k8s/etcd/ssl/ca.pem --peer-cert-file /u01/k8s/etcd/ssl/etcd.pem --peer-key-file /u01/k8s/etcd/ssl/etcd-key.pem --peer-trusted-ca-file /u01/k8s/etcd/ssl/ca.pem --client-cert-auth=true --peer-client-cert-auth=true"

Restart=on-failure
RestartSec=5
LimitNOFILE=65536


[Install]
WantedBy=multi-user.target
--------------------

4 设置开机启动 
systemctl daemon-reload
systemctl enable etcd    $systemctl disable etcd
systemctl start etcd    systemctl restart etcd  systemctl stop etcd
systemctl status etcd 查看状态
5 检查etcd是否安装成功
$etcdctl cluster-health  $journalctl -xe
验证服务 
$cd /usr/bin 好像不需要
etcdctl --ca-file=/u01/k8s/etcd/ssl/ca.pem --cert-file=/u01/k8s/etcd/ssl/etcd.pem --key-file=/u01/k8s/etcd/ssl/etcd-key.pem --endpoints=https://192.168.220.93:2379,https://192.168.220.94:2379,https://192.168.220.95:2379 cluster-health
查看主节点 
etcdctl --ca-file=/u01/k8s/etcd/ssl/ca.pem --cert-file=/u01/k8s/etcd/ssl/etcd.pem --key-file=/u01/k8s/etcd/ssl/etcd-key.pem --endpoints=https://192.168.220.93:2379,https://192.168.220.94:2379,https://192.168.220.95:2379 member list

systemctl start etcd
systemctl start flannel
systemctl start docker
************kubernetes server******************
----95 节点 kube-apiserver、kube-controller-manager、kube-scheduler 
---1---
$cd /u01/software
$tar xvf kubernetes-server-linux-amd64.tar.gz
$cd kubernetes/server/bin/
$cp kube-scheduler kube-apiserver kube-controller-manager kubectl /u01/k8s/kubernetes/bin/
$cd /u01/k8s/kubernetes/bin/
$head -c 16 /dev/urandom | od -An -t x | tr -d ' ' 
生成 4d821432156878176e5dd1397a63b842
$vi /u01/k8s/kubernetes/cfg/token.csv 内容
4d821432156878176e5dd1397a63b842,kubelet-bootstrap,10001,"system:kubelet-bootstrap"

$vi /u01/k8s/kubernetes/cfg/kube-apiserver--------内容如下换成一行
KUBE_APISERVER_OPTS="--logtostderr=true 
--v=4 
--etcd-servers=https://192.168.220.93:2379,https://192.168.220.94:2379,https://192.168.220.95:2379 
--bind-address=192.168.220.95 
--secure-port=6443 
--advertise-address=192.168.220.95 
--allow-privileged=true 
--service-cluster-ip-range=10.254.0.0/16 
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction
--authorization-mode=RBAC,Node 
--enable-bootstrap-token-auth 
--token-auth-file=/u01/k8s/kubernetes/cfg/token.csv 
--service-node-port-range=30000-50000 
--tls-cert-file=/u01/k8s/kubernetes/ssl/kubernetes.pem 
--tls-private-key-file=/u01/k8s/kubernetes/ssl/kubernetes-key.pem 
--client-ca-file=/u01/k8s/kubernetes/ssl/ca.pem 
--service-account-key-file=/u01/k8s/kubernetes/ssl/ca-key.pem 
--etcd-cafile=/u01/k8s/etcd/ssl/ca.pem 
--etcd-certfile=/u01/k8s/etcd/ssl/etcd.pem 
--etcd-keyfile=/u01/k8s/etcd/ssl/etcd-key.pem"
-----------------------------------
$vi /usr/lib/systemd/system/kube-apiserver.service ----
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
 
[Service]
EnvironmentFile=-/u01/k8s/kubernetes/cfg/kube-apiserver
ExecStart=/u01/k8s/kubernetes/bin/kube-apiserver $KUBE_APISERVER_OPTS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
---------启动服务-----------
$systemctl daemon-reload
$systemctl enable kube-apiserver
$systemctl start kube-apiserver 

$systemctl status kube-apiserver  显示active  
$ps -ef |grep kube-apiserver   
$netstat -tulpn |grep kube-apiserve
---------------2部署kube-scheduler组件---------------------------
$vi /u01/k8s/kubernetes/cfg/kube-scheduler  内容--
KUBE_SCHEDULER_OPTS="--logtostderr=true --v=4 --master=127.0.0.1:8080 --leader-elect"

$vi /usr/lib/systemd/system/kube-scheduler.service ---------
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
 
[Service]
EnvironmentFile=-/u01/k8s/kubernetes/cfg/kube-scheduler
ExecStart=/u01/k8s/kubernetes/bin/kube-scheduler $KUBE_SCHEDULER_OPTS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
-------------------------------------
启动服务 
$systemctl daemon-reload
$systemctl enable kube-scheduler.service 
$systemctl start kube-scheduler.service
$systemctl status kube-scheduler.service 显示active
-------------3部署kube-controller-manager组件---------------
$vi /u01/k8s/kubernetes/cfg/kube-controller-manager  ---内容如下注意成一行---
KUBE_CONTROLLER_MANAGER_OPTS="--logtostderr=true 
--v=4 
--master=127.0.0.1:8080 
--leader-elect=true 
--address=127.0.0.1 
--service-cluster-ip-range=10.254.0.0/16 
--cluster-name=kubernetes 
--cluster-signing-cert-file=/u01/k8s/kubernetes/ssl/ca.pem 
--cluster-signing-key-file=/u01/k8s/kubernetes/ssl/ca-key.pem 
--root-ca-file=/u01/k8s/kubernetes/ssl/ca.pem 
--service-account-private-key-file=/u01/k8s/kubernetes/ssl/ca-key.pem"
------------------------------------------------------------
$vi /usr/lib/systemd/system/kube-controller-manager.service---内容如下----
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
 
[Service]
EnvironmentFile=-/u01/k8s/kubernetes/cfg/kube-controller-manager
ExecStart=/u01/k8s/kubernetes/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
--------------------------------------------------------
启动 
systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl start kube-controller-manager
systemctl status kube-controller-manager 会显示active
-------------4设置环境变量-------------------------------------------
$vi /etc/profile  增加  PATH=$JAVA_HOME/bin:/u01/k8s/kubernetes/bin:$PATH
$vi source /etc/profile 
查看master服务状态 
$kubectl get cs,nodes
【注意这里提示】The connection to the server localhost:8080 was refused - did you specify the right host or port?
$lsof -i:8080  出现这个错误是配置文件--前面少个空格
$netstat -tunlp |grep 8080  这两个命令是查看端口状态

--------------5master总结------------
systemctl start etcd
systemctl start kube-apiserver
$systemctl start kube-scheduler.service
systemctl start kube-controller-manager

$systemctl status kube-apiserver
$systemctl status kube-scheduler.service
$systemctl status kube-controller-manager
$kubectl get cs,nodes  显示5行数据etcd3行 另外两行
--------------------------------------------------------
************Node 部署 ************
部署在node节点，监听apiserver中service和endpoint的变化，创建路由规则来进行负载均衡
--93 94 kubelet、docker、kube_proxy
说明 kublet运行在每个worker节点,接收 kube-apiserver 发送的请求，管理pod容器，执行交互式命令
1 安装dokcer如上-------------------------------
2 部署kubelet组件------------------------------ 这里把/u01/k8s/kubernetes/bin 加入了PATH不知道能不能去掉
$mkdir -p /u01/k8s/kubernetes/{ssl,bin,cfg} -p 
$cd /u01/software
$tar -xvf kubernetes-node-linux-amd64.tar.gz
$cd kubernetes/node/bin/
$cp kube-proxy kubelet kubectl /u01/k8s/kubernetes/bin/
$cd /u01/k8s/kubernetes/bin/  
#$chmod 755 kubelet  分配权限 不需要
把 master里面kubernetes下面生成的*.pem文件拷贝到/u01/k8s/kubernetes/ssl/
-------------1创建kubeconfig文件----
$ vi /u01/k8s/kubernetes/cfg/environment.sh---------------------------
#!/bin/bash
#创建kubelet bootstrapping kubeconfig 
BOOTSTRAP_TOKEN=4d821432156878176e5dd1397a63b842
KUBE_APISERVER="https://192.168.220.95:6443"
#设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/u01/k8s/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig 
#设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig 
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig 
# 设置默认上下文
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig 
#---------------------- 
# 创建kube-proxy kubeconfig文件 
kubectl config set-cluster kubernetes \
  --certificate-authority=/u01/k8s/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig 
kubectl config set-credentials kube-proxy \
  --client-certificate=/u01/k8s/kubernetes/ssl/kube-proxy.pem \
  --client-key=/u01/k8s/kubernetes/ssl/kube-proxy-key.pem  \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig 
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig 
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
--------------------------------------------------
$cd /u01/k8s/kubernetes/cfg 执行-------------
$sh environment.sh   【注意执行文件不成功，手动执行environment换行版.sh，输出如下】
Cluster "kubernetes" set.
User "kubelet-bootstrap" set.
Context "default" created.
Switched to context "default".
Cluster "kubernetes" set.
User "kube-proxy" set.
Context "default" created.
Switched to context "default".
---------------------------------------------
cfg 下会生成bootstrap.kubeconfig  kube-proxy.kubeconfig 文件
-------------2 创建kubelet参数配置模板文件--------------------------------
$vi /u01/k8s/kubernetes/cfg/kubelet.config   【注意修改ip】
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: 192.168.220.94
port: 10250
readOnlyPort: 10255
cgroupDriver: cgroupfs
clusterDNS: ["10.254.0.10"]
clusterDomain: cluster.local.
failSwapOn: false
authentication:
  anonymous:
    enabled: true
	
-------------3创建kubelet配置文件------------
$vi /u01/k8s/kubernetes/cfg/kubelet 【注意修改ip】 【这里面有个aliyun的pod】 kubelet源文件里面有换行不能用
----------------
KUBELET_OPTS="--logtostderr=true --v=4 --hostname-override=192.168.220.94 --kubeconfig=/u01/k8s/kubernetes/cfg/kubelet.kubeconfig --bootstrap-kubeconfig=/u01/k8s/kubernetes/cfg/bootstrap.kubeconfig --config=/u01/k8s/kubernetes/cfg/kubelet.config --cert-dir=/u01/k8s/kubernetes/ssl --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0"

-------------4创建kubelet systemd文件---------------------------
$vi /usr/lib/systemd/system/kubelet.service------------------
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service
 
[Service]
EnvironmentFile=/u01/k8s/kubernetes/cfg/kubelet
ExecStart=/u01/k8s/kubernetes/bin/kubelet $KUBELET_OPTS
Restart=on-failure
KillMode=process
 
RestartSec=5
[Install]
WantedBy=multi-user.target
-------------5将kubelet-bootstrap用户绑定到系统集群角色 --------------执行一次就可以了
使用95ssl $kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap
注意这个默认连接localhost:8080端口，在master上操作
应该输出 clusterrolebinding.rbac.authorization.k8s.io/kubelet-bootstrap created
--------------6启动服务-------------94
$systemctl daemon-reload 
$systemctl enable kubelet 
$systemctl start kubelet    要提前启动docker
$systemctl status kubelet   active  启动失败 journalctl -xefu kubelet 有次配置未成功原因kubelet.kubeconfig需要删掉
--------------7Master接受Kubelet CSR请求可以手动，也可以自动approve CSR，下面手动方式-------------
使用95ssl $kubectl get csr  第一列name替换下面的
          $kubectl certificate approve 【node-csr-ij3py9j-yi-eoa8sOHMDs7VeTQtMv0N3Efj3ByZLMdc】
          $kubectl get csr 再次查看 变成Approve Issued
3部署kube-proxy组件---------------------
------------1创建 kube-proxy 配置文件---------------
$vi /u01/k8s/kubernetes/cfg/kube-proxy  【注意修改ip】-----
KUBE_PROXY_OPTS="--logtostderr=true --v=4 --hostname-override=192.168.220.94 --cluster-cidr=10.254.0.0/16 --kubeconfig=/u01/k8s/kubernetes/cfg/kube-proxy.kubeconfig"

------------2创建kube-proxy systemd---------------
$vi /usr/lib/systemd/system/kube-proxy.service -----
[Unit]
Description=Kubernetes Proxy
After=network.target
 
[Service]
EnvironmentFile=-/u01/k8s/kubernetes/cfg/kube-proxy
ExecStart=/u01/k8s/kubernetes/bin/kube-proxy $KUBE_PROXY_OPTS
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
------------3启动---------------
要检查 $systemctl status kubelet   
 systemctl daemon-reload 
 systemctl enable kube-proxy 
 systemctl start kube-proxy
 systemctl status  kube-proxy 查看状态
95cfg $kubectl get nodes  #查看集群状态 会列出192.168.220.94 
注意kubelet lube-proxy配置错误，比如监听ip或者hostname导致node not found 删除kubelet-client证书,重启kubelet服务，重新认证csr
-----------【把另外一个node部署成功再继续】------------------
-----------------------------
------------Flanneld网络部署---------------
-------1注册etcd网段--------------------
$cd /usr/bin 好像不需要  注意下面endpoint增加了引号有什么用，文件/u01/k8s/network/config 会自动创建吗
$etcdctl --ca-file=/u01/k8s/etcd/ssl/ca.pem --cert-file=/u01/k8s/etcd/ssl/etcd.pem --key-file=/u01/k8s/etcd/ssl/etcd-key.pem --endpoints=https://192.168.220.93:2379,https://192.168.220.94:2379,https://192.168.220.95:2379 set /u01/k8s/network/config  '{ "Network": "10.254.0.0/16", "Backend": {"Type": "vxlan"}}'
-------2安装flannel--------------------
$mkdir /u01/k8s/network
$cd /u01/software
$tar -xvf flannel-v0.10.0-linux-amd64.tar.gz
$cd kubernetes/server/bin/  这个好像解压到本目录了
$mv flanneld mk-docker-opts.sh /u01/k8s/kubernetes/bin/
配置flanneld文件

$vi /u01/k8s/kubernetes/cfg/flanneld  内容如下-----------
FLANNEL_OPTIONS="--etcd-endpoints=https://192.168.220.93:2379,https://192.168.220.94:2379,https://192.168.220.95:2379  -etcd-cafile=/u01/k8s/etcd/ssl/ca.pem -etcd-certfile=/u01/k8s/etcd/ssl/etcd.pem -etcd-keyfile=/u01/k8s/etcd/ssl/etcd-key.pem -etcd-prefix=/u01/k8s/network"

-------------------------------
创建 flannel服务文件
$vi /usr/lib/systemd/system/flanneld.service  内容如下-----------
[Unit]
Description=Flanneld overlay address etcd agent
After=network-online.target network.target
Before=docker.service
 
[Service]
Type=notify
EnvironmentFile=/u01/k8s/kubernetes/cfg/flanneld
ExecStart=/u01/k8s/kubernetes/bin/flanneld --ip-masq $FLANNEL_OPTIONS
ExecStartPost=/u01/k8s/kubernetes/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/subnet.env
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
-----------------------------
配置Docker启动指定子网
$vi /usr/lib/systemd/system/docker.service
注意原文件已存在其实就是 
EnvironmentFile=/run/flannel/subnet.env  新增的
ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS
--------3启动【注意启动flannel前要关闭docker及相关kubelet这样flannel才会覆盖docker0网桥】------------
systemctl stop kubelet
systemctl stop kube-proxy
systemctl daemon-reload
systemctl stop docker
systemctl start flanneld
systemctl enable flanneld
systemctl status flanneld
systemctl start docker
systemctl restart kubelet
systemctl restart kube-proxy
---------4验证服务------------------
进入bin目录
$cat /run/flannel/subnet.env 
DOCKER_OPT_BIP="--bip=10.254.35.1/24"
DOCKER_OPT_IPMASQ="--ip-masq=false"
DOCKER_OPT_MTU="--mtu=1450"
DOCKER_NETWORK_OPTIONS=" --bip=10.254.35.1/24 --ip-masq=false --mtu=1450"

$ ip a
95 $kubectl get nodes
******************************************
打包 点击右边 airsale-parent->Lifecycle->package   service-demo-1.0.0.0.jar
CMD ->java -jar service-demo-1.0.0.0.jar  (后面加个 & 后台执行) 访问 http://localhost:9002/hello
      java -jar service-demo-1.0.0.0.jar --server.port=9005
	  java -jar service-demo-1.0.0.0.jar --spring.profiles.active=dev
$docker pull openjdk:8    centos:7.3.1611   8u181-slim
$docker image ls 查看下载的镜像
$docker run -it openjdk:8 交互式运行
 ->java -version 
 ->exit 执行前打开另外一个终端，执行下句
$docker container ls   列出当前运行的容器 简写 ->docker ps 
$docker container ls -a  列出所有容器包括退出的 简写->docker ps -a
$docker rm [container name] 删除
把jar放到 /u01/k8s/workspace
$mv service-demo-1.0.0.0.jar service-demo.jar 重命名
$java -jar service-demo 启动访问  http://192.168.220.95:9002/hello
-------当前目录 创建dockerfile------
FROM openjdk:8       需要替换成 192.168.220.95:9999/ch-gds-service/openjdk:8u181-slim  

MAINTAINER liuyujie@inner.sss.com

VOLUME /tmp
ADD service-demo.jar app.jar
RUN sh -c 'touch /app.jar'
ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar -Duser.timezone=GMT+08 /app.jar" ]
-------------
$docker build -t service-demo:v1.0 .  #-t后面指定一个tag这里用steven加目录名，点是指在当前目录找dockerfile
$docker image ls 多了一个镜像
$docker run -it service-demo:v1.0   ---it意义不大
$docker exec -it a3460f0719cb /bin/sh
->ip a   输出 10.254.22.2 这个ip与192.168.220.95是互通的
$http://10.254.22.2:9002/hello 新开一个终端 输出Hello Server
$docker rm $(docker container ls -aq) 即可移除所有容器
$docker run -d -p 9000:9002 --name service-demo service-demo:v1.0 后台运行映射到9000端口
本机访问  http://192.168.220.95:9000/hello
$docker stop service-demo
$docker rm service-demo  删除
----安装docker-compose--------
$mv docker-compose /usr/local/bin/
$chmod +x /usr/local/bin/docker-compose
$docker-compose --version
----------镜像仓库-----------------
$tar -xvf harbor-offline-installer-v1.7.1.tgz
$mv harbor /u01/k8s/
$vi docker-compose.yml
 修改log.volumes - ./log/:var/log/docker/:z
 registry  ./data  前面加.
 registryctl  ./data  
 postgresql   ./data
 adminserver  3个
 core         4
 jobservice   1
 redis        1
 另外 proxy.ports  9999:80
$vi harbor.cfg 
 修改hostname = 192.168.220.95:9999
 修改 secretkey_path 前面加 .  后面两个不改--ssl_cert / ssl_cert_key
 修改 harbor_admin_password 为 GDS12345
$./install.sh  安装
访问 http://192.168.220.95:9999  admin  GDS12345
新建用户 019055 Liuyujie888  
$vi /etc/docker/daemon.json 
增加 "insecure-registries": ["192.168.220.95:9999"]  逗号分割

$docker tag openjdk:8 192.168.220.95:9999/ch-gds-service/openjdk:8
$docker login 192.168.220.95:9999 
$docker push 192.168.220.95:9999/ch-gds-service/openjdk:8 
-- docker tag service-demo:v2.0 192.168.220.95:9999/ch-gds-service/service-demo:v2.0
$kubectl run dep-demo --image=192.168.220.95:9999/ch-gds-service/service-demo:v2.0 
$kubectl delete deployments dep-demo  --第一次没执行成功，删除重新执行上句成功了
$kubectl get pods  -o wide  看到已经ready
$kubectl get deploy   #同kubectl get deployments 查看  启动available 1是启动
$curl 10.254.22.2:9002/hello  根据上面的ip可以访问
$kubectl scale dep-demo --replicas=3 扩缩容
$kubectl scale deployment dep-demo --replicas=3

---------------------------
---------------------------
