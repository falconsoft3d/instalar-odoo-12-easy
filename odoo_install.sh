#!/bin/bash
#Creamos el usuario y grupo de sistema 'odoo':
sudo adduser --system --quiet --shell=/bin/bash --home=/opt/odoo --gecos 'odoo' --group odoo
#Creamos en directorio en donde se almacenará el archivo de configuración y log de odoo:
sudo mkdir /etc/odoo && sudo mkdir /var/log/odoo
# Agregamos los repositorios APT de postgres
echo deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main >> /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
# Instalamos esta librería aparte, ya que se pone mariquita si la instalamos junto a las demás
sudo apt-get install libsasl2-dev
# Instalamos Postgres y librerías base del sistema:
sudo apt-get update && sudo apt-get install postgresql postgresql-server-dev-10 build-essential python3-pil python3-lxml python-ldap3 python3-dev python3-pip python3-setuptools npm nodejs git gdebi libldap2-dev libxml2-dev libxslt1-dev libjpeg-dev -y
#Descargamos odoo version 12 desde git:
sudo git clone --depth 1 --branch 12.0 https://github.com/odoo/odoo /opt/odoo/server
#Damos permiso al directorio que contiene los archivos de OdooERP  e instalamos las dependencias de python3:
sudo chown odoo:odoo /opt/odoo/ -R && sudo chown odoo:odoo /var/log/odoo/ -R && sudo pip3 install -r /opt/odoo/server/requirements.txt
#Usamos npm, que es el gestor de paquetes Node.js para instalar less:
sudo npm install -g less less-plugin-clean-css -y && sudo ln -s /usr/bin/nodejs /usr/bin/node
#Descargamos dependencias e instalar wkhtmltopdf para generar PDF en odoo
sudo apt install xfonts-base xfonts-75dpi -y
cd /tmp
wget http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb && sudo dpkg -i libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.xenial_amd64.deb && sudo dpkg -i wkhtmltox_0.12.5-1.xenial_amd64.deb
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin/
sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin/
#Creamos un usuario 'odoo' para la base de datos:
sudo su - postgres -c "createuser -s odoo"
#Creamos la configuracion de Odoo:
sudo su - odoo -c "/opt/odoo/server/odoo-bin --addons-path=/opt/odoo/server/addons -s --stop-after-init"
#Creamos el archivo de configuracion de odoo:
sudo mv /opt/odoo/.odoorc /etc/odoo/odoo.conf
#Agregamos los siguientes parámetros al archivo de configuración de odoo:
sudo sed -i "s,^\(logfile = \).*,\1"/var/log/odoo/odoo-server.log"," /etc/odoo/odoo.conf
# sudo sed -i "s,^\(logrotate = \).*,\1"True"," /etc/odoo/odoo.conf
#sudo sed -i "s,^\(proxy_mode = \).*,\1"True"," /etc/odoo/odoo.conf
#Creamos el archivo de inicio del servicio de Odoo:
sudo cp /opt/odoo/server/debian/init /etc/init.d/odoo && sudo chmod +x /etc/init.d/odoo
sudo ln -s /opt/odoo/server/odoo-bin /usr/bin/odoo
update-rc.d odoo defaults
sudo service odoo start
# Para que postgres se inicie automáticamente
update-rc.d postgresql enable
