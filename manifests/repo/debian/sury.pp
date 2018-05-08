# Uses predifined values from https://deb.sury.org/ for usage of the sury repository as php install source.
#
# === Parameters
# [*apt_source*]
#   Hash holding all parameters passed directly to `apt::source` prefilled with module hiera data.
#   This parameter allows to override for example the key if it changes and the module has no update yet
#
# [*apt_list_name*]
#   Allows to customize the list name used in `/etc/apt/sources.list.d/YOUR_LIST_NAME.list`.
#
class php::repo::debian::sury(
  Hash    $apt_source,
  String  $apt_list_name,
  Hash[Integer, Array[Variant[Enum['-1'], Pattern[/^[57].[0-9]/]]]] $version_matrix

) {
  if $caller_module_name != $module_name {
    warning('php::repo::debian::sury is private')
  }

  $debian_major_version_number = Integer($facts['os']['release']['major'])

  warning($version_matrix)

  if ! ($php::repo::debian::debian_php_version in $version_matrix[$debian_major_version_number]) {
    $php_available_versions = join($version_matrix[$debian_major_version_number], ', ')
    warning($version_matrix[$debian_major_version_number])
    warning($php_available_versions)
    fail("invalid version php '${php::globals::globals_php_version}' with \$php::repo::debian::source 'sury' for current operation system version
      (debian${facts['os']['release']['major']}). valid versions are '${$php_available_versions}'")
  }



  apt::source { $apt_list_name:
    * => $apt_source,
  }
}
