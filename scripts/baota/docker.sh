#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
install_tmp='/tmp/bt_install.pl'
public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi

. $public_file

download_Url=$NODE_URL

Install_Ubuntu_ce()

{
	sudo apt remove docker.io -y
    pip install pytz
	apt install docker.io -y
	apt install apt-transport-https ca-certificates curl software-properties-common -y
	echo 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable' >/etc/apt/sources.list.d/docker.list
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	apt install docker-ce -y
	update-rc.d docker defaults

}

Install_Docker_ce()

{
	#install docker-ce
	pip install pytz
	yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine -y
	yum install -y yum-utils device-mapper-persistent-data lvm2
	yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
	yum makecache fast
	yum -y install docker-ce
	
	#yum remove docker docker-common docker-selinux docker-engine -y
	#yum install -y yum-utils device-mapper-persistent-data lvm2 atomic-registries container-storage-setup containers-common oci-register-machine oci-systemd-hook oci-umount python-pytoml subscription-manager-rhsm-certificates yajl -y
	#yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	#yum-config-manager --enable docker-ce-edge
	#yum install docker-ce -y
	#yum-config-manager --disable docker-ce-edge
	#move docker data to /www/server/docker
	#echo 'move docker data to /www/server/docker ...';
	#if [ -f /usr/bin/systemctl ];then
	#	systemctl stop docker
	#else
	#	service docker stop
	#fi

	#if [ ! -d /www/server/docker ];then
	#	mv -f /var/lib/docker /www/server/docker
	#else
	#	rm -rf /var/lib/docker
	#fi
	#ln -sf /www/server/docker /var/lib/docker

	#systemctl or service
	if [ -f /usr/bin/systemctl ];then
		systemctl stop getty@tty1.service
		systemctl mask getty@tty1.service
		systemctl enable docker
		systemctl start docker
	else
		chkconfig --add docker
		chkconfig --level 2345 docker on
		service docker start
	fi
}


Install_docker()
{
	mkdir -p /www/server/panel/plugin/docker
	systemctl start docker
	is_start=$(systemctl status docker|grep "active (running)")
	if [ "$is_start" == "" ];then
		rm -f /var/lib/docker
		if [ -f "/usr/bin/apt-get" ];then
	    	Install_Ubuntu_ce
	    elif [ -f "/usr/bin/yum" ];then
	    	Install_Docker_ce
	    fi
	fi
	
	curl -Ss --connect-timeout 3 -m 60 http://download.bt.cn/install/pip_select.sh|bash
    pip install docker==2.7
    pip install requests -I
    
	echo '正在安装脚本文件...' > $install_tmp
	grep "English" /www/server/panel/config/config.json
	if [ "$?" -ne 0 ];then
		wget -O /www/server/panel/plugin/docker/docker_main.py $download_Url/install/plugin/docker/docker_main.py -T 5
		wget -O /www/server/panel/plugin/docker/index.html $download_Url/install/plugin/docker/index.html -T 5
		wget -O /www/server/panel/plugin/docker/info.json $download_Url/install/plugin/docker/info.json -T 5
		wget -O /www/server/panel/plugin/docker/icon.png $download_Url/install/plugin/docker/icon.png -T 5
		wget -O /www/server/panel/plugin/docker/login-docker.html $download_Url/install/plugin/docker/login-docker.html -T 5
		wget -O /www/server/panel/plugin/docker/userdocker.html $download_Url/install/plugin/docker/userdocker.html -T 5
	else
		wget -O /www/server/panel/plugin/docker/docker_main.py $download_Url/install/plugin/docker_en/docker_main.py -T 5
		wget -O /www/server/panel/plugin/docker/index.html $download_Url/install/plugin/docker_en/index.html -T 5
		wget -O /www/server/panel/plugin/docker/info.json $download_Url/install/plugin/docker_en/info.json -T 5
		wget -O /www/server/panel/plugin/docker/icon.png $download_Url/install/plugin/docker_en/icon.png -T 5
		wget -O /www/server/panel/plugin/docker/login-docker.html $download_Url/install/plugin/docker_en/login-docker.html -T 5
		wget -O /www/server/panel/plugin/docker/userdocker.html $download_Url/install/plugin/docker_en/userdocker.html -T 5
	fi
	echo '安装完成' > $install_tmp
	/etc/init.d/bt reload
}





Uninstall_docker()
{
	rm -rf /www/server/panel/plugin/docker
	if [ -f "/usr/bin/apt-get" ];then
	    systemctl stop docker
    	pip uninstall docker -y

    elif [ -f "/usr/bin/yum" ];then
    	if [ -f /usr/bin/systemctl ];then
			systemctl disable docker
			systemctl stop docker
		else
			service docker stop
			chkconfig --level 2345 docker off
			chkconfig --del docker
		fi
		pip uninstall docker -y
    fi

}



action=$1
if [ "${1}" == 'install' ];then
	Install_docker
elif  [ "${1}" == 'update' ];then
	Install_docker
elif [ "${1}" == 'uninstall' ];then
	Uninstall_docker
fi

