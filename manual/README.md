# Develop Node.js Remotely using AWS infrastructure

### Prerequisite
- Key Pair - **EC2 / Network & Security / Key Pairs**
- Access Key - **IAM / Security credentials / AWS IAM credentials / Access keys**

### Create AWS Security Groups (Open Ports)
- SSH - it's recommended to have a special security group for SSH port

  <img src="media/sg-ssh.png" alt="Security Group SSH - 22 port" width="80%"/>


- HTTP,HTTPS

  <img src="media/sg-http,https.png" alt="Security Group HTTP/HTTPS - 80/443 port" width="80%"/>
  
- Node

  <img src="media/sg-node.png" alt="Security Group Node - 3000 port" width="80%"/>

### Create EC2 Virtual Machine Instance

- Name & Machine Image

  <img src="media/aws-ec2-part1.png" alt="Name & Machine Image" width="80%"/>


- Instance Type & Key Pair

  <img src="media/aws-ec2-part2.png" alt="Instance Type & Key Pair" width="80%"/>


- Network Settings & Storage

  <img src="media/aws-ec2-part3.png" alt="Network Settings & Storage" width="80%"/>


- Advanced Details / User Data

  <img src="media/aws-ec2-part4.png" alt="Advanced Details / User Data" width="80%"/>

```console
#!/bin/bash
yum update -y; yum upgrade -y

#Updates the public IP on DuckDns site
DUCKNS_SUBDOMAIN=ec2-g4share
DUCKNS_TOKEN=a98723a3-****-****-****-************
PER_BOOT_PATH=/var/lib/cloud/scripts/per-boot
printf "#\041/bin/bash\necho url=\"https://www.duckdns.org/update?domains=${DUCKNS_SUBDOMAIN}&token=${DUCKNS_TOKEN}&ip=\" | curl -k -o ${PER_BOOT_PATH}/duck.log -K - " > ${PER_BOOT_PATH}/duck-dns.sh

chmod 744 ${PER_BOOT_PATH}/duck-dns.sh
${PER_BOOT_PATH}/duck-dns.sh
```

### Configure SSH Connection on your machine (Windows 10+, Linux, MacOs)

- Copy downloaded .pem file in **~/.ssh** folder

   <img src="media/ssh-part1.png" alt=".pem file" width="80%"/>

- Add a record in **~/.ssh/config** file

     <img src="media/ssh-part2.png" alt="Configure AWS SSH Connection" width="80%"/>

  - (5) - .pem file
  - (6) - DOMAIN _defined above_
  - (7) - short name


- Connect to AWS Instance from terminal **ssh g4share.aws**

     <img src="media/ssh-part3.png" alt="Initiate SSH Connection" width="80%"/>

### Install required packages

- Open SSH Session to EC2 Instance - **ssh g4share.aws**
- Define required Variables _defined above_
```console
DUCKNS_SUBDOMAIN=ec2-g4share
DOMAIN=ec2.g4share.com
```
- Node.js
```console
sudo yum install nodejs -y
sudo npm install -g typescript
```
- Docker
```console
sudo yum install docker -y
sudo usermod -a -G docker ec2-user
newgrp docker
sudo systemctl enable docker.service
sudo systemctl start docker.service
```
- Docker Compose
```console
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose
```
- Git
```console
sudo yum install git -y
```
- Visual Studio Code Server
```console
curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER
sudo systemctl start code-server@$USER
```
- Nginx, Certbot (free SSL Certificate)
```console
sudo yum install -y nginx certbot python3-certbot-nginx
```
- NGINX PreRequirements
```console
#put your email
LETSENCTYPT_EMAIL=g4share@gmail.com 

NGINX_SITES_PATH_AVAILABLE=/etc/nginx/sites-available
NGINX_SITES_PATH_ENABLED=/etc/nginx/sites-enabled

sudo mkdir -p ${NGINX_SITES_PATH_AVAILABLE}
sudo mkdir -p ${NGINX_SITES_PATH_ENABLED}
```
- Configure NGINX
```console
cat > ~/${DOMAIN}.conf << EOT
server {
    listen 80;
    listen [::]:80;

    server_name ${DOMAIN}        www.${DOMAIN};
        
    location / {
        proxy_pass "http://127.0.0.1:8080";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
    }
}
EOT

sudo mv ~/${DOMAIN}.conf ${NGINX_SITES_PATH_AVAILABLE}/${DOMAIN}.conf
sudo ln -s ${NGINX_SITES_PATH_AVAILABLE}/${DOMAIN}.conf ${NGINX_SITES_PATH_ENABLED}/${DOMAIN}.conf
```
- Download SSL Certificate, Restart NGINX
  - Edit **/etc/nginx/nginx.conf** file 
    - Remove all **server** section
    - Add **include /etc/nginx/sites-enabled/*.conf;** line in **http** section
    
    <img src="media/nginx.png" alt="NGINX Config" width="80%"/>

  - Add SSL Certificate for SSL connection
```console
certbot --non-interactive --redirect --agree-tos --nginx -d ${DOMAIN} -m ${LETSENCTYPT_EMAIL}
```
- Download Node.js HelloWorld application
  - git clone https://github.com/johnpapa/node-hello.git
- Open Visual Studio Code https://ec2.g4share.com/
- Open project

  <img src="media/VS Code Server.png" alt="Visual Studio Code Serve" width="80%"/>


- Open Node.js application - http://ec2.g4share.com:3000
  <img src="media/Node App.png" alt="Node App" width="80%"/>

