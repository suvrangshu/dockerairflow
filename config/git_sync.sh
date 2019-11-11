


#!/bin/bash

#This is a shell script that pulls the dag files from a git repo
#It runs every minute on a cronjob

cd /usr/local/airflow/dags
git fetch dags dev
git reset --hard dev
#this will update all local files that are on git
git pull dags dev
#this command will catch new dags that are pushed into git
