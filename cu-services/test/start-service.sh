#!/bin/bash

export ENV_FILE="/etc/environment"
# Ajout des variables d'environnement
export CU_USER=$1
export CU_PASSWORD=$2
export CU_REST_IP=$3	
export CU_DATABASE_NAME=$4
export TOMCAT_HOME=/cloudunit/appconf
export JAVA_HOME=/cloudunit/java/$5

pid1=0
pid2=0

term_handler() {
  if [ $pid1 -ne 0 ]; then
    /cloudunit/scripts/cu-stop.sh $JAVA_HOME
    wait "$pid1"
  fi
  if [ $pid2 -ne 0 ]; then
    kill -s 15 "$pid2"
    wait "$pid2"
  fi	
  exit 42; 
}

trap 'kill ${!}; term_handler' SIGTERM

if [ ! -f /init-service-ok ]; then

	# variable signalant au manager quels scripts lancer
	step=start

	#################
	# PREMIER APPEL #
	#################
	echo "Start Services and configure password for $1" 

	# Transforme les variables en variables d'environnements
	echo  "CU_USER=$CU_USER" >> $ENV_FILE
	echo  "CU_PASSWORD=$CU_PASSWORD" >> $ENV_FILE
	echo  "CU_REST_IP=$CU_REST_IP" >> $ENV_FILE
	echo  "CU_DATABASE_NAME=$CU_DATABASE_NAME" >> $ENV_FILE
	echo  "JAVA_HOME=$JAVA_HOME" >> $ENV_FILE
	echo  "CATALINA_HOME=$TOMCAT_HOME" >> $ENV_FILE

	# Ajout de l'utilisateur et modif du home directory
	useradd $1 && echo "$CU_USER:$CU_PASSWORD" | chpasswd && echo "root:$CU_PASSWORD" | chpasswd

	# GENERATION CLES SSH POUR LIEN AVEC MODULES
	ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
	mkdir -p $CU_USER_HOME/.ssh
	cp /root/.ssh/id_rsa.pub $CU_USER_HOME/.ssh
	cp /root/.ssh/id_rsa $CU_USER_HOME/.ssh
	cp /root/.bashrc $CU_USER_HOME
	cp /root/.profile $CU_USER_HOME

	# Affection du homedirectory à l'utilisateur unix
	usermod -d $CU_USER_HOME $CU_USER

	# Ajout du Shell à l'utilisateur
	usermod -s /bin/bash $CU_USER

	# mv /tomcat $TOMCAT_HOME
	rm -rf $TOMCAT_HOME/webapps/ROOT $TOMCAT_HOME/webapps/examples $TOMCAT_HOME/webapps/docs

	# ajout des credentials pour tomcat
	sed -i -e'/<tomcat-users>/a\<user username=\"'$CU_USER'\" password=\"'$CU_PASSWORD'\" roles=\"manager-gui,manager-status,manager-script,manager-jmx\"/>' $TOMCAT_HOME/conf/tomcat-users.xml

	# Le montage /cloudunit n'appartient qu'à l'utilisateur créé
	chown -R $CU_USER:$CU_USER /cloudunit

	# Fin initialisation
	touch /init-service-ok


else
        #################
        # SECOND APPEL  #
        #################
        # purge des logs
        rm -rf /cloudunit/appconf/logs/*

        # variable signalant au manager quels scripts lancer
        step=restart

        # Redémarrage de openssh et tomcat
        echo "restarting"
        chown -R $1:$1 /cloudunit
fi


# Lancement de ssh et tomcat
su - $CU_USER -c "/cloudunit/scripts/cu-start.sh" 
/usr/sbin/sshd

# Attente du démarrage du processus sshd pour confirmer au manager
until [ "`nc -z localhost 22 && echo $?`" -eq "0" ];
do	
	echo "\nWaiting for sshd process to start"
	sleep 1
done

RETURN=1
until [ "$RETURN" -eq "0" ];
do
        echo "\nWaiting for tomcat to start"
	grep 'org.apache.catalina.startup.Catalina.start Server startup in' /cloudunit/appconf/logs/catalina.out
	RETURN=$?
	sleep 1
done

# ENVOIE DE REST AU MANAGER
/cloudunit/java/jdk1.7.0_55/bin/java -jar /cloudunit/tools/cloudunitAgent-1.0-SNAPSHOT.jar SERVER cuplatform_mysql_1.mysql.cloud.unit $CU_DATABASE_NAME $CU_USER START

pid1=`pidof sshd | awk '{print $2}'`
pid2=`pidof java`

echo $pid1 > /pids.txt
echo $pid2 >> /pids.txt

# wait indefinetely
while true
do
  tail -f /dev/null & wait ${!}
done


