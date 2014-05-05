# Base image 
FROM centos

MAINTAINER bigloupe, slashart2012@gmail.com

RUN yum -y install wget

RUN cd /opt; wget http://freefr.dl.sourceforge.net/project/jobscheduler/jobscheduler_linux-x64.1.6.4119.tar.gz -O jobscheduler_linux-x64.tar.gz 

RUN cd /opt; tar -zxvf jobscheduler_linux-x64.tar.gz 

# Expose ports : 22 for SSH & 44440 for JobScheduler Controller
EXPOSE 22 44440