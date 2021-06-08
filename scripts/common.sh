#!/bin/bash

[ "$DEBUG" == 'true' ] && set -x;

cmd=$1

if [ "$cmd" = "create" ]; then
  echo "Creating directories..."
  ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $AZ_USER@$AZ_VM_LOGIN_IP 'sudo mkdir -p /webap/DEM-Server; sudo chmod 777 /webap/DEM-Server'
  exit
fi

if [ "$cmd" = "build" ]; then
  ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $AZ_USER@$AZ_VM_LOGIN_IP '
  echo "Executing build command"
  cd /webap/DEM-Server/
  rm -rf *.enc
  sudo cp /common_cred/DataSDK-2ffc438a9b47.json  /webapps/DEM-Server/
  sudo cp /common_cred/credentials.py /webapps/DEM-Server/dem
  git status
  echo -e "\n"
  git branch
  echo -e "\n"
  git diff
  echo -e "\n"
  docker-compose down
  echo -e "\n"
  docker-compose build'
  exit
fi

if [ "$cmd" = "test" ]; then
  ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $AZ_USER@$AZ_VM_LOGIN_IP '
  echo "Executing test command"
  cd /webap/DEM-Server/
  source newenv/bin/activate
  python manage.py test dem
  deactivate'
  exit
fi

if [ "$cmd" = "run" ]; then
  ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $AZ_USER@$AZ_VM_LOGIN_IP '
  echo "Executing run command"
  cd /webap/DEM-Server/
  docker-compose up -d --no-build'
  exit
fi

if [ "$cmd" = "rebuild" ]; then
  ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $AZ_USER@$AZ_VM_LOGIN_IP '
  echo -e "\n Executing rebuild docker compose down/up commands \n"
  cd /webap/DEM-Server/
  rm -rf *.enc
  sudo cp /common_cred/DataSDK-2ffc438a9b47.json  /webap/DEM-Server/
  sudo cp /common_cred/credentials.py /webap/DEM-Server/dem
  git status
  echo -e "\n"
  git branch
  echo -e "\n"
  git diff
  echo -e "\n"
  docker-compose down
  echo -e "\n"
  docker images
  echo -e "\n"
  docker ps
  echo -e "\n"
  docker-compose up --build
  echo -e "\n"
#  docker rm $(docker ps -aq)
#  echo -e "\n"
  docker image prune -f
  echo -e "\n"
  docker images
  echo -e "\n"
  docker ps
  echo -e "\n"
  docker ps'
  exit
fi

if [ "$cmd" = "remove_C_I_and_rebuild" ]; then
  ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $AZ_USER@$AZ_VM_LOGIN_IP '
  echo -e "\n Executing rebuild docker compose down/up commands \n"
  cd /webap/DEM-Server/
  rm -rf *.enc
  sudo cp /common_cred/DataSDK-2ffc438a9b47.json  /webap/DEM-Server/
  sudo cp /common_cred/credentials.py /webap/DEM-Server/dem
  git status
  echo -e "\n"
  git branch
  echo -e "\n"
  git diff
  echo -e "\n"
  docker-compose down
  echo -e "\n"
  docker rmi $(sudo docker images -aq) --force
  echo -e "\n"
  docker images
  echo -e "\n"
  docker ps
  echo -e "\n"
  docker image prune -a -f
  echo -e "\n"
  docker-compose up -d --build
  echo -e "\n"'
  exit
fi

if [ "$cmd" = "restart" ]; then
  ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $AZ_USER@$AZ_VM_LOGIN_IP '
  echo "Executing restart command"
  cd /webap/DEM-Server/
  echo -e "\n"
  docker ps
  echo -e "\n"
  docker-compose restart
  echo -e "\n"
  docker ps'
  exit
fi

if [ "$cmd" = "m_create" ]; then
  echo "Executing migration create command"
  migration create
  exit
fi

if [ "$cmd" = "m_drop" ]; then
  echo "/n/n/n Executing migration drop command to remove migrations /n/n/n"
  cd /webap/DEM-Server/dem/ && sudo rm -r migrations
  cd /webap/DEM-Server/dem_actor && sudo  rm -r migrations
  cd /webap/DEM-Server/dem_policy && sudo rm -r migrations
  cd /webap/DEM-Server/demfcm && sudo rm -r migrations
  cd /webap/DEM-Server/users && sudo rm -r migrations
  exit
fi

if [ "$cmd" = "push" ]; then
  echo "Creating docker image and pushing to datacultr docker hub..."
  ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $AZ_USER@$AZ_VM_LOGIN_IP bash -c "export DOCKER_PASSWORD=$DOCKER_PASSWORD; export DOCKER_USERNAME=$DOCKER_USERNAME;
      export DOCKER_REPO=$DOCKER_REPO; export DOCKER_ACCOUNT=$DOCKER_ACCOUNT; export TRAVIS_COMMIT=$TRAVIS_COMMIT; export TRAVIS_BUILD_NUMBER=$TRAVIS_BUILD_NUMBER; export DOCKER_TOKEN=$DOCKER_TOKEN"'
  docker login -u "$DOCKER_USERNAME" -p "$DOCKER_TOKEN"
  echo -e "\n\n"
  cd /webap/DEM-Server/
  echo -e "\n\n"
  docker images
  echo -e "\n\n"
  docker tag dem_server:latest "$DOCKER_ACCOUNT"/"$DOCKER_REPO":travis-dem_server-"$TRAVIS_BUILD_NUMBER"
  echo -e "\n\n"
  docker tag demserver_knox_app:latest "$DOCKER_ACCOUNT"/"$DOCKER_REPO":travis-demserver_knox_app-"$TRAVIS_BUILD_NUMBER"
  echo -e "\n\n"
  docker tag demserver_knox_oauth_reseller:latest "$DOCKER_ACCOUNT"/"$DOCKER_REPO":travis-demserver_knox_oauth_reseller-"$TRAVIS_BUILD_NUMBER"
  echo -e "\n\n"
  docker tag demserver_knox_oauth_customer:latest "$DOCKER_ACCOUNT"/"$DOCKER_REPO":travis-demserver_knox_oauth_customer-"$TRAVIS_BUILD_NUMBER"
  echo -e "\n\n"
  docker login -u "$DOCKER_USERNAME" -p "$DOCKER_TOKEN"
  echo -e "\n\n"
  docker push "$DOCKER_ACCOUNT"/"$DOCKER_REPO":travis-dem_server-"$TRAVIS_BUILD_NUMBER"
  echo -e "\n\n"
  docker push "$DOCKER_ACCOUNT"/"$DOCKER_REPO":travis-demserver_knox_app-"$TRAVIS_BUILD_NUMBER"
  echo -e "\n\n"
  docker push "$DOCKER_ACCOUNT"/"$DOCKER_REPO":travis-demserver_knox_oauth_reseller-"$TRAVIS_BUILD_NUMBER"
  echo -e "\n\n"
  docker push "$DOCKER_ACCOUNT"/"$DOCKER_REPO":travis-demserver_knox_oauth_customer-"$TRAVIS_BUILD_NUMBER"
  echo -e "\n\n"
  docker image prune -f
  echo -e "\n\n"
  docker images
  echo -e "\n\n"
  docker ps'
  exit
fi

#if [ "$cmd" = "checkout" ]; then
#  echo "Performing git checkout..."
#  sudo su
#  mkdir /webapp
#  cd /webapp/ && \
##  git clone https://$GIT_USERNAME:$GIT_PASSWORD@github.com/$GIT_ACCOUNT/DEM-Server.git --single-branch travis-DEM-Server && \
#  git clone git@github.com-repo-Invideo_task_aws:Shashankreddysunkara/Invideo_task_aws.git
#  git checkout travis-DEM-Server && \
#  git status && /n/n
#  git diff && /n/n
#  git branch && " \n Current path of working dir is " pwd && \
#  #git pull origin travis-DEM-Server
#  exit
#fi
#
#echo "No command specified"

if [ "$cmd" = "checkout" ]; then
  echo "Performing git checkout..."
  cd cd /home/ubuntu/sunny/
  git clone git@github.com-repo-Invideo_task_aws:Shashankreddysunkara/Invideo_task_aws.git
#  git checkout travis-DEM-Server && \
#  git status && /n/n
#  git diff && /n/n
#  git branch && " \n Current path of working dir is " pwd && \
#  #git pull origin travis-DEM-Server
#  exit
else
  git pull origin main
fi

echo "No command specified"