# Retrieve system package
yum install -y wget

# Install pip for python
sudo yum -y install epel-release
sudo yum -y update
sudo yum -y install python-pip
sudo pip install --upgrade pip

# Install MySQL as a backend for airflow
cd /tmp
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
sudo yum -y update
sudo yum -y install mysql-server
sudo yum install -y mysql-community-devel
cd -

sudo yum install -y MySQL-python

sudo systemctl enable mysqld.service
sudo systemctl start mysqld.service

mysql -u root -e "create database airflow ;"
mysql -u root -e "create user 'airflow'@'127.0.0.1' identified by 'airflowpass';"
mysql -u root -e "grant ALL on airflow.* to 'airflow'@'localhost' identified by 'airflowpass';"

# Set-up airflow
sudo groupadd -g 1001 airflow
sudo adduser -M -u 1001 -g 1001 airflow

# Install airflow
sudo yum -y install python-devel
sudo pip install airflow
sudo pip install airflow[mysql]

sudo mkdir /run/airflow
sudo chown -R airflow:airflow /run/airflow/

cd /tmp
wget https://raw.githubusercontent.com/apache/incubator-airflow/master/scripts/systemd/airflow-webserver.service

sudo mv airflow-webserver.service /etc/systemd/system/
sudo touch /etc/sysconfig/airflow
sudo echo "AIRFLOW_CONFIG=/airflow/airflow.cfg" >> /etc/sysconfig/airflow
sudo echo "AIRFLOW_HOME=/airflow" >> /etc/sysconfig/airflow
sudo echo "SCHEDULER_RUNS=5" >> /etc/sysconfig/airflow

sudo -u airflow bash -c '(export AIRFLOW_HOME=/airflow; airflow initdb)'

sudo systemctl enable airflow-webserver
sudo systemctl start airflow-webserver