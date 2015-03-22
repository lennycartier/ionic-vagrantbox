Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

exec { 'add-nodesource-repo':
	command => "curl -sL https://deb.nodesource.com/setup | sudo bash -",
}

exec { 'apt-update':
    command => "/usr/bin/apt-get update",
    onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
}

# run apt-get upgrade
exec { 'apt-upgrade':
  command => "/usr/bin/apt-get upgrade -y",
  require => Exec['apt-update'],
}

# install nodejs
exec { 'install-nodejs': command => 'apt-get install -y nodejs', require => Exec['apt-upgrade'], }

# install cordova
exec { 'install-cordova': command => 'npm install -g cordova', require => Exec['install-nodejs'], }

# install ionic
exec { 'install-ionic': command => 'npm install -g ionic', require => Exec['install-cordova'], }

# install git
exec { 'install-git': command => 'apt-get install -y git', }

# install java and ant
exec { 'install-java-ant': command => 'apt-get install -y openjdk-7-jdk ant', }

# fixes for aapt not found
exec { 'aapt-fixes': command => 'apt-get install -y lib32stdc++6 lib32z1', require => Exec['install-java-ant'], }

# download Android SDK
exec { 'download-android-sdk': 
	command => 'wget http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz',
	onlyif => "test ! -f android-sdk_r23.0.2-linux.tgz",
	path => ['/usr/bin','/usr/sbin','/bin','/sbin'],
 }

# install Android SDK
exec { 'install-android-sdk':
	command => 'tar xzvf android-sdk_r23.0.2-linux.tgz',
	user => 'vagrant',
	require => Exec['download-android-sdk'],
	path => ['/usr/bin','/usr/sbin','/bin','/sbin'],
}

# make sure android path and JAVA_HOME are available
exec { 'android_path': 
	command => 'echo "ANDROID_HOME=~/android-sdk-linux" >> /home/vagrant/.bashrc && echo "export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64" >> /home/vagrant/.bashrc && echo "PATH=\$PATH:~/android-sdk-linux/tools:~/android-sdk-linux/platform-tools" >> /home/vagrant/.bashrc'
}

# install android-19
exec { 'android-19':
	command => 'echo "y" | android update sdk -u -t 2,21',
	user => 'vagrant',
	require => Exec['install-android-sdk'],
}

