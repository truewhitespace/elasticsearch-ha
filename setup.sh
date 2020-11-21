sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo yum install -y --enablerepo=elasticsearch elasticsearch
sudo chkconfig --add elasticsearch
sudo -i service elasticsearch start
# sudo systemctl start elasticsearch.service
echo "Installation complete"
curl -o - http://localhost:9200
