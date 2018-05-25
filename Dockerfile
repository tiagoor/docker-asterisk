FROM centos:centos7
MAINTAINER Tor <tor@openstack.eti.br>
ENV build_date 2017-11-04
ENV build_last 2018-05-24

RUN yum update -y && \
 yum install kernel-headers gcc gcc-c++ cpp ncurses ncurses-devel libxml2 \
 libxml2-devel sqlite sqlite-devel openssl-devel newt-devel kernel-devel \
 libuuid-devel net-snmp-devel xinetd tar make git bzip2 patch libjansson-dev -y 

#ENV AUTOBUILD_UNIXTIME 1418234402

# Download asterisk.
WORKDIR /tmp/

ADD jansson-2.10.tar.gz /tmp/
WORKDIR /tmp/jansson-2.10/
RUN bash ./configure && \
  make && \
  make check && \
  make install

WORKDIR /tmp/
#RUN git clone -b 15.1 --depth 1 https://gerrit.asterisk.org/asterisk
#RUN git clone -b 15.1 --depth 1 https://github.com/asterisk/asterisk.git
# Rvn P. D*
RUN git clone -b 15.4 --depth 1 https://github.com/tiagoor/asterisk.git

WORKDIR /tmp/asterisk

# make asterisk.
ENV rebuild_date 2017-11-04
# Configure
RUN bash ./configure --libdir=/usr/lib64 1> /dev/null
# Remove the native build option
RUN make menuselect.makeopts
RUN menuselect/menuselect \
  --disable BUILD_NATIVE \
  --enable cdr_csv \
  --enable chan_sip \
  --enable res_snmp \
  --enable res_http_websocket \
  menuselect.makeopts

# Continue with a standard make.
RUN make 1> /dev/null
RUN make install 1> /dev/null
RUN make samples 1> /dev/null
WORKDIR /

# Update max number of open files.
RUN sed -i -e 's/# MAXFILES=/MAXFILES=/' /usr/sbin/safe_asterisk
# Set tty
RUN sed -i 's/TTY=9/TTY=/g' /usr/sbin/safe_asterisk
# Create and configure asterisk for running asterisk user.
RUN useradd -m asterisk -s /sbin/nologin
RUN chown asterisk:asterisk /var/run/asterisk
RUN chown -R asterisk:asterisk /etc/asterisk/
RUN chown -R asterisk:asterisk /var/{lib,log,spool}/asterisk
RUN chown -R asterisk:asterisk /usr/lib64/asterisk/

# Running asterisk with user asterisk.
CMD /usr/sbin/asterisk -f -U asterisk -G asterisk -vvvg -c
