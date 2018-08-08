FROM debian:stretch-slim

CMD ["add-apt-repository non-free"]
RUN apt-get update \
    && apt-get -f install \
    && apt-get -y dist-upgrade

RUN apt-get -y install ntp ca-certificates unzip curl sudo cron nano openssh-server supervisor \
    locate tar telnet wget logrotate fail2ban dos2unix ntpdate htop iotop vim iftop smbclient \
    git python python-pip \
    software-properties-common \
    libexpat1 ssl-cert \
    apt-transport-https \
    xvfb cutycapt \
    libav-tools \
    libsox-fmt-mp3 sox \
    espeak \
    brltty \
    mysql-client mysql-common mysql-server \
    apache2 apache2-utils libexpat1 ssl-cert \
    php7.0 php7.0-curl php7.0-gd php7.0-imap php7.0-json php7.0-mcrypt php7.0-mysql php7.0-xml php7.0-opcache php7.0-soap php7.0-xmlrpc lib$
    && rm -rf /var/lib/apt/lists/*

RUN echo "root:Jeedom" | chpasswd \
    && sed -i 's/#Port 22/Port 22/;s/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

RUN mkdir -p /var/run/sshd /var/log/supervisor

ADD https://raw.githubusercontent.com/jeedom/core/stable/install/install.sh /root/install.sh

RUN chmod +x /root/install.sh \
    && apt-get -y autoremove

RUN /root/install.sh -w /var/www/html -m Jeedom \
    && apt-get -y autoremove

VOLUME /var/lib/mysql
VOLUME /var/www/html

EXPOSE 80
EXPOSE 22

ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD conf/init.sh /root/init.sh
RUN chmod +x /root/init.sh \
    && systemctl disable apache2 \
    && systemctl disable mysql \
    && systemctl disable ssh \
    && systemctl disable cron \
    && mkdir -p /srv/mysql /srv/html \
    && cp -R /var/lib/mysql/* /srv/mysql \
    && cp -R /var/www/html/* /srv/html

ENTRYPOINT ["/root/init.sh"]
