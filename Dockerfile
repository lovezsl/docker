FROM centos:centos7
MAINTAINER zsl_0529@163.com63.com
ENV TIME_ZOME Asia/Shanghai

#COPY nginx.conf /usr/local/nginx/
RUN yum -y install gcc gcc-c++ make openssl-devel pcre-devel zlib-devel wget \
        #创建nginx用户关联nginx和php-fpm程序 
        && useradd -s /sbin/nologin nginx \
        && mkdir -p /usr/local/nginx \
        && cd /tmp \
        && wget http://nginx.org/download/nginx-1.21.4.tar.gz \
        && tar -zxvf nginx-1.21.4.tar.gz \
        && cd /tmp/nginx-1.21.4 \
        && ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-stream --with-http_ssl_module --with-http_stub_status_module \
        && make -j 4 \
        && make install \
        && echo "${TIME_ZOME}" > /etc/timezone \
        && ln -sf /usr/share/zoneinfo/${TIME_ZOME} /etc/localtime \
        && rm -rf /tmp/nginx* \
        && ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx  \
 
        #php是直接用第三方yum源epel安装的，指定安装7.3版本
        && yum install -y epel-release  \
        && rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
        && yum -y install yum-utils  \
        && yum-config-manager --enable remi-php73  \
        && yum -y install php php73-php-opcache php73-php-ldap php73-php-odbc php73-php-pear php73-php-xml php73-php-xmlrpc php73-php-soap curl curl-devel  php73-php-mbstring php73-php-mysqlnd  php73-php-fpm  php73-php-gd php73-php-redis php73-php-rdkafka \
        #把php-fpm的www.conf配置里的user和group都nginx
        && sed -i "s/apache/nginx/g"  /etc/opt/remi/php73/php-fpm.d/www.conf \
        && yum clean all \
        && yum -y remove gcc gcc-c++ make \
        #设置权限php的session目录权限，否则跑项目里，会提示"Permission denied"
        && chmod -R 777 /var/opt/remi/php73/lib/php/session/  
  

WORKDIR /usr/local/nginx/
EXPOSE 80
CMD /opt/remi/php73/root/sbin/php-fpm  && nginx -g "daemon off;"   

#上一行CMD同时启动php-fpm服务，不过最后一个服务一定要前台运行，要不创建的镜像后台会启动不起来(docker容器运行的原理)
