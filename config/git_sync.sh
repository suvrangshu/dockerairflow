#!/bin/bash
#This is a script that pulls dags from a git repo
cd /usr/local/airflow/dags
git fetch origin master
#This will update all local files that are in git
git reset --hard master
#this command will catch all new dags that are pushed in git
git pull origin master

