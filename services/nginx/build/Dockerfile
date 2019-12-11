
ARG IMAGE_BASE
ARG IMAGE_VERSION
ARG IMAGE_TAG

FROM $IMAGE_BASE:$IMAGE_VERSION$IMAGE_TAG

ARG USER_GROUP
ARG USER_NAME
ARG USER_GROUP_ID
ARG USER_NAME_ID
ARG TIME_ZONE
ARG WORKING_DIR
ARG CHANGE_SOURCE
ARG BUILD_DEPS

RUN set -eux ; \
    # ⬇ 更新、安装基础组件
#    sed -i "http://dl-4.alpinelinux.org/alpine/edge/testing" /etc/apk/repositories ; \
    sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories ; \
    apk add --no-cache --virtual .build-deps shadow $BUILD_DEPS ; \
    rm -rf /var/lib/apt/lists/* ; \
    # ⬇ 添加用户
    groupadd -f $USER_GROUP ; \
    groupmod -g $USER_GROUP_ID $USER_GROUP ; \
    useradd  -g $USER_GROUP $USER_NAME ; \
    usermod -u $USER_NAME_ID $USER_NAME  ; \
    # ⬇ 工作目录授权
    if [ ! -d $WORKING_DIR"/" ] ;then \
        mkdir -p  $WORKING_DIR ; \
    fi ; \
    chown -R $USER_GROUP:$USER_NAME  $WORKING_DIR ; \
    chmod -R 0751 $WORKING_DIR ; \
    # ⬇ 修改时区
    ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime ; \
    echo $TIME_ZONE > /etc/timezone ;