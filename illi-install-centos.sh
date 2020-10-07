#!/bin/bash

configuracao_inicial() {
	yum update && \
	yum remove httpd php* mysql* maria* && \
	yum install cronie wget && \
	wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm  && rpm -Uvh epel-release-latest-7.noarch.rpm && \
	yum install nano postfix ntp crudini htop mlocate yum-priorities yum-utils iperf logrotate bmon netcat mtr && \
	echo "export VISUAL=\"nano\"" >> ~/.bash_profile && \
	echo "export EDITOR=\"nano\"" >> ~/.bash_profile && \
	crudini --set /etc/yum.repos.d/epel.repo epel priority 10;
}

configuracao_horario() {
	timedatectl set-timezone America/Sao_Paulo && \
	systemctl stop ntpd.service ; ntpdate a.ntp.br ; ntpdate b.ntp.br ; systemctl start ntpd.service && \	
	hwclock --systohc;
}

configuracao_idioma() {
	localectl set-locale LANG=pt_br.UTF-8;
}

configuranca_seguranca() {
	sed -i -e "s/.*SELINUX=enforcing.*/SELINUX=disabled/" /etc/sysconfig/selinux && \
	sed -i -e "s/.*SELINUX=enforcing.*/SELINUX=disabled/" /etc/selinux/config && \
	systemctl disable firewalld && \
	systemctl stop firewalld;

}

configuracao_dw() {
	wget https://www.dwservice.net/download/dwagent_x86.sh && \
	chmod +x dwagent_x86.sh && \
	./dwagent_x86.sh;
}

instalacao_mysql() {
	yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm && \
	percona-release setup ps80 && \
	yum install percona-server-server && \
	systemctl start mysql.service && \
	cat /var/log/mysqld.log  | grep "temporary password is generated" && \
	/usr/bin/mysql_secure_installation && \
	mysql -u root -p -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'" && \
	mysql -u root -p -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'" && \
	mysql -u root -p -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'" && \
	crudini --set /etc/my.cnf mysqld sql_mode STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION && \
	crudini --set /etc/my.cnf mysqld max_allowed_packet 64M && \
	crudini --set /etc/my.cnf mysqld bind-address 0.0.0.0 && \
	crudini --set /etc/my.cnf mysqld skip-external-locking 1 && \		
	crudini --set /etc/my.cnf mysqld skip-host-cache 1 && \
	crudini --set /etc/my.cnf mysqld skip-name-resolve 1 && \
	crudini --set /etc/my.cnf mysqld performance_schema 1 && \
	crudini --set /etc/my.cnf mysqldump quick 1 && \
	crudini --set /etc/my.cnf mysqldump quote-names 1 && \
	crudini --set /etc/my.cnf mysqldump max-allowed-packet 128M && \
	sed -i -e "s/.*skip-external-locking.*/skip-external-locking/" /etc/my.cnf && \
	sed -i -e "s/.*skip-host-cache.*/skip-host-cache/" /etc/my.cnf && \
	sed -i -e "s/.*skip-name-resolve.*/skip-name-resolve/" /etc/my.cnf && \
	sed -i -e "s/.*performance_schema.*/performance_schema/" /etc/my.cnf && \
	sed -i -e "s/.*quick.*/quick/" /etc/my.cnf && \
	sed -i -e "s/.*quote-names.*/quote-names/" /etc/my.cnf && \
	systemctl stop mysql.service && \
	systemctl start mysql.service && \
	mysql -u root -p mysql -e "UPDATE user SET Host = '%' WHERE user.Host  = 'localhost' AND user.User  = 'root' LIMIT 1" && \
	mysql -u root -p mysql -e "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '\!@A7v400mx';" && \
	systemctl stop mysql.service && \
	systemctl start mysql.service;

}

instalacao_nginx_php() {
	wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm  && rpm -Uvh remi-release-7.rpm && \
	crudini --set /etc/yum.repos.d/remi-php73.repo remi-php73 enabled 1 && \
	crudini --set /etc/yum.repos.d/remi-php73.repo remi-php73 priority 10 && \
	yum clean all && \
	yum install nginx && \
	yum install php-fpm php-cli php-mysqlnd php-gd php-curl php-imap php-zip php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-pdo-dblib php-snmp php-soap php-tidy php-sqlite3 php-opcache && \
	yum install php-pecl-apc php-pecl-mcrypt && \
	systemctl enable nginx.service && \
	systemctl enable php-fpm && \
	systemctl start nginx.service && \
	systemctl stop php-fpm.service;

}

configuracao_nginx() {
	mv /var/www /var/www.old && \
	ln -s /usr/share/nginx/html /var/www && \
	echo ":)" > /usr/share/nginx/html/index.html && \
	mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.sample && \
	cd nginx/ && \
	mv nginx.conf /etc/nginx/ && \
	mv fastcgi_params.conf /etc/nginx/ && \
	mv proxy.conf /etc/nginx/default.d/ && \
	mv default.conf /etc/nginx/default.d/ && \
	mv php.conf /etc/nginx/default.d/ && \
	mv php-sincronismo.conf /etc/nginx/default.d/ && \
	cd .. ;

}

configuracao_php(){
	cp -f /etc/php.ini /etc/php.ini.sample && \
	cp -f /etc/php-fpm.conf /etc/php-fpm.conf.sample && \
	sed -i -e "s/.*cgi.fix_pathinfo =.*/cgi.fix_pathinfo = 0/" /etc/php.ini && \
	sed -i -e "s/.*date.timezone =.*/date.timezone = America\/Sao_Paulo/" /etc/php.ini && \
	sed -i -e "s/.*upload_max_filesize =.*/upload_max_filesize = 500M/" /etc/php.ini && \
	sed -i -e "s/.*post_max_size =.*/post_max_size = 500M/" /etc/php.ini && \
	sed -i -e "s/.*memory_limit =.*/memory_limit = 1024M/" /etc/php.ini && \
	sed -i -e "s/.*emergency_restart_threshold =.*/emergency_restart_threshold = 3/" /etc/php-fpm.conf && \
	sed -i -e "s/.*emergency_restart_interval =.*/emergency_restart_interval = 1m/" /etc/php-fpm.conf && \
	sed -i -e "s/.*process_control_timeout =.*/process_control_timeout = 5s/" /etc/php-fpm.conf && \
	sed -i -e "s/.*opcache.enable=.*/opcache.enable=1/" /etc/php.d/10-opcache.ini && \
	sed -i -e "s/.*opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php.d/10-opcache.ini && \
	sed -i -e "s/.*opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/" /etc/php.d/10-opcache.ini && \
	sed -i -e "s/.*opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php.d/10-opcache.ini && \
	sed -i -e "s/.*opcache.save_comments=.*/opcache.save_comments=1/" /etc/php.d/10-opcache.ini && \
	sed -i -e "s/.*opcache.revalidate_freq=.*/opcache.revalidate_freq=1/" /etc/php.d/10-opcache.ini && \
	mkdir -p /var/lib/php/sessions && \
	chmod 777 /var/lib/php/sessions && \
	echo "" > /etc/php-fpm.d/www.conf && \
	cd php/ && \
	mv illi.conf /etc/php-fpm.d/ ;
}

instalacao_git(){
	yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel && \
	yum install gcc perl-ExtUtils-MakeMaker && \
	yum remove git && \
	cd /usr/src && \
	wget https://www.kernel.org/pub/software/scm/git/git-2.21.0.tar.gz && \
	tar zxvf git-2.21.0.tar.gz && \
	cd git-2.21.0 && \
	make prefix=/usr/local/git all && \
	make prefix=/usr/local/git install && \
	echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc && \
	ln -s /usr/local/git/bin/git /usr/bin/git && \
	ln -s /usr/local/git/bin/git /usr/sbin/git && \
	source /etc/bashrc; 

}

clonar_repositorio(){
	cd /var/www && \
	git clone https://git.pdv.moda/publico/standalone.git illi && \
	cd illi && \
	chmod +x *.sh && \
	chown -Rf apache:apache . ;
}

habilitar_illi_nginx() {
	cd illi_nginx/ && \
	mv illi.conf /etc/nginx/conf.d/ && \
	systemctl stop nginx.service && systemctl stop php-fpm.service && systemctl start php-fpm.service && systemctl start nginx.service;

}

configuracao_database_illi(){
	cd /var/www/illi && \
	touch database && \
	chown -Rf apache:apache database && \
	echo "Bem vindo ao ILLI!" && \
	echo " " && \
	echo "A partir de agora estaremos configurando nosso banco de dados." && \
	read -p "Insira o endereço do servidor (Padrão: localhost): " endereco && \
	read -p "Insira o usuário do banco de dados (Padrão: root): " usuario && \
	read -p "Insira o alias da senha: " alias_senha && \
	read -p "Insira o nome do banco de dados (Padrão: illi): " nome_bd && \
	echo "$endereco,$usuario,$alias_senha,$nome_bd" >> database && \
	echo "/usr/" >> database && \
	echo " " && \
	echo "Configuração realizada com sucesso!";
}

instalacao_illi() {

	cd /var/www/illi && \
	echo " " && \
	read -p "Insira a chave de registro do servidor: " licenca && \
	echo " " && \
	chown -Rf apache:apache . && chmod +x *.sh && \
	/usr/bin/sudo -u apache /usr/bin/php index.php illi registrar $licenca && \
	/usr/bin/sudo -u apache /usr/bin/php index.php instalacao shell && \
	/usr/bin/sudo -u apache /usr/bin/php index.php atualizacao shell && \
	git clean -df && chown -Rf apache:apache . && chmod +x *.sh
	echo " " && \
	echo "Instalação do illi realizada com sucesso!";

}

configuracao_inicial
configuracao_horario
configuracao_idioma
configuracao_seguranca
configuracao_dw
instalacao_mysql
instalacao_nginx_php
configuracao_nginx
configuracao_php
instalacao_git
clonar_repositorio
habilitar_illi_nginx
configuracao_database_illi
instalacao_illi