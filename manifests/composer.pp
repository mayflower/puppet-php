# Install composer package manager
#
# === Parameters
#
# [*channel_sources*]
#   Define channel URLs to the Composer source file
#
# [*path*]
#   Holds path to the Composer executable
#
# [*channel*]
#   Holds the Update channel (stable|preview|snapshot|1|2)
#
# [*proxy_type*]
#    proxy server type (none|http|https|ftp)
#
# [*proxy_server*]
#   specify a proxy server, with port number if needed. ie: https://example.com:8080.
#
# [*auto_update*]
#   Defines if composer should be auto updated
#
# [*max_age*]
#   Defines the time in days after which an auto-update gets executed
#
# [*root_group*]
#   UNIX group of the root user
#
class php::composer (
  Hash $channel_sources                = {},
  Stdlib::Absolutepath $path           = $php::params::composer_path,
  Optional[String[1]] $proxy_type      = undef,
  Optional[String[1]] $proxy_server    = undef,
  Php::ComposerChannel $channel        = 'stable',
  Boolean $auto_update                 = true,
  Integer $max_age                     = $php::params::composer_max_age,
  Variant[Integer, String] $root_group = $php::params::root_group,
) inherits php::params {
  assert_private()

  archive { 'download composer':
    path         => $path,
    source       => $channel_sources.dig($channel),
    proxy_type   => $proxy_type,
    proxy_server => $proxy_server,
  }
  -> file { $path:
    mode  => '0555',
    owner => root,
    group => $root_group,
  }

  if $auto_update {
    class { 'php::composer::auto_update':
      max_age      => $max_age,
      path         => $path,
      channel      => $channel,
      proxy_type   => $proxy_type,
      proxy_server => $proxy_server,
    }
  }
}
