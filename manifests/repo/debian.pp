# Configure debian apt repo
#
# === Parameters
#
# [*source*]
#   Mode of Repo Handling 'auto', 'native', 'sury', 'dotdeb', 'custom'
#
# [*apt_source*]
#   full Apt Source Hash defined in apt::source

class php::repo::debian(
  Enum['auto', 'native', 'sury', 'dotdeb', 'custom'] $source,
  Optional[Hash] $apt_source = undef,
  ### deprecated parameters below
  $location     = undef,
  $release      = undef,
  $repos        = undef,
  $include_src  = undef,
  $key          = undef,
  $dotdeb       = undef,
  $sury         = undef,
) {

  warning("we are here in repo setup")
  warning($sury)
  warning($dotdeb)
  warning($source)

  assert_private()

  ### deprecation code start ###########################################################################################
  if ($sury and $dotdeb) {
    fail('invalid setting, you cannot set both $sury and $dotdeb to true.')
  }

  if $sury != undef {
    deprecation('php::repo::debian sury', '$sury is deprecated and will be removed in the next major release. Please use $source instead.')
    warning('$sury is deprecated and will be removed in the next major release. Please use $source instead.') # TODO: remove
    if $sury {
      if ($source != 'auto' or $source != 'sury') {
        fail('invalid $source and $sury combination')
      }
      $_source = 'sury'
    }
  }
  if $dotdeb != undef {
    deprecation('php::repo::debian dotdeb', '$dotdeb is deprecated and will be removed in the next major release. Please use $source instead.')
    warning('$dotdeb is deprecated and will be removed in the next major release. Please use $source instead.')
    if $dotdeb {
      if ($source != 'auto' or $source != 'dotdeb') {
        fail('invalid $source and $dotdeb combination')
      }
      $_source = 'dotdeb'
    }
  }

  if  ($sury == undef or $sury == false) and ($dotdeb == undef or $dotdeb == false) {
    $_source = $source
  }

  if $location != undef or $release != undef or $repos != undef or $include_src != undef or $key != undef {
    deprecation('php::repo::debian $apt', '$location, $release, $repos, $include_src and $key are deprecated and will be removed in the next major release. Please use $repo hash instead.')
    warning('php::repo::debian $apt', '$location, $release, $repos, $include_src and $key are deprecated and will be removed in the next major release. Please use $repo hash instead.')

    $_apt_source = {
      location     => $location,
      release      => $release,
      repos        => $repos,
      include      => {
          'src' => $include_src,
          'deb' => true,
      },
      key          => $key,
    }
  } else {
    $_apt_source = $apt_source
  }
  ### deprecation code end ###########################################################################################

  if ($apt_source != undef and $source != 'custom') {
    warning("\$apt_source defined as '${apt_source}' but \$source is not 'custom'")
  }

  include '::apt'

  case $php::globals::globals_php_version {
    /^[57].[0-9]/: { $debian_php_version = $php::globals::globals_php_version }
    default:  { # default == `5.x`
      # would prefer to auto lookup a valid version but this won't work, as data $php::globals sets paths according
      # the invalid version number `5.x` which uses a default version.
      #$debian_php_version = lookup('php::repo::debian::native::version_matrix', Hash[Integer, Pattern[/^[57].[0-9]/]])
      fail('you have to set $php::globals::php_version to a valid php version. cannot use default version')
    }
  }

  case $_source {
    'native': { class { 'php::repo::debian::native': } }
    'auto':   { class { 'php::repo::debian::auto': } }
    'sury':   { class { 'php::repo::debian::sury': } }
    'dotdeb': { class { 'php::repo::debian::dotdeb': } }
    'custom': { class { 'php::repo::debian::custom': apt_source => $_apt_source } }
    default:  { fail("invalid source '${source}'") }
  }
}
