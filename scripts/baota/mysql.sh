#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file
download_Url=$NODE_URL

run_path="/root"
Is_64bit=`getconf LONG_BIT`
Setup_Path="/www/server/mysql"
Data_Path="/www/server/data"
alibabaVer=`cat /etc/redhat-release |grep Alibaba`
isFedora=`cat /etc/redhat-release |grep Fedora`
centos_version=`cat /etc/redhat-release | grep ' 7.' | grep -i centos`


if [ "${isFedora}" ] || [ "${alibabaVer}" ];then
	wget -O mysql.sh $download_Url/install/0/mysql.sh -T 5
	bash mysql.sh $1 $2
	exit;
fi

if [ -z "${centos_version}" ]; then
	wget -O mysql.sh $download_Url/install/1/old/mysql.sh -T 5
	bash mysql.sh $1 $2
	exit;
fi

if [ "${centos_version}" != '' ]; then
	rpm_path="centos7"
else
	rpm_path="centos6"
fi

Install_mysqldb()
{
	wget -O MySQL-python-1.2.5.zip ${download_Url}/install/src/MySQL-python-1.2.5.zip -T 10
	unzip MySQL-python-1.2.5.zip
	rm -f MySQL-python-1.2.5.zip
	cd MySQL-python-1.2.5
	python setup.py install
	cd ..
	rm -rf MySQL-python-1.2.5
}

Install_mysqldb3()
{
	wget -O mysqlclient-1.3.12.zip ${download_Url}/install/src/mysqlclient-1.3.12.zip -T 10
	unzip mysqlclient-1.3.12.zip
	rm -f mysqlclient-1.3.12.zip
	cd mysqlclient-1.3.12
	python setup.py install
	cd ..
	rm -rf mysqlclient-1.3.12
}

Install_Mysql(){
	Uninstall_Mysql
	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql
	wget -O bt-${sqlVersion}.rpm ${download_Url}/rpm/${rpm_path}/${Is_64bit}/bt-${sqlVersion}.rpm
	rpm -ivh bt-${sqlVersion}.rpm --force --nodeps
	rm -f bt-${sqlVersion}.rpm
}

Install_Mysql_PyDb(){
	pyVersion=$(python -V 2>&1|awk '{printf ("%d",$2)}')
	if [ "${pyVersion}" == "2" ];then
		if [ -f "${Setup_Path}/mysqlDb3.pl" ]; then
			pip uninstall mysqlclient -y
			Install_mysqldb3
			/etc/init.d/bt reload
		else
			pip uninstall mysql-python -y
			pipUrl=`cat /root/.pip/pip.conf|awk 'NR==2 {print $3}'`
			if [ "${pipUrl}" != "" ]; then
				checkPip=`curl --connect-timeout 5 --head -s -o /dev/null -w %{http_code} ${pipUrl}`
			fi
			if [ "${checkPip}" = "200" ]; then
				pip install mysql-python
			else
				Install_mysqldb
				/etc/init.d/bt reload
			fi
		fi
		pip uninstall pymysql -y
		pip install pymysql
	else
		pip uninstall pymysql -y
		pip install pymysql
	fi	
}

Uninstall_Mysql(){
	yum remove mysql-devel -y
	[ -f "/etc/init.d/mysqld" ] && /etc/init.d/mysqld stop
	mysqlVersion=`rpm -qa |grep bt-mysql-`
	mariadbVersion=`rpm -qa |grep bt-mariadb-`
	[ "${mysqlVersion}" ] && rpm -e $mysqlVersion --nodeps
	[ "${mariadbVersion}" ] && rpm -e $mariadbVersion --nodeps
	[ -f "${Setup_Path}/rpm.pl" ] && yum remove $(cat ${Setup_Path}/rpm.pl) -y
	if [ -f "${Setup_Path}/bin/mysql" ] || [ -f "/etc/init.d/mysqld" ]; then
		/etc/init.d/mysqld stop > /dev/null 2>&1
		chkconfig --del mysqld
		rm -rf /etc/init.d/mysqld
		rm -rf ${Setup_Path}
		mkdir -p /www/backup
		mv -f $Data_Path  /www/backup/oldData
		rm -rf $Data_Path
		rm -f /usr/bin/mysql*
		rm -f /usr/lib/libmysql*
		rm -f /usr/lib64/libmysql*
	fi
	
}

actionType=$1
version=$2

if [ "${actionType}" == 'install' ] || [ "${actionType}" == "update" ];then
	if [ -z "${version}" ]; then
		exit
	fi
	mysqlpwd=`cat /dev/urandom | head -n 16 | md5sum | head -c 16`
	case "$version" in
		'5.1')
			sqlVersion="mysql51"
			;;
		'5.5')
			sqlVersion="mysql55"
			;;
		'5.6')
			sqlVersion="mysql56"
			;;
		'5.7')
			sqlVersion="mysql57"
			;;
		'8.0')
			sqlVersion="mysql80"
			;;
		'alisql')
			sqlVersion="AliSQL"
			;;
		'mariadb_10.0')
			sqlVersion="mariadb100"
			;;		
		'mariadb_10.1')
			sqlVersion="mariadb101"
			;;
		'mariadb_10.2')
			sqlVersion="mariadb102"
			;;
		'mariadb_10.3')
			sqlVersion="mariadb103"
			;;
	esac
	Install_Mysql
	Install_Mysql_PyDb
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_Mysql del
fi
