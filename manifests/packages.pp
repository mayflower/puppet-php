# Install common PHP packages
#
# === Parameters
#
# [*ensure*]
#   Specify which version of PHP packages to install
#
# [*names*]
#   List of the names of the package to install
#
# [*names_to_prefix*]
#   List of packages names that should be prefixed with the common
#   package prefix `$php::package_prefix`
#
class php::packages (
  String $ensure         = $php::ensure,
  Boolean $manage_repos  = $php::manage_repos,
  Array $names_to_prefix = $php::params::common_package_suffixes,
  Array $names           = $php::params::common_package_names,
) inherits php::params {
  assert_private()

  $names_with_prefix = prefix($names_to_prefix, $php::package_prefix)
  $real_names = union($names, $names_with_prefix)
  if $facts['os']['family'] == 'Debian' {
    if $manage_repos {
      include apt
      Class['apt::update'] -> Package[$real_names]
    }
    package { $real_names:
      ensure => $ensure,
    }
  } else {
    package { $real_names:
      ensure => $ensure,
    }
  }
}
