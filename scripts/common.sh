#!/usr/bin/env bash
#当前目录
cur_dir=$(pwd)
chmod -R +x $cur_dir
#添加执行权限
CheckSh() {
  # echo 'CheckSh:'$1
  chmod -R +x $1
  if [[ $1 =~ '.sh' ]]; then
    sed -i 's/\r$//' $1
  fi
}

#循环添加执行权限
ListFiles() {
  #1st param, the dir name
  #2nd param, the aligning space
  for file in $(ls $1); do
    if [ -d "$1/$file" ]; then
      #echo "file:-d==>   $2$file"
      ListFiles "$1/$file$2"
    elif [ -f "$1/$file" ]; then
      #echo "$2$file" #
      #echo "file:-f==> $1/$file" #
      CheckSh $1/$file
    else
      echo "$2$file" #
      echo "Error: 无法识别当前文件类型"
      exit 1
    fi
  done
}
#得到系统版本位数
Get_OS_Bit() {
  if [[ $(getconf WORD_BIT) == '32' && $(getconf LONG_BIT) == '64' ]]; then
    Is_64bit='y'
    _os_bit=64
  else
    Is_64bit='n'
    _os_bit=32
  fi
}
#得到系统版本类型
Get_Dist_Name() {
  echo "+------------------------------------------------------------------------+"
  echo "|                         系统版本类型检测                               |"
  echo "+------------------------------------------------------------------------+"

  if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
    DISTRO='CentOS'
    PM='yum'
  elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
    DISTRO='RHEL'
    PM='yum'
  elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
    DISTRO='Aliyun'
    PM='yum'
  elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
    DISTRO='Fedora'
    PM='yum'
  elif grep -Eqi "Amazon Linux" /etc/issue || grep -Eq "Amazon Linux" /etc/*-release; then
    DISTRO='Amazon'
    PM='yum'
  elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
    DISTRO='Debian'
    PM='apt-get'
  elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
    DISTRO='Ubuntu'
    PM='apt-get'
  elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
    DISTRO='Raspbian'
    PM='apt-get'
  elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
    DISTRO='Deepin'
    PM='apt-get'
  elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release; then
    DISTRO='Mint'
    PM='apt-get'
  elif grep -Eqi "Kali" /etc/issue || grep -Eq "Kali" /etc/*-release; then
    DISTRO='Kali'
    PM='apt-get'
  else
    DISTRO='unknow'
    PM=''
  fi
  Get_OS_Bit
  echo -e "+--------------------当前系统类型：$DISTRO ；安装命令：$PM    ------------+"
  echo -e "+--------------------当前系统位数：$_os_bit     -------------------------------+"
  echo -e "+------------------------------------------------------------------------+"
}
