
#lines 1-6: takes airflow image, runs commands as root, sets AIRFLOW_HOME = /usr/local/airflow, and gets an update
FROM puckel/docker-airflow
USER root
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}
ENV FERNET_KEY=81HqDtbqAywKSOumSha3BhWNOdQ26slT6K0YaZeZyPs=
RUN apt-get update
RUN apt-get install --yes python3 && pip
RUN pip install --upgrade pip
RUN apt-get install --yes \
    vim \
    cron \
    git
RUN pip install pyodbc flask-bcrypt azure pymssql sqlalchemy psycopg2-binary apache-airflow[s3]
RUN cd ${AIRFLOW_HOME} && mkdir logs && chmod +x logs
#Copies airflow.cfg file to set airflow with SQL Database, Fernet Key
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg
#Creates dags folder and then connects them to the bitbucket repo, dev branch. Installing cron so it automatically pulls from git
RUN cd ${AIRFLOW_USER_HOME} && mkdir dags && chmod +x dags
RUN touch /var/log/cron.log
RUN apt-get update && apt-get -y install cron
#Setting permissions and security to pull dev branch from bitbucket
ADD /config/id_rsa /root/.ssh/id_rsa
ADD /config/id_rsa.pub /root/.ssh/id_rsa.pub
ADD /config/authorized_keys /root/.ssh/authorized_keys
ADD /config/known_hosts /root/.ssh/known_hosts
#Adding bitbucket repo to dags folder so they automatically sync
RUN cd ${AIRFLOW_USER_HOME}/dags && git init && git remote add dags git@bitbucket.org:saipanneerselvam/dags.git
COPY /config/git_sync.sh /root/git_sync.sh
RUN cd ~ && chmod +x git_sync.sh && ./git_sync.sh --yes
#Testing cron job and git_sync.sh so that dags folder syncs with bitbucket repo
COPY config/hello-cron /etc/cron.d/hello-cron
RUN chmod 0644 /etc/cron.d/hello-cron
RUN crontab /etc/cron.d/hello-cron
RUN touch /var/log/cron.log
RUN apt-get update && apt-get -y install cron
COPY config/git_sync /etc/cron.d/git_sync
RUN chmod 0644 /etc/cron.d/git_sync
RUN crontab /etc/cron.d/git_sync
#initializing airflow's database, cronjob
RUN airflow initdb
RUN cron start
