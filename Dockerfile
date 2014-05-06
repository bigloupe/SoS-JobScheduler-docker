# Base image 
FROM centos:latest

MAINTAINER bigloupe, slashart2012@gmail.com

RUN yum -y install wget tar

RUN cd /opt; wget http://freefr.dl.sourceforge.net/project/jobscheduler/jobscheduler_linux-x64.1.6.4119.tar.gz -O jobscheduler_linux-x64.tar.gz 

RUN cd /opt; /bin/tar -zxvf jobscheduler_linux-x64.tar.gz 

# Install JDK 1.7
RUN cd /opt; wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.rpm" -O /opt/jdk-7-linux-x64.rpm

# Install in /usr/java/jdk1.7.0_51 
RUN cd /opt; rpm -Uvh /opt/jdk-7-linux-x64.rpm

RUN alternatives --install /usr/bin/java java /usr/java/jdk1.7.0_51/jre/bin/java 20000; alternatives --install /usr/bin/jar jar /usr/java/jdk1.7.0_51/bin/jar 20000; alternatives --install /usr/bin/javac javac /usr/java/jdk1.7.0_51/bin/javac 20000; alternatives --install /usr/bin/javaws javaws /usr/java/jdk1.7.0_51/jre/bin/javaws 20000; alternatives --set java /usr/java/jdk1.7.0_51/jre/bin/java; alternatives --set javaws /usr/java/jdk1.7.0_51/jre/bin/javaws; alternatives --set javac /usr/java/jdk1.7.0_51/bin/javac; alternatives --set jar /usr/java/jdk1.7.0_51/bin/jar;

# Install PostgreSQL 9.3
RUN rpm -ivh http://yum.postgresql.org/9.3/redhat/rhel-6.5-x86_64/pgdg-centos93-9.3-1.noarch.rpm
RUN yum groupinstall -y "PostgreSQL Database Server 9.3 PGDG"

USER postgres

# Create a PostgreSQL role named ``jobscheduler`` with ``jobscheduler`` as the password and
# then create a database `jobscheduler` owned by the ``jobscheduler`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER jobscheduler WITH SUPERUSER PASSWORD 'jobscheduler';" &&\
    createdb -O jobscheduler jobscheduler
    

# Expose ports : 22 for SSH & 44440 for JobScheduler Controller (Jetty)
# PostgresSQL port is not exposed 
EXPOSE 22 44440

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER root

# Install JobScheduler
ADD scheduler_install.xml /opt/jobscheduler.1.6.4119/scheduler_install.xml
RUN cd /opt/jobscheduler.1.6.4119 ;/usr/bin/java -jar jobscheduler.1.6.4119 scheduler_install.xml

# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
#CMD ["/usr/opt/jobscheduler.1.6/localhost_4444/bin/jobscheduler"]

