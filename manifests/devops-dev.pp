# ALL SCRIPT MUST BE "IDEPOTENTE"

#Basic commands:

# vagrant up : start machine
# vagrant destroy : destroy the machine
# vagrant halt : Shutdown the machine
# vagrant reload : Restart the machine
# vagrant ssh: Enters the machine
# sudo puppet apply /vagrant/manifests/web.pp : apply the configurations to the machine (must be executed inside the machine)

#type "startxfce4&" on terminal to startup the UI on Virtualbox


# Update all packages from Ubuntu machine
exec { "apt-update":
	command => "/usr/bin/apt-get update"
}

# Ui required packages
package { ["xfce4", "virtualbox-guest-dkms", "virtualbox-guest-utils", "virtualbox-guest-x11", "ubuntu-artwork"]:
	ensure => installed,
	require => Exec["apt-update"]
}

# Ui configuration
exec { "ui-config":
	command => "echo 'allowed_users=anybody' > /etc/X11/Xwrapper.config",
	path => '/bin',
	require => Package["xfce4", "virtualbox-guest-dkms", "virtualbox-guest-utils", "virtualbox-guest-x11"]
}

# Download of jdk7 and tomcat7 and MySQL
package { ["openjdk-7-jre", "tomcat7", "mysql-server"]:
	ensure => installed,
	require => Exec["apt-update", "ui-config"]
}

# Start Tomcat7
service { "tomcat7":
	ensure => running,
	enable => true,
	hasstatus => true,
	hasrestart => true,
	require => Package["tomcat7"]
}

# Start MySQL
service { "mysql":
	ensure => running,
	enable => true,
	hasstatus => true,
	hasrestart => true,
	require => Package["mysql-server"]
}

# Create database musicjungle (required to run the war)
exec { "musicjungle":
	command => "mysqladmin -uroot create musicjungle",
	unless => "mysql -u root musicjungle",
	path => "/usr/bin",
	require => Service["mysql"]
}

# War deployment on tomcat path
file { "/var/lib/tomcat7/webapps/vraptor-musicjungle.war":
	source => "/vagrant/manifests/vraptor-musicjungle.war",
	owner => tomcat7,
	group => tomcat7,
	mode => 0644,
	require => Package["tomcat7"],
	notify => Service["tomcat7"]
}

# Download Eclipse
exec { "eclipse-download":
	command => "wget -O /opt/eclipse-java-luna-SR2-linux-gtk-x86_64.tar.gz http://ftp.fau.de/eclipse/technology/epp/downloads/release/luna/SR2/eclipse-java-luna-SR2-linux-gtk-x86_64.tar.gz",
	path => "/usr/bin/"
}

# Unzip Eclipse
exec { "eclipse-unzip":
	command => "tar -zxvf eclipse-java-luna-SR2-linux-gtk-x86_64.tar.gz",
	cwd => "/opt/",
	path => "/bin/",
	require => Exec["eclipse-download"]
}

# Permission to use eclipse files
exec { "eclipse-permission":
	command => "chmod -R a+x /opt/eclipse",
	path => "/bin/",
	require => Exec["eclipse-unzip"]
}

# Link creation for Eclipse
exec { "eclipse-env-variable":
	command => "ln -s /opt/eclipse/eclipse /usr/local/bin/eclipse",
	path => "/bin/",
	require => Exec["eclipse-permission"]
}

# Permission to allow the use of the link
exec { "eclipse-env-permission":
	command => "chmod a+x /usr/local/bin/eclipse",
	path => "/bin/",
	require => Exec["eclipse-env-variable"]
}

# Remove Downloaded file
exec { "eclipse-remove-downloaded-file":
	command => "rm /opt/eclipse-java-luna-SR2-linux-gtk-x86_64.tar.gz",
	path => "/bin/",
	require => Exec["eclipse-env-permission"]
}