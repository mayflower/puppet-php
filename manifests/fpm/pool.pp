# Configure fpm pools
#
# === Parameters
#
# See the official php-fpm documentation for parameters that are not
# documented here: http://php.net/manual/en/install.fpm.configuration.php.
#
# [*ensure*]
#   Remove pool if set to `'absent'`, add otherwise
#
# [*listen*]
#   On what socket to listen for FastCGI connections, i.e.
#   `'127.0.0.1:9000'' or `'/var/run/php5-fpm.sock'`
#
# [*listen_backlog*]
#
# [*listen_allowed_clients*]
#
# [*listen_owner*]
#   Set owner of the Unix socket
#
# [*listen_group*]
#   Set the group of the Unix socket
#
# [*listen_mode*]
#
# [*user*]
#   The user that php-fpm should run as
#
# [*group*]
#   The group that php-fpm should run as
#
# [*apparmor_hat*]
#   The Apparmor hat to use
#
# [*pm*]
#
# [*pm_max_children*]
#
# [*pm_start_servers*]
#
# [*pm_min_spare_servers*]
#
# [*pm_max_spare_servers*]
#
# [*pm_max_requests*]
#
# [*pm_process_idle_timeout*]
#
# [*pm_status_path*]
#
# [*ping_path*]
#
# [*ping_response*]
#
# [*access_log*]
#   The path to the file to write access log requests to
#
# [*access_log_format*]
#   The format to save the access log entries as
#
# [*request_terminate_timeout*]
#
# [*request_slowlog_timeout*]
#
# [*security_limit_extensions*]
#
# [*slowlog*]
#
# [*template*]
#   The template to use for the pool
#
# [*rlimit_files*]
#
# [*rlimit_core*]
#
# [*chroot*]
#
# [*chdir*]
#
# [*catch_workers_output*]
#
# [*include*]
#   Other configuration files to include on this pool
#
# [*env*]
#   List of environment variables that are passed to the php-fpm from the
#   outside and will be available to php scripts in this pool
#
# [*env_value*]
#   Hash of environment variables and values as strings to use in php
#   scripts in this pool
#
# [*clear_env*]
#   Whether the environment should be cleared.
#
# [*options*]
#   An optional hash for any other data.
#
# [*php_value*]
#   Hash of php_value directives
#
# [*php_flag*]
#   Hash of php_flag directives
#
# [*php_admin_value*]
#   Hash of php_admin_value directives
#
# [*php_admin_flag*]
#   Hash of php_admin_flag directives
#
# [*php_directives*]
#   List of custom directives that are appended to the pool config
#
# [*root_group*]
#   UNIX group of the root user
#
# [*base_dir*]
#   The folder that contains the php-fpm pool configs. This defaults to a
#   sensible default depending on your operating system, like
#   '/etc/php5/fpm/pool.d' or '/etc/php-fpm.d'
#
define php::fpm::pool (
  Enum['present', 'absent'] $ensure                                 = 'present',
  String[1] $listen                                                 = '127.0.0.1:9000',
  Integer[-1] $listen_backlog                                       = -1,
  Optional[String[1]] $listen_allowed_clients                       = undef,
  Optional[String[1]] $listen_owner                                 = undef,
  Optional[String[1]] $listen_group                                 = undef,
  Optional[Stdlib::Filemode] $listen_mode                           = undef,
  String[1] $user                                                   = $php::fpm::config::user,
  String[1] $group                                                  = $php::fpm::config::group,
  Optional[String[1]] $apparmor_hat                                 = undef,
  String[1] $pm                                                     = 'dynamic',
  Variant[Integer[1], Php::EnvString] $pm_max_children              = 50,
  Variant[Integer[0], Php::EnvString] $pm_start_servers             = 5,
  Variant[Integer[0], Php::EnvString] $pm_min_spare_servers         = 5,
  Variant[Integer[0], Php::EnvString] $pm_max_spare_servers         = 35,
  Variant[Integer[0], Php::EnvString] $pm_max_requests              = 0,
  Variant[Php::Duration, Php::EnvString] $pm_process_idle_timeout   = '10s',
  Optional[Stdlib::Absolutepath] $pm_status_path                    = undef,
  Optional[Stdlib::Absolutepath] $ping_path                         = undef,
  String[1] $ping_response                                          = 'pong',
  Optional[Stdlib::Absolutepath] $access_log                        = undef,
  String[1] $access_log_format                                      = '"%R - %u %t \"%m %r\" %s"',
  Variant[Php::Duration, Php::EnvString] $request_terminate_timeout = 0,
  Variant[Php::Duration, Php::EnvString] $request_slowlog_timeout   = 0,
  Array[String[1]] $security_limit_extensions                       = [],
  Stdlib::Absolutepath $slowlog                                     = "/var/log/php-fpm/${name}-slow.log",
  String[1] $template                                               = 'php/fpm/pool.conf.erb',
  Optional[Integer] $rlimit_files                                   = undef,
  Optional[Integer] $rlimit_core                                    = undef,
  Optional[Stdlib::Absolutepath] $chroot                            = undef,
  Optional[Stdlib::Absolutepath] $chdir                             = undef,
  Enum['yes', 'no'] $catch_workers_output                           = 'no',
  Optional[String[1]] $include                                      = undef,
  Array[String[1]] $env                                             = [],
  Hash $env_value                                                   = {},
  Boolean $clear_env                                                = true,
  Hash $options                                                     = {},
  Hash $php_value                                                   = {},
  Hash $php_flag                                                    = {},
  Hash $php_admin_value                                             = {},
  Hash $php_admin_flag                                              = {},
  Array[String[1]] $php_directives                                  = [],
  String[1] $root_group                                             = $php::params::root_group,
  Optional[Stdlib::Absolutepath] $base_dir                          = undef,
) {
  # The base class must be included first because it is used by parameter defaults
  if ! defined(Class['php']) {
    warning('You must include the php base class before using any php defined resources')
  }

  $pool = $title

  # Hack-ish to default to user for group too
  $group_final = $group ? {
    undef   => $user,
    default => $group
  }

  # On FreeBSD fpm is not a separate package, but included in the 'php' package.
  # Implies that the option SET+=FPM was set when building the port.
  $real_package = $facts['os']['name'] ? {
    'FreeBSD' => [],
    default   => $php::fpm::package,
  }

  $pool_base_dir = pick_default($base_dir, $php::fpm::config::pool_base_dir, $php::params::fpm_pool_dir)
  if ($ensure == 'absent') {
    file { "${pool_base_dir}/${pool}.conf":
      ensure => absent,
      notify => Class['php::fpm::service'],
    }
  } else {
    file { "${pool_base_dir}/${pool}.conf":
      ensure  => file,
      notify  => Class['php::fpm::service'],
      require => Package[$real_package],
      content => template($template),
      owner   => root,
      group   => $root_group,
      mode    => '0640',
    }
  }
}
