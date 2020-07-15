# Configure a yum repo for RedHat-based systems
#
# === Parameters
# To define a particular version of php, set the global php version
#
# [*yum_repo*]
#   Class name of the repo under ::yum::repo
#

class php::repo::redhat {
  $releasever = $facts['os']['name'] ? {
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

  if($::php::globals::php_version == undef) {
    $version_real = '5.6'
  } else {
    $version_real = $::php::globals::php_version
  }

  if ($version_real == '5.5') {
    fail('PHP 5.5 is no longer available for download')
  }
  assert_type(Pattern[/^\d\.\d/], $version_real)

  $version_repo = $version_real ? {
    '5.4' => '54',
    '5.6' => '56',
    '7.0' => '70',
    '7.1' => '71',
    '7.2' => '72',
    '7.3' => '73',
  }

  yumrepo { "remi-php${version_repo}":
    ensure     => 'present',
    descr      => "Remi\'s PHP ${version_real} RPM repository for Enterprise Linux \$releasever - \$basearch",
    enabled    => '1',
    gpgcheck   => '1',
    gpgkey     => 'https://rpms.remirepo.net/RPM-GPG-KEY-remi',
    mirrorlist => "http://cdn.remirepo.net/enterprise/${releasever}/php${version_repo}/mirror",
  }
}
