FROM centos:7
LABEL maintainer="Vlad Grigorescu <grigorescu@gmail.com>"

RUN yum install -y epel-release
RUN yum install -y kernel-devel ruby-devel rubygems rpm-build gcc make jemalloc jemalloc-devel git cmake cmake28 gcc-c++ flex bison libpcap-devel openssl-devel python-devel swig file-devel gperftools-devel libmaxminddb-devel python2-pip which
RUN gem install fpm
RUN pip install --upgrade pip
RUN pip install zkg

