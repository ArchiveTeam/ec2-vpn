#!/bin/sh
# here be dragons
# there are so many assumptions here that you'd better read it pretty closely before you try it
old_instance=$(ec2-describe-instances | grep INSTANCE | head -n 1 | cut -f 2 -d ' ')
new_instance=$(ec2-run-instances ami-de99b99b -k celebdil -t t1.micro -g ssh -g openvpn-server | grep INSTANCE | cut -f 2 -d ' ')
sleep 10
host=$(ec2-describe-instances | grep $new_instance | cut -f 4 -d ' ')

function ssh {
    ssh -t -t -t -i ~/.ssh/id_rsa_ec2 ec2-user@$host sudo -n $1
}

ssh yum update -y yum
ssh yum update -y
ssh yum install openvpn
scp -i configure-openvpn-server.sh ec2-user@$host:.
ssh chmod u+x configure-openvpn-server.sh
ssh ./configure-openvpn-server.sh
ssh cp /etc/openvpn/openvpn-key.txt /home/ec2-user
ssh chown ec2-user.ec2-user openvpn-key.txt
scp -i ~/.ssh/id_rsa_ec2 ec2-user@$host:openvpn-key.txt ~/.ssh/openvpn-key.txt
sudo mv ~db48x/.ssh/openvpn-key.txt /etc/openvpn
chmod root.root /etc/openvpn/openvpn.txt
sudo ./configure-openvpn-client.sh $host
ec2-terminate-instance $old_instance
