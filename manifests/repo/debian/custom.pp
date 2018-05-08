# Allows to define a custom repository as php install source.
#
# === Parameters
# [*apt_source*]
#   Hash holding all parameters passed directly to `apt::source`.
#
# [*apt_list_name*]
#   Allows to customize the list name used in `/etc/apt/sources.list.d/YOUR_LIST_NAME.list`.
#
class php::repo::debian::custom(
  Hash    $apt_source,
  String  $apt_list_name = 'php_custom',
) {
  if $caller_module_name != $module_name {
    warning('php::repo::debian::custom is private')
  }
  apt::source { $apt_list_name:
    * => $apt_source,
  }
}
