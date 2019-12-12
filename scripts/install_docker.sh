#!/usr/bin/env bash
. ./common.sh

Remove_Docker() {
  echo -e "+------------------------------------------------------------------------+"
  echo -e "|                               Docker卸载                               |"
  echo -e "+------------------------------------------------------------------------+"
  echo -e "| Docker卸载中......                                                         |"

   sudo $PM remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine\
                  docker-compose
  sudo rm /usr/local/bin/docker-compose
  echo -e "+------------------------------------------------------------------------+"
  echo -e "| Docker卸载完成......                                                         |"
  echo -e "+------------------------------------------------------------------------+"
}

Initall_Docker() {
   pName=$(rpm -qa | grep "docker")
  if [ $? -eq 0 ]; then
    Remove_Docker
  fi
  echo -e "+------------------------------------------------------------------------+"
  echo -e "|                               Docker安装                               |"
  echo -e "+------------------------------------------------------------------------+"
  sudo $PM -y yum-utils device-mapper-persistent-data lvm2
  sudo $PM-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
  sudo $PM -y install docker-ce docker-compose docker-ce-cli containerd.io
  curl -L https://github.com/docker/compose/releases/download/1.25.1-rc1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  echo -e "+------------------------------------------------------------------------+"
  pName=$(rpm -qa | grep "docker")
  if [ $? -eq 0 ]; then
    echo -e "| Docker安装成功                                                         |"
    docker -v
    docker-compose -v
    echo -e "| Docker启动中......                                                         |"
    # 1. 建立 Docker 用户组
    sudo groupadd docker
    # 2.添加当前用户到 docker 组
    sudo usermod -aG docker $USER
    systemctl enable docker
     # docker加速
     DOCKER_OPTS="--registry-mirror=https://registry.docker-cn.com"
     \cp -rf $cur_dir/conf/docker_daemon.json /etc/docker/daemon.json
      systemctl daemon-reload
    # 重启docker
    systemctl restart docker
    echo -e "| Docker启动成功                                                         |"
  else
    echo -e "| Docker安装失败                                                          |"
  fi

  echo -e "+------------------------------------------------------------------------+"
}
# Check if user is root
if [ $(id -u) != "0" ]; then
  echo "Error: 您账户无权限, 请使用root账户"
  exit 1
else
  ListFiles $cur_dir
  echo "1.系统信息监测中....."
  Get_Dist_Name
  echo "2.Docker安装中....."
  Initall_Docker
fi
