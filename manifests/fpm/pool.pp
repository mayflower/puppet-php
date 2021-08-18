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
# [*process.dumpable*]
#   Allow PHP to create a coredump during a segfault. Must still set
#   rlimit_core
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
  $ensure                                  = 'present',
  $listen                                  = '127.0.0.1:9000',
  $listen_backlog                          = '-1',
  $listen_allowed_clients                  = undef,
  $listen_owner                            = undef,
  $listen_group                            = undef,
  $listen_mode                             = undef,
  $user                                    = $php::fpm::config::user,
  $group                                   = $php::fpm::config::group,
  Optional[String[1]] $apparmor_hat        = undef,
  $pm                                      = 'dynamic',
  $pm_max_children                         = '50',
  $pm_start_servers                        = '5',
  $pm_min_spare_servers                    = '5',
  $pm_max_spare_servers                    = '35',
  $pm_max_requests                         = '0',
  $pm_process_idle_timeout                 = '10s',
  $pm_status_path                          = undef,
  $ping_path                               = undef,
  $ping_response                           = 'pong',
  $access_log                              = undef,
  $access_log_format                       = '"%R - %u %t \"%m %r\" %s"',
  $request_terminate_timeout               = '0',
  $request_slowlog_timeout                 = '0',
  $security_limit_extensions               = undef,
  $slowlog                                 = "/var/log/php-fpm/${name}-slow.log",
  $template                                = 'php/fpm/pool.conf.erb',
  $process_dumpable                        = false,
  $rlimit_files                            = undef,
  $rlimit_core                             = undef,
  $chroot                                  = undef,
  $chdir                                   = undef,
  $catch_workers_output                    = 'no',
  $include                                 = undef,
  $env                                     = [],
  $env_value                               = {},
  $clear_env                               = true,
  $options                                 = {},
  $php_value                               = {},
  $php_flag                                = {},
  $php_admin_value                         = {},
  $php_admin_flag                          = {},
  $php_directives                          = [],
  $root_group                              = $php::params::root_group,
  Optional[Stdlib::Absolutepath] $base_dir = undef,
) {
  # The base class must be included first because it is used by parameter defaults
  if ! defined(Class['php']) {
    warning('You must include the php base class before using any php defined resources')
  }

  if ($php::globals::php_version != undef) {
    $php_version_major = regsubst($php::globals::php_version, '^(\d+)\.(\d+)$','\1')
  } else {
    $php_version_major = 5
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
