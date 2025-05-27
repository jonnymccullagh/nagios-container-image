FROM ubuntu:noble-20240904.1

ARG NAGIOS_VERSION=4.4.6-4ubuntu0.24.04.1
ARG NAGIOSGRAPH_VERSION=1.5.2

RUN apt-get update && \
    apt-get upgrade -y \
    && apt-get install -y \
    ca-certificates \
    git vim-tiny telnet curl \
    gcc wget \
    sudo \
    nagios4=$NAGIOS_VERSION \
    libwww-perl libxml-rss-perl \
    build-essential rrdtool librrds-perl libgd-perl \
    php libapache2-mod-php \
    libnet-snmp-perl libsnmp-base libtalloc2 libtdb1 libwbclient0 snmp whois mrtg libcgi-pm-perl libnagios-object-perl nagios-plugins-contrib \
    librrds-perl libgd-gd2-perl \
    monitoring-plugins

COPY ./config/nagios/commands.cfg /etc/nagios4/objects/commands.cfg
COPY ./config/nagios/contacts.cfg /etc/nagios4/objects/contacts.cfg
COPY ./config/nagios/localhost.cfg /etc/nagios4/objects/conf.d/localhost.cfg
COPY ./config/nagios/extracommands.cfg /etc/nagios4/objects/extracommands.cfg
COPY ./config/nagios/nagios.cfg /etc/nagios4/nagios.cfg
COPY ./config/nagios/templates.cfg /etc/nagios4/templates.cfg
COPY ./config/nagios/timeperiods.cfg /etc/nagios4/timeperiods.cfg
COPY ./config/nagiosgraph/nagiosgraph.conf /etc/nagiosgraph/nagiosgraph.conf
COPY ./config/apache/htpasswd /etc/nagios4/htpasswd
COPY ./config/apache/nagios4-cgi.conf /etc/apache2/conf-enabled/nagios4-cgi.conf
COPY ./tmp/nagiosgraph-$NAGIOSGRAPH_VERSION.tar.gz /tmp
COPY ./config/extraplugins /usr/lib/nagios/plugins/extraplugins
RUN rm -rf /etc/nagios4/objects/localhost.cfg /etc/nagios4/objects/printer.cfg /etc/nagios4/objects/switch.cfg /etc/nagios4/objects/windows.cfg
RUN ls /etc/nagios4
RUN ls /etc/nagios4/objects
RUN ln -s /usr/sbin/nagios4 /usr/sbin/nagios
RUN ln -s /etc/nagios4 /etc/nagios
RUN ln -s /etc/nagios4 /etc/nagios3
RUN cd /tmp && tar -xvzf nagiosgraph-$NAGIOSGRAPH_VERSION.tar.gz && cd nagiosgraph-$NAGIOSGRAPH_VERSION && ./install.pl --layout debian 
RUN mkdir -p /var/spool/nagios/checkresults
RUN chown -R nagios:nagios /var/spool/nagios/checkresults
RUN chown -R www-data:www-data /usr/lib/cgi-bin/nagiosgraph
RUN cp -R /etc/nagios4/stylesheets /usr/share/nagios4/htdocs

RUN /usr/sbin/nagios4 -v /etc/nagios4/nagios.cfg
COPY entrypoint.sh /usr/local/bin

RUN sudo a2enmod auth_digest authz_groupfile cgi

RUN chmod +x /usr/local/bin/entrypoint.sh && \
    update-ca-certificates && \
    apt-get clean all -y 

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
