sudo yum install -y epel-release nginx wget unzip lsof ipset

cd /etc/nginx
sudo mv nginx.conf nginx.conf.backup
sudo wget https://raw.githubusercontent.com/amansin0504/aws-3tier-app-tfm/main/nginx.conf
sudo sed -i -E 's/appnlbaddress_here/${appnlb}/g' ./nginx.conf

sudo systemctl restart nginx
sudo systemctl enable nginx
