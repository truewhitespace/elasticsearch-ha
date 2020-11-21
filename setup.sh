sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo yum install -y --enablerepo=elasticsearch elasticsearch
sudo chkconfig --add elasticsearch
sudo systemctl enable elasticsearch
