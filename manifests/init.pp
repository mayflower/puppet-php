# Base class with global configuration parameters that pulls in all
# enabled components.
#
# === Parameters
#
# [*ensure*]
#   Specify which version of PHP packages to install, defaults to 'present'.
#   Please note that 'absent' to remove packages is not supported!
#
# [*manage_repos*]
#   Include repository (dotdeb, ppa, etc.) to install recent PHP from
#
# [*fpm*]
#   Install and configure php-fpm
#
# [*fpm_service_enable*]
#   Enable/disable FPM service
#
# [*fpm_service_ensure*]
#   Ensure FPM service is either 'running' or 'stopped'
#
# [*fpm_service_name*]
#   This is the name of the php-fpm service. It defaults to reasonable OS
#   defaults but can be different in case of using php7.0/other OS/custom fpm service
#
# [*fpm_service_provider*]
#   This is the name of the service provider, in case there is a non
#   OS default service provider used to start FPM.
#   Defaults to 'undef', pick system defaults.
#
# [*fpm_pools*]
#   Hash of php::fpm::pool resources that will be created. Defaults
#   to a single php::fpm::pool named www with default parameters.
#
# [*fpm_global_pool_settings*]
#   Hash of defaults params php::fpm::pool resources that will be created.
#   Defaults to empty hash.
#
# [*fpm_inifile*]
#   Path to php.ini for fpm
#
# [*fpm_package*]
#   Name of fpm package to install
#
# [*fpm_user*]
#   The user that php-fpm should run as
#
# [*fpm_group*]
#   The group that php-fpm should run as
#
# [*dev*]
#   Install php header files, needed to install pecl modules
#
# [*composer*]
#   Install and auto-update composer
#
# [*pear*]
#   Install PEAR
#
# [*phpunit*]
#   Install phpunit
#
# [*apache_config*]
#   Manage apache's mod_php configuration
#
# [*proxy_type*]
#    proxy server type (none|http|https|ftp)
#
# [*proxy_server*]
#   specify a proxy server, with port number if needed. ie: https://example.com:8080.
#
# [*extensions*]
#   Install PHP extensions, this is overwritten by hiera hash `php::extensions`
#
# [*package_prefix*]
#   This is the prefix for constructing names of php packages. This defaults
#   to a sensible default depending on your operating system, like 'php-' or
#   'php5-'.
#
# [*config_root_ini*]
#   This is the path to the config .ini files of the extensions. This defaults
#   to a sensible default depending on your operating system, like
#   '/etc/php5/mods-available' or '/etc/php5/conf.d'.
#
# [*config_root_inifile*]
#   The path to the global php.ini file. This defaults to a sensible default
#   depending on your operating system.
#
# [*ext_tool_enable*]
#   Absolute path to php tool for enabling extensions in debian/ubuntu systems.
#   This defaults to '/usr/sbin/php5enmod'.
#
# [*ext_tool_query*]
#   Absolute path to php tool for querying information about extensions in
#   debian/ubuntu systems. This defaults to '/usr/sbin/php5query'.
#
# [*ext_tool_enabled*]
#   Enable or disable the use of php tools on debian based systems
#   debian/ubuntu systems. This defaults to 'true'.
#
# [*log_owner*]
#   The php-fpm log owner
#
# [*log_group*]
#   The group owning php-fpm logs
#
# [*embedded*]
#   Enable embedded SAPI
#
# [*pear_ensure*]
#   The package ensure of PHP pear to install and run pear auto_discover
#
# [*settings*]
#   PHP configuration parameters in php.ini files as a hash. For example,
#   'Date/date.timezone' => 'Australia/Melbourne' sets data.timezone
#   to 'Australia/Melbourne' under [Date] section, and
#   'PHP/memory_limit' => '256M' sets memory_limit to 256M.
#
# [*cli_settings*]
#   Additional hash of PHP configuration parameters for PHP CLI. When a
#   setting key already exists in $settings, the value provided from the
#   $cli_settings parameter overrides the value from $settings parameter.
#   For example, 'PHP/memory_limit' => '1000M' sets memory_limit to 1000M
#   for the PHP cli ini file, regardless of the values from $settings.
#
# [*pool_purge*]
#   Whether to purge pool config files not created
#   by this module
#
# [*reload_fpm_on_config_changes*]
#   by default, we reload the service on changes.
#   But certain options, like socket owner, will only be applied during a restart.
#   If set to false, a restart will be executed instead of a reload.
#   This default will be changed in a future release.
#
class php (
  String $ensure                                  = $php::params::ensure,
  Boolean $manage_repos                           = $php::params::manage_repos,
  Boolean $fpm                                    = true,
  Boolean $fpm_service_enable                     = $php::params::fpm_service_enable,
  Enum['running', 'stopped'] $fpm_service_ensure  = $php::params::fpm_service_ensure,
  String[1] $fpm_service_name                     = $php::params::fpm_service_name,
  Optional[String[1]] $fpm_service_provider       = undef,
  Hash $fpm_pools                                 = $php::params::fpm_pools,
  Hash $fpm_global_pool_settings                  = {},
  Stdlib::Absolutepath $fpm_inifile               = $php::params::fpm_inifile,
  Optional[String[1]] $fpm_package                = undef,
  String[1] $fpm_user                             = $php::params::fpm_user,
  String[1] $fpm_group                            = $php::params::fpm_group,
  Stdlib::Filemode $fpm_log_dir_mode              = $php::params::fpm_log_dir_mode,
  Boolean $embedded                               = false,
  Boolean $dev                                    = true,
  Boolean $composer                               = true,
  Boolean $pear                                   = $php::params::pear,
  String $pear_ensure                             = $php::params::pear_ensure,
  Boolean $phpunit                                = false,
  Boolean $apache_config                          = false,
  Optional[String[1]] $proxy_type                 = undef,
  Optional[String[1]] $proxy_server               = undef,
  Hash $extensions                                = {},
  Hash $settings                                  = {
    # php secure settings by default
    'Date/date.timezone'      => 'UTC',
    'PHP/expose_php'          => 'Off',
    'PHP/allow_url_fopen'     => 'Off',
    'PHP/disable_functions'   => 'pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,chown,diskfreespace,disk_free_space,disk_total_space,dl,exec,escapeshellarg,escapeshellcmd,fileinode,highlight_file,max_execution_time,passthru,pclose,phpinfo,popen,proc_close,proc_open,proc_get_status,proc_nice,proc_open,proc_terminate,set_time_limit,shell_exec,show_source,system,serialize,unserialize,__construct, __destruct, __call,__wakeup',
    'PHP/memory_limit'        => '128M',
    'PHP/include_path'        => '/usr/share/pear:/usr/share/php',
    'PHP/file_uploads'        => 'Off',
    'Assertion/assert.active' => 'Off',
    'Session/session.use_strict_mode' => 1,
    'Session/session.cookie_secure'   => true,
    'Session/session.cookie_httponly' => true,
  },
  Hash $cli_settings                              = {},
  Optional[String[1]] $package_prefix             = $php::params::package_prefix,
  Stdlib::Absolutepath $config_root_ini           = $php::params::config_root_ini,
  Stdlib::Absolutepath $config_root_inifile       = $php::params::config_root_inifile,
  Optional[Stdlib::Absolutepath] $ext_tool_enable = $php::params::ext_tool_enable,
  Optional[Stdlib::Absolutepath] $ext_tool_query  = $php::params::ext_tool_query,
  Boolean $ext_tool_enabled                       = $php::params::ext_tool_enabled,
  String $log_owner                               = $php::params::fpm_user,
  String $log_group                               = $php::params::fpm_group,
  Boolean $pool_purge                             = $php::params::pool_purge,
  Boolean $reload_fpm_on_config_changes           = true,
) inherits php::params {
  $real_fpm_package = pick($fpm_package, "${package_prefix}${php::params::fpm_package_suffix}")

  $real_settings = $settings
  $real_extensions = $extensions
  $real_fpm_pools = $fpm_pools
  $real_fpm_global_pool_settings = $fpm_global_pool_settings

  # Merge in additional or overridden settings for php::cli::settings.
  $final_cli_settings = $real_settings + $cli_settings

  if $manage_repos {
    contain php::repo
  }

  class { 'php::packages': }
  -> class { 'php::cli':
    settings => $final_cli_settings,
  }
  contain php::packages
  contain php::cli

  # Configure global PHP settings in php.ini
  if $facts['os']['family'] != 'Debian' {
    Class['php::packages']
    -> class { 'php::global':
      settings => $real_settings,
    }
    contain php::global
  }

  if $fpm { contain 'php::fpm' }
  if $embedded {
    if $facts['os']['family'] == 'RedHat' and $fpm {
      # Both fpm and embeded SAPIs are using same php.ini
      fail('Enabling both cli and embedded sapis is not currently supported')
    }

    class { 'php::embedded':
      settings => $real_settings,
    }
    contain php::embedded
  }
  if $dev {
    contain php::dev
  }
  if $composer {
    class { 'php::composer':
      proxy_type   => $proxy_type,
      proxy_server => $proxy_server,
    }
  }
  if $pear {
    class { 'php::pear':
      ensure => $pear_ensure,
    }
  }
  if $phpunit {
    contain php::phpunit
  }
  if $apache_config {
    class { 'php::apache_config':
      settings => $real_settings,
    }
    contain php::apache_config
  }

  create_resources('php::extension', $real_extensions, {
      require => Class['php::cli'],
  })

  # On FreeBSD purge the system-wide extensions.ini. It is going
  # to be replaced with per-module configuration files.
  if $facts['os']['family'] == 'FreeBSD' {
    # Purge the system-wide extensions.ini
    file { '/usr/local/etc/php/extensions.ini':
      ensure  => absent,
      require => Class['php::packages'],
    }
  }
}
