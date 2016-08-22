#!/bin/bash
# The perfect rootserver UPDATE
# by Shoujii
# https://github.com/mxiiii/perfect_update
# Based on https://github.com/zypr/perfectrootserver & https://github.com/mxiiii/perfect_update
# Thanks to Zypr and and mxiiii
# Compatible with Debian 8.x (jessie)

source ~/updateconfig.cfg

# Some nice colors
cyan() { echo "$(tput setaf 6)$*$(tput setaf 9)"; }
textb() { echo $(tput bold)${1}$(tput sgr0); }
greenb() { echo $(tput bold)$(tput setaf 2)${1}$(tput sgr0); }
redb() { echo $(tput bold)$(tput setaf 1)${1}$(tput sgr0); }
yellowb() { echo $(tput bold)$(tput setaf 3)${1}$(tput sgr0); }
pinkb() { echo $(tput bold)$(tput setaf 5)${1}$(tput sgr0); }

# Some nice variables
info="$(textb [INFO] -)"
warn="$(yellowb [WARN] -)"
error="$(redb [ERROR] -)"
fyi="$(pinkb [INFO] -)"
ok="$(greenb [OKAY] -)"

echo
echo "$(yellowb +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+)"
echo " $(textb Perfect) $(textb Rootserver) $(textb Update) $(textb by)" "$(cyan REtender / Shoujii)"
echo "$(yellowb +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+)"
echo
if [ "$CONFIG_COMPLETED" != '1' ]; then
echo "${error} Please check the updateconfig and set a valid value for the variable \"$(textb CONFIG_COMPLETED)\" to continue." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
exit 1
fi

echo "${info} Stop Nginx..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
systemctl -q stop nginx.service

echo "${info} Backup Nginx Folder..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
rm /root/backup/ -r >/dev/null 2>&1
mkdir /root/backup/ >/dev/null 2>&1
mkdir /root/backup/nginx/ >/dev/null 2>&1
cp -R /etc/nginx/* /root/backup/nginx/

cd ~/sources

echo "${info} Downloading Nginx Pagespeed..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip >/dev/null 2>&1
unzip -qq release-${NPS_VERSION}-beta.zip
cd ngx_pagespeed-release-${NPS_VERSION}-beta/
wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz >/dev/null 2>&1
tar -xzf ${NPS_VERSION}.tar.gz

cd ~/sources

echo "${info} Downloading Nginx..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz >/dev/null 2>&1
tar -xzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}

echo "${info} Compiling Nginx..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
./configure --prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/lib/nginx/body \
--http-proxy-temp-path=/var/lib/nginx/proxy \
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
--http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
--http-scgi-temp-path=/var/lib/nginx/scgi \
--user=www-data \
--group=www-data \
--without-http_autoindex_module \
--without-http_browser_module \
--without-http_empty_gif_module \
--without-http_userid_module \
--without-http_split_clients_module \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_realip_module \
--with-http_geoip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-mail \
--with-mail_ssl_module \
--with-file-aio \
--with-ipv6 \
--with-debug \
--with-pcre \
--with-cc-opt='-O2 -g -pipe -Wall -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' \
--with-openssl=$HOME/sources/openssl-${OPENSSL_VERSION} \
--add-module=$HOME/sources/ngx_pagespeed-release-${NPS_VERSION}-beta >/dev/null 2>&1

# make the package
make >/dev/null 2>&1

# Create a .deb package
checkinstall --install=no -y >/dev/null 2>&1

# Install the package
echo "${info} Installing Nginx..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
dpkg -i nginx_${NGINX_VERSION}-1_amd64.deb >/dev/null 2>&1
mv nginx_${NGINX_VERSION}-1_amd64.deb ../

echo "${info} Restore Nginx Folder..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
cp -R /root/backup/nginx/* /etc/nginx/

echo "${info} Starting Nginx..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
systemctl -q start nginx.service

echo "${info} Update finished..." | awk '{ print strftime("[%H:%M:%S] |"), $0 }'
