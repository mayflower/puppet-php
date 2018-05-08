# This class only checks if the shipped php version matches the requested one.
# no repo setup has to be done here.
#
# === Parameters
# [*version_matrix*]
#   Lookup matrix to map Debian Versions to their shipped Php Versions.
#
class php::repo::debian::native(
  Hash $version_matrix,
) {
  if $caller_module_name != $module_name {
    warning('php::repo::debian::native is private')
  }

  $debian_major_version_number = Integer($facts['os']['release']['major'])
  $php_native_version = $version_matrix[$debian_major_version_number]

  if $php_native_version != $php::globals::globals_php_version {
    fail("invalid version php '${php::globals::globals_php_version}' in native mode for current operation system version
      (debian${facts['os']['release']['major']}). valid version is ${php_native_version}")
  }
}
