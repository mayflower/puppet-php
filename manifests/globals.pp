# PHP globals class
#
# === Parameters
#
# [*php_version*]
#   The version of php.
#
# [*config_root*]
#   The configuration root directory.
#
# [*fpm_pid_file*]
#   Path to pid file for fpm
#
# [*rhscl_mode*]
#   The mode specifies the specifics in paths for the various RedHat SCL environments so that the module is configured
#   correctly on their pathnames.
#
# @param flavor
#   Flavor of PHP, either 'community' or 'zend'.
#
# @param zend_creds
#   Hash of ZendPHP repo credentials; {username => '<USERNAME>', password => '<PASSWORD>'}
#

class php::globals (
  Optional[Pattern[/^(rh-)?(php)?[578](\.)?[0-9]/]] $php_version = undef,
  Optional[Stdlib::Absolutepath] $config_root                    = undef,
  Optional[Stdlib::Absolutepath] $fpm_pid_file                   = undef,
  Optional[Enum['rhscl', 'remi']] $rhscl_mode                    = undef,
  Optional[Hash] $zend_creds                                     = undef,
  Enum['community', 'zend'] $flavor                              = 'community',
) {
  if ($php_version == undef) {
    $globals_php_version = $facts['os']['name'] ? {
      'Debian' => $facts['os']['release']['major'] ? {
        '10'    => '7.3',
        '11'    => '7.4',
        '12'    => '8.2',
        default => fail("Unsupported Debian release: ${fact('os.release.major')}"),
      },
      'Ubuntu' => $facts['os']['release']['major'] ? {
        '18.04' => '7.2',
        '20.04' => '7.4',
        '22.04' => '8.1',
        '24.04' => '8.3',
        default => fail("Unsupported Ubuntu release: ${fact('os.release.major')}"),
      },
      default  => '5.x',
    }
  } else {
    $globals_php_version = $php_version
  }

  case $facts['os']['family'] {
    'Debian': {
      if $facts['os']['name'] == 'Ubuntu' {
        case $globals_php_version {
          /^[578].[0-9]/: {
            case $flavor {
              'zend': {
                $default_config_root = "/etc/php/${globals_php_version}-zend"
                $fpm_service_name = "php${globals_php_version}-zend-fpm"
                $package_prefix = "php${globals_php_version}-zend-"
              }
              default: {
                $default_config_root = "/etc/php/${globals_php_version}"
                $fpm_service_name = "php${globals_php_version}-fpm"
                $package_prefix = "php${globals_php_version}-"
              }
            }
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log = "/var/log/php${globals_php_version}-fpm.log"
            $ext_tool_enable = "/usr/sbin/phpenmod -v ${globals_php_version}"
            $ext_tool_query = "/usr/sbin/phpquery -v ${globals_php_version}"
          }
          default: {
            # Default php installation from Ubuntu official repository use the following paths until 16.04
            # For PPA please use the $php_version to override it.
            $default_config_root = '/etc/php5'
            $default_fpm_pid_file = '/var/run/php5-fpm.pid'
            $fpm_error_log = '/var/log/php5-fpm.log'
            $fpm_service_name = 'php5-fpm'
            $ext_tool_enable = '/usr/sbin/php5enmod'
            $ext_tool_query = '/usr/sbin/php5query'
            $package_prefix = 'php5-'
          }
        }
      } else {
        if $flavor == 'zend' and versioncmp($facts['os']['release']['major'], '11') > 0 {
          fail("Zend PHP is unsupported on this Debian release: ${fact('os.release.major')}")
        }
        case $globals_php_version {
          /^5\.6/,
          /^7\.[0-9]/,
          /^8\.[0-9]/: {
            case $flavor {
              'zend': {
                $default_config_root = "/etc/php/${globals_php_version}-zend"
                $fpm_service_name = "php${globals_php_version}-zend-fpm"
                $package_prefix = "php${globals_php_version}-zend-"
              }
              default: {
                $default_config_root = "/etc/php/${globals_php_version}"
                $fpm_service_name = "php${globals_php_version}-fpm"
                $package_prefix = "php${globals_php_version}-"
              }
            }
            $default_fpm_pid_file = "/var/run/php/php${globals_php_version}-fpm.pid"
            $fpm_error_log        = "/var/log/php${globals_php_version}-fpm.log"
            $ext_tool_enable      = "/usr/sbin/phpenmod -v ${globals_php_version}"
            $ext_tool_query       = "/usr/sbin/phpquery -v ${globals_php_version}"
          }
          default: {
            $default_config_root = '/etc/php5'
            $default_fpm_pid_file = '/var/run/php5-fpm.pid'
            $fpm_error_log = '/var/log/php5-fpm.log'
            $fpm_service_name = 'php5-fpm'
            $ext_tool_enable = '/usr/sbin/php5enmod'
            $ext_tool_query = '/usr/sbin/php5query'
            $package_prefix = 'php5-'
          }
        }
      }
    }
    'Suse': {
      case $globals_php_version {
        /^7/: {
          $default_config_root = '/etc/php7'
          $package_prefix = 'php7-'
          $default_fpm_pid_file = '/var/run/php7-fpm.pid'
          $fpm_error_log = '/var/log/php7-fpm.log'
        }
        default: {
          $default_config_root = '/etc/php5'
          $package_prefix = 'php5-'
          $default_fpm_pid_file = '/var/run/php5-fpm.pid'
          $fpm_error_log = '/var/log/php5-fpm.log'
        }
      }
    }
    'RedHat': {
      case $flavor {
        'zend': {
          $php_version_sans_dot = $php_version.regsubst(/\./, '', 'G')
          $default_config_root    = "/etc/opt/zend/php${php_version_sans_dot}zend"
          $default_fpm_pid_file   = '/var/run/php-fpm/php-fpm.pid'
          $fpm_service_name       = "php${php_version_sans_dot}zend-php-fpm"
          $package_prefix         = "php${php_version_sans_dot}zend-php-"
        }

        default: {
          case $rhscl_mode {
            'remi': {
              $rhscl_root             = "/opt/remi/${php_version}/root"
              $default_config_root    = "/etc/opt/remi/${php_version}"
              $default_fpm_pid_file   = '/var/run/php-fpm/php-fpm.pid'
              $package_prefix         = "${php_version}-php-"
              $fpm_service_name       = "${php_version}-php-fpm"
            }
            'rhscl': {
              $rhscl_root             = "/opt/rh/${php_version}/root"
              $default_config_root    = "/etc/opt/rh/${php_version}" # rhscl registers contents by copy in /etc/opt/rh
              $default_fpm_pid_file   = "/var/opt/rh/${php_version}/run/php-fpm/php-fpm.pid"
              $package_prefix         = "${php_version}-php-"
              $fpm_service_name       = "${php_version}-php-fpm"
            }
            undef: {
              $default_config_root    = '/etc/php.d'
              $default_fpm_pid_file   = '/var/run/php-fpm/php-fpm.pid'
              $fpm_service_name       = undef
              $package_prefix         = undef
            }
            default: {
              fail("Unsupported rhscl_mode '${rhscl_mode}'")
            }
          }
        }
      }
    }
    'FreeBSD': {
      case $globals_php_version {
        /^(\d)\.(\d)$/: {
          $package_prefix = "php${1}${2}-"
        }
        default: {
          $package_prefix = 'php56-'
        }
      }
      $default_config_root  = '/usr/local/etc'
      $default_fpm_pid_file = '/var/run/php-fpm.pid'
      $fpm_service_name     = undef
    }
    'Archlinux': {
      $default_config_root  =  '/etc/php'
      $default_fpm_pid_file = '/run/php-fpm/php-fpm.pid'
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
    }
  }

  $globals_config_root    = pick($config_root, $default_config_root)
  $globals_fpm_pid_file   = pick($fpm_pid_file, $default_fpm_pid_file)
}
