#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
redis_version=5.0.5
runPath=/root
public_file=/www/server/panel/install/public.sh
[ ! -f $public_file ] && wget -O $public_file http://download.bt.cn/install/public.sh -T 5;

publicFileMd5=$(md5sum ${public_file}|awk '{print $1}')
md5check="0aa6cc891b1efd074f37feef75ec60bb"
[ "${publicFileMd5}" != "${md5check}"  ] && wget -O $public_file http://download.bt.cn/install/public.sh -T 5;

. $public_file
download_Url=$NODE_URL
System_Lib(){
	if [ "${PM}" == "yum" ] || [ "${PM}" == "dnf" ] ; then
		Pack="sudo"
		${PM} install ${Pack} -y
	elif [ "${PM}" == "apt-get" ]; then
		Pack="sudo"
		${PM} install ${Pack} -y
	fi

}
Service_Add(){
	if [ -f "/usr/bin/yum" ];then
		chkconfig --add redis
		chkconfig --level 2345 redis on
	elif [ -f "/usr/bin/apt" ]; then
		apt-get install sudo -y	
		update-rc.d redis defaults
	fi
}
Service_Del(){
	if [ -f "/usr/bin/yum" ];then
		chkconfig --level 2345 redis off
	elif [ -f "/usr/bin/apt" ]; then
		update-rc.d redis remove
	fi
}

ext_Path(){
	case "${version}" in 
		'53')
		extFile='/www/server/php/53/lib/php/extensions/no-debug-non-zts-20090626/redis.so'
		;;
		'54')
		extFile='/www/server/php/54/lib/php/extensions/no-debug-non-zts-20100525/redis.so'
		;;
		'55')
		extFile='/www/server/php/55/lib/php/extensions/no-debug-non-zts-20121212/redis.so'
		;;
		'56')
		extFile='/www/server/php/56/lib/php/extensions/no-debug-non-zts-20131226/redis.so'
		;;
		'70')
		extFile='/www/server/php/70/lib/php/extensions/no-debug-non-zts-20151012/redis.so'
		;;
		'71')
		extFile='/www/server/php/71/lib/php/extensions/no-debug-non-zts-20160303/redis.so'
		;;
		'72')
		extFile='/www/server/php/72/lib/php/extensions/no-debug-non-zts-20170718/redis.so'
		;;
		'73')
		extFile='/www/server/php/73/lib/php/extensions/no-debug-non-zts-20180731/redis.so'
		;;
	esac
}
Install_Redis()
{
	groupadd redis
	useradd -g redis -s /sbin/nologin redis
	if [ ! -f '/www/server/redis/src/redis-server' ];then
		rm -rf /www/server/redis
		cd /www/server
		wget $download_Url/src/redis-$redis_version.tar.gz -T 5
		tar zxvf redis-$redis_version.tar.gz
		mv redis-$redis_version redis
		cd redis
		make -j ${cpuCore}

		wget -O /etc/init.d/redis ${download_Url}/init.redis
		ln -sf /www/server/redis/src/redis-cli /usr/bin/redis-cli
		chmod +x /etc/init.d/redis
		chown -R redis.redis /www/server/redis
		#v=`cat /www/server/panel/class/common.py|grep "g.version = "|awk -F "'" '{print $2}'|awk -F "." '{print $1}'`
		v=`cat /www/server/panel/class/common.py|grep -E ".version = [\"|\']"|awk -F '[\"\47]+' '{print $2}'|awk -F '.' '{print $1}'`
		if [ "$v" -ge "6" ];then
			pluginPath=/www/server/panel/plugin/redis
			mkdir -p $pluginPath
			grep "English" /www/server/panel/config/config.json
			if [ "$?" -ne 0 ];then
				wget -O $pluginPath/redis_main.py $download_Url/install/plugin/redis/redis_main.py -T 5
				wget -O $pluginPath/index.html $download_Url/install/plugin/redis/index.html -T 5
				wget -O $pluginPath/info.json $download_Url/install/plugin/redis/info.json -T 5
				wget -O $pluginPath/icon.png $download_Url/install/plugin/redis/icon.png -T 5
			else
				wget -O $pluginPath/redis_main.py $download_Url/install/plugin/redis_en/redis_main.py -T 5
				wget -O $pluginPath/index.html $download_Url/install/plugin/redis_en/index.html -T 5
				wget -O $pluginPath/info.json $download_Url/install/plugin/redis_en/info.json -T 5
				wget -O $pluginPath/icon.png $download_Url/install/plugin/redis_en/icon.png -T 5
			fi
		fi
	
		sed -i 's/dir .\//dir \/www\/server\/redis\//g' /www/server/redis/redis.conf

		if [ -d "/www/server/panel/BTPanel" ]; then
			wget -O /etc/init.d/redis ${download_Url}/init/init6.redis
			wget -O /www/server/redis/redis.conf ${download_Url}/conf/redis.conf
		else
			wget -O /etc/init.d/redis ${download_Url}/init/init5.redis
		fi

		chmod +x /etc/init.d/redis 
		/etc/init.d/redis start
		rm -f /www/server/redis-$redis_version.tar.gz
		cd $runPath
		echo $redis_version > /www/server/redis/version.pl
	fi
	
	if [ ! -d /www/server/php/$version ];then
		return;
	fi
	
	if [ ! -f "/www/server/php/$version/bin/php-config" ];then
		echo "php-$vphp 未安装,请选择其它版本!"
		echo "php-$vphp not install, Plese select other version!"
		return
	fi
	
	isInstall=`cat /www/server/php/$version/etc/php.ini|grep 'redis.so'`
	if [ "${isInstall}" != "" ];then
		echo "php-$vphp 已安装过Redis,请选择其它版本!"
		echo "php-$vphp not install, Plese select other version!"
		return
	fi
	

	if [ ! -f "${extFile}" ];then		
		if [ "${version}" == "52" ];then
			rVersion='2.2.7'
		elif [ "${version}" -ge "70" ];then
			rVersion='5.0.2'
		else
			rVersion='4.3.0'
		fi
		
		wget $download_Url/src/redis-$rVersion.tgz -T 5
		tar zxvf redis-$rVersion.tgz
		rm -f redis-$rVersion.tgz
		cd redis-$rVersion
		/www/server/php/$version/bin/phpize
		./configure --with-php-config=/www/server/php/$version/bin/php-config
		make && make install
		cd ../
		rm -rf redis-$rVersion*
	fi
	
	if [ ! -f "${extFile}" ];then
		echo 'error';
		exit 0;
	fi
	
	echo -e "\n[redis]\nextension = ${extFile}\n" >> /www/server/php/$version/etc/php.ini

	service php-fpm-$version reload
	echo '==============================================='
	echo 'successful!'
}

Uninstall_Redis()
{
	if [ ! -d /www/server/php/$version/bin ];then
		pkill -9 redis
		rm -f /var/run/redis_6379.pid
		Service_Del
		rm -f /usr/bin/redis-cli
		rm -f /etc/init.d/redis
		rm -rf /www/server/redis
		rm -rf /www/server/panel/plugin/redis

		return;
	fi
	if [ ! -f "/www/server/php/$version/bin/php-config" ];then
		echo "php-$vphp 未安装,请选择其它版本!"
		echo "php-$vphp not install, Plese select other version!"
		return
	fi
	
	isInstall=`cat /www/server/php/$version/etc/php.ini|grep 'redis.so'`
	if [ "${isInstall}" = "" ];then
		echo "php-$vphp 未安装Redis,请选择其它版本!"
		echo "php-$vphp not install Redis, Plese select other version!"
		return
	fi
	
	sed -i '/redis.so/d' /www/server/php/$version/etc/php.ini
	
	service php-fpm-$version reload
	echo '==============================================='
	echo 'successful!'
}
Update_redis(){ 
	REDIS_CONF="/www/server/redis/redis.conf"
	REDIS_PORT=$(cat ${REDIS_CONF} |grep port|grep -v '#'|awk '{print $2}')
	REDIS_PASS=$(cat ${REDIS_CONF} |grep requirepass|grep -v '#'|awk '{print $2}')
	REDIS_HOST=$(cat ${REDIS_CONF} |grep bind|grep -v '#'|awk '{print $2}')
	REDIS_DIR=$(cat ${REDIS_CONF} |grep dir|grep -v '#'|awk '{print $2}')

	cd /www/server
	
	wget $download_Url/src/redis-$redis_version.tar.gz -T 5
	tar zxvf redis-$redis_version.tar.gz
	rm -f redis-$redis_version.tar.gz
	mv redis-$redis_version redis2
	cd redis2
	make -j ${cpuCore}
	if [ -f "${REDIS_DIR}dump.rdb" ]; then
		\cp -rf ${REDIS_DIR}dump.rdb ${REDIS_DIR}dumpBak.rdb
		if [ -z "${REDIS_PASS}" ]; then
			/www/server/redis/src/redis-cli -p ${REDIS_PORT} <<EOF
SAVE
EOF
		else
			/www/server/redis/src/redis-cli -p ${REDIS_PORT} -a ${REDIS_PASS} <<EOF
SAVE
EOF
		fi
	fi

	/etc/init.d/redis stop
	sleep 1
	cd ..
	
	[ -f "/www/server/redis/dump.rdb" ] && \cp -rf /www/server/redis/dump.rdb /www/server/redis2/dump.rdb
	\cp -rf /www/server/redis/redis.conf /www/server/redis2/redis.conf

	if [ -d "/www/server/redisBak" ]; then
		tar czvf /www/backup/redisBak$(date +%Y%m%d).tar.gz /www/server/redisBak
		rm -rf /www/server/redisBak 
	fi

	mv /www/server/redis /www/server/redisBak
	mv redis2 redis
	chown -R redis.redis /www/server/redis
	rm -f /usr/bin/redis-cli
	ln -sf /www/server/redis/src/redis-cli /usr/bin/redis-cli
	/etc/init.d/redis start
	rm -f /www/server/redis/version_check.pl
	echo $redis_version > /www/server/redis/version.pl
}
Bt_Check(){
	checkFile="/www/server/panel/install/check.sh"
	if [ ! -f "${checkFile}" ];then
		wget -O ${checkFile} ${download_Url}/tools/check.sh
	fi
	checkFileMd5=$(md5sum ${checkFile}|awk '{print $1}')
	local md5Check="d3a76081aafd6493484a81cd446527b3"
	if [ "${checkFileMd5}" != "${md5Check}" ];then
		wget -O ${checkFile} ${download_Url}/tools/check.sh			
	fi
	. ${checkFile} 
}
actionType=$1
version=$2
vphp=${version:0:1}.${version:1:1}
if [ "$actionType" == 'install' ];then
	System_Lib
	ext_Path
	Install_Redis
	Service_Add
	Bt_Check
elif [ "$actionType" == 'uninstall' ];then
	Uninstall_Redis
elif [ "${actionType}" == "update" ]; then
	Update_redis
fi

