#!/bin/sh 

user=ubuntu
pem_path=../keys/Web_SP.pem
dockergit_v2_path=scripts/Install_Docker_Git_2.sh
up_jenkins_path=scripts/up_Jenkins.sh
scripts_path=scripts

echo "################################################################## "
echo "#                       Terraform init                           # "
echo "################################################################## "
echo " "
sleep 1

docker run -v $PWD:/data --workdir=/data -i -t hashicorp/terraform:light init

echo "################################################################## "
echo "#                       Terraform apply                          # "
echo "################################################################## "
echo " "
sleep 1

docker run -v $PWD:/data --workdir=/data -i -t hashicorp/terraform:light apply -auto-approve


echo " "
echo "################################################################## "
echo "#             sent the public_dns to var and file                # "
echo "################################################################## "
sleep 1
public_dns=`terraform output instance_public_dns` 
public_dns2=`docker run -v $PWD:/data --workdir=/data -i -t hashicorp/terraform:light output instance_public_dns`  
docker run -v $PWD:/data --workdir=/data -i -t hashicorp/terraform:light output instance_public_dns > public_dns3.txt  
echo " "

echo "################################################################## "
echo "#             showing the var content public_dns                 #"
echo "################################################################## "
echo " "
echo $public_dns
echo " "


echo " "
echo "*** Wait a moment, Server starting ***"
echo " "

sleep 25

echo "################################################################## "
echo "#             sending the key to known hosts                     # "
echo "################################################################## "
echo " "
ssh-keyscan -T 240 $public_dns >> ~/.ssh/known_hosts 


echo " "
echo "################################################################## "
echo "#                  change permission                             # "
echo "################################################################## "
echo " "
sleep 1
scp -i $pem_path $scripts_path/permission.sh $user@$public_dns:

sleep 1
ssh -i $pem_path $user@$public_dns './permission.sh'

echo "################################################################## "
echo "#               copy the script up_Jenkins                       # "
echo "################################################################## "
echo " "
sleep 1

scp -i $pem_path $up_jenkins_path $user@$public_dns:

echo "################################################################## "
echo "#              Start Script Container Jenkins                    # "
echo "################################################################## "
echo " "
sleep 1

ssh -i $pem_path $user@$public_dns 'nohup ./up_Jenkins.sh &'

echo ""
echo ""
echo ""
echo "############################# "
echo ""
echo "#  :::Script Finalizado:::  #"
echo ""
echo "############################# "
echo ""
echo ""
echo "QUANTIDADE DE VEZES QUE O CONTAINER TERRAFORM FOI UTILIZADO: "
echo "--------------------------------------- "
sudo docker ps -a
sleep 1
echo ""
echo ""
echo "Containers removidos "
echo "--------------------------------------- "
docker rm $(docker ps -qa)
sudo docker ps -a
echo ""
echo ""
echo ""
echo ""
echo "PARA ACESSAR SEU NOVO SERVIDOR EXECUTE: "
echo "--------------------------------------- "
echo "ssh -i $pem_path $user@$public_dns" 
echo ""
echo ""
echo "PARA VISUALIZAR OS CONTAINERS INICIADOS EXECUTE: "
echo "--------------------------------------- "
echo "ssh -i $pem_path $user@$public_dns 'docker ps -a'" 
echo ""
echo ""
echo "PARA ACESSAR A CONSOLE DO JENKINS EXECUTE: "
echo "--------------------------------------- "
echo "$public_dns:8080"
echo ""
echo ""
echo ""
