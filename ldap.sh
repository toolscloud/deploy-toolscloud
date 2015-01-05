#!/bin/bash

install_openldap() {
  sudo apt-get -qq update && apt-get -yqq upgrade
  sudo apt-get -yqq install gcc g++ libdb-dev make groff groff-base wget ca-certificates cpp cpp-4.8 g++-4.8 gcc-4.8 libasan0 libatomic1 libc-dev-bin libc6-dev libcloog-isl4 libdb5.3-dev libgcc-4.8-dev libgmp10 libice6 libisl10 libitm1 libmpc3 libmpfr4 libquadmath0 libsm6 libstdc++-4.8-dev libtsan0 libxaw7 libxmu6 libxpm4 libxt6 linux-libc-dev manpages manpages-dev openssl psutils x11-common time libltdl-dev
  sudo wget -q -O /opt/openldap-2.4.40.tgz ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.40.tgz
  sudo tar xf /opt/openldap-2.4.40.tgz -C /opt
  sudo chmod -R 777 /opt/openldap-2.4.40/
  cd /opt/openldap-2.4.40/ && ./configure && make -s depend && make -s && make install -s
  sudo update-alternatives --install /usr/bin/slapd slapd /usr/local/libexec/slapd 1

  sudo rm /opt/openldap-2.4.40.tgz
  sudo rm -rf /opt/openldap-2.4.40/
}

configure_openldap() {
  useradd -M -u 1002 accounts
  mkdir -p /applications/var/lib/ldap
  sudo rm /usr/local/etc/openldap/slapd.conf
  sudo cp /vagrant/slapd.conf /usr/local/etc/openldap/
  su root -c /usr/local/libexec/slapd
  sudo sed '/rootpw/ d' /usr/local/etc/openldap/slapd.conf
  ldapadd -x -D "cn=admin,dc=toolscloud,dc=com" -w secret -f /vagrant/toolscloud.ldif
}

install_pla() {
  sudo apt-get -yqq install apache2 apache2-bin apache2-data libapache2-mod-php5 libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap php5-cli php5-common php5-json php5-ldap php5-readline ssl-cert phpldapadmin
}

install_openldap
configure_openldap
install_pla
