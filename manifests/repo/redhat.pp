# Configure a yum repo for RedHat-based systems
#
# === Parameters
#
# [*version*]
#   Dotted PHP version. Default: $php::globals::globals_php_version
#

class php::repo::redhat (
  Pattern[/^\d\.\d$/] $version = $php::globals::globals_php_version,
) {

  $version_nodot = $version.delete('.')
  $releasever    = $facts['os']['name'] ? {
    /(?i:Amazon)/ => '6',
    default       => '$releasever',  # Yum var
  }

  yumrepo { 'remi':
    descr      => 'Remi\'s RPM repository for Enterprise Linux $releasever - $basearch',
    mirrorlist => "https://rpms.remirepo.net/enterprise/${releasever}/remi/mirror",
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => 'https://rpms.remirepo.net/RPM-GPG-KEY-remi',
    priority   => 1,
  }

  yumrepo { "remi-php${version_nodot}":
    descr      => "Remi's PHP ${version} RPM repository for Enterprise Linux \$releasever - \$basearch",
    mirrorlist => "https://rpms.remirepo.net/enterprise/${releasever}/php${version_nodot}/mirror",
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => 'https://rpms.remirepo.net/RPM-GPG-KEY-remi',
    priority   => 1,
  }
}
