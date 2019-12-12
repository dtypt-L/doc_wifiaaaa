
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
ARG CDN_URl
ARG BUILD_DEPS
ARG SAVE_DEPS
COPY resource /tmp/resource/
RUN set -eux ; \
    # ⬇ 设置源
    if [ -n "$CDN_URl" ]; then \
        cp -a /tmp/resource/* /etc/  ; \
    fi ; \
    # ⬇ 更新、安装基础组件
    if [ -n "$BUILD_DEPS" ]; then \
         apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS ; \
    fi ; \
     # ⬇ 添加用户
    groupadd -f $USER_GROUP ; \
    groupmod -g $USER_GROUP_ID $USER_GROUP ; \
    useradd  -g $USER_GROUP $USER_NAME ; \
    usermod -u $USER_NAME_ID $USER_NAME  ; \
    # ⬇ 工作目录授权
    if [ ! -d $WORKING_DIR"/" ] ;then \
        mkdir -p  $WORKING_DIR ; \
        mkdir -p  $WORKING_DIR/wwwlogs/mysql ; \
    fi ; \
    chown -R $USER_GROUP:$USER_NAME  $WORKING_DIR ; \
    chmod -R 0775 $WORKING_DIR ; \
    chmod -R 0777 $WORKING_DIR/wwwlogs/mysql  ; \
    # ⬇ 修改时区
    ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime ; \
    echo $TIME_ZONE > /etc/timezone ;
RUN set -eux ; \
   # ⬇ 扩展安装源
    if [ -n "$SAVE_DEPS" ]; then \
        apt-get update && apt-get install -y --no-install-recommends $SAVE_DEPS ; \
    fi ; \
    rm -rf /etc/apt/lists/* ; \
    rm -rf /etc/apk/lists/* ; \
    rm -rf /tmp/resource ;
