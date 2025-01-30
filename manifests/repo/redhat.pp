# Configure a yum repo for RedHat-based systems
#
# === Parameters
#
# [*yum_repo*]
#   Class name of the repo under ::yum::repo
#

class php::repo::redhat (
  String[1] $yum_repo = 'remi_php56',
) {
  $releasever = $facts['os']['name'] ? {
    /(?i:Amazon)/ => '6',
    default       => '$releasever',  # Yum var
  }

  $basearch = $facts['architecture'] ? {
    default     => '$basearch',  # Yum var
  }

  yumrepo { 'remi':
    descr      => 'Remi\'s RPM repository for Enterprise Linux $releasever - $basearch',
    mirrorlist => "https://rpms.remirepo.net/enterprise/${releasever}/remi/${basearch}/mirror",
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => 'https://rpms.remirepo.net/RPM-GPG-KEY-remi',
    priority   => 1,
  }

if (! ($facts['os']['name'] in ['AlmaLinux','Redhat'])) and ($facts['distro']['major'] in ['8','9'])  {
  yumrepo { 'remi-php56':
    descr      => 'Remi\'s PHP 5.6 RPM repository for Enterprise Linux $releasever - $basearch',
    mirrorlist => "https://rpms.remirepo.net/enterprise/${releasever}/php56/${basearch}/mirror",
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => 'https://rpms.remirepo.net/RPM-GPG-KEY-remi2023',
    priority   => 1,
  }
}
}
