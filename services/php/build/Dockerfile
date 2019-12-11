
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
ARG PECL_DEPS
COPY resource /tmp/resource/
RUN set -eux ; \
    # ⬇ 设置源
    if [ -n "$CDN_URl" ]; then \
        cp -a /tmp/resource/* /etc/  ; \
#        sed -i "s/dl-cdn.alpinelinux.org/$CDN_URl/g" /etc/apk/repositories  ; \
    fi ; \
    # ⬇ 更新、安装基础组件
    if [ -n "$BUILD_DEPS" ]; then \
         apk add --no-cache --virtual .build-deps $BUILD_DEPS ; \
    fi ; \
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
    chmod -R 0775 $WORKING_DIR ; \
    # ⬇ 修改时区
    ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime ; \
    echo $TIME_ZONE > /etc/timezone ;


####################################################################################
# 安装 PHP 扩展
####################################################################################

RUN set -eux  ; \
# ⬇ 安装 Composer
##    # ⬇ 线上安装
#    curl -sS https://getcomposer.org/installer | php ; \
#    mv composer.phar /usr/local/bin/composer ; \
    # ⬇ 本地安装
    php ; \
    mv /etc/apk/lists/composer.phar /usr/local/bin/composer  ; \
    chmod 777 /usr/local/bin/composer  ; \
    # ⬇ 替换源
    rm -rf /etc/apt/sources.list.d/buster.list ; \
#   composer config -g repo.packagist composer https://packagist.phpcomposer.com ; \
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ ; \
##     更新 composer
#    composer self-update --clean-backups ; \
    # ⬇ 安装 自带扩展
    docker-php-source extract ; \
    if [ -n "$SAVE_DEPS" ]; then \
        docker-php-ext-configure gd  --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/  ; \
        docker-php-ext-install -j$(nproc) gd $SAVE_DEPS ; \
#       docker-php-ext-enable gd $PHP_SAVE_DEPS ; \
    fi ; \
    if [ -n "$PECL_DEPS" ]; then \
        pecl install -o -f $PECL_DEPS ; \
        docker-php-ext-enable $PECL_DEPS ; \
        rm -rf /tmp/pear ; \
    fi ; \
#    # ⬇ 清理 扩展安装源
    docker-php-source delete ; \
    rm -rf /etc/apt/lists/* ; \
    rm -rf /etc/apk/lists/* ; \
    rm -rf //tmp/resource ;

