[![Puppet Forge](http://img.shields.io/puppetforge/v/puppet/php.svg)](https://forge.puppetlabs.com/puppet/php)

# voxpupuli/php Puppet Module

voxpupuli/php is a Puppet module for managing PHP with a strong focus
on php-fpm. The module aims to use sane defaults for the supported
architectures. We strive to support all recent versions of Debian,
Ubuntu, RedHat/CentOS, openSUSE/SLES and FreeBSD. Managing Apache
with `mod_php` is not supported.

This originally was a fork of [jippi/puppet-php](https://github.com/jippi/puppet-php)
(nodes-php on Puppet Forge) but has since been rewritten in large parts.

## Usage

Quickest way to get started is simply `include`'ing the _`php` class_.

```puppet
include 'php'
```

Or, you can override defaults and specify additional custom
configurations by declaring `class { 'php': }` with parameters:

```puppet
class { 'php':
  ensure       => latest,
  manage_repos => true,
  fpm          => true,
  dev          => true,
  composer     => true,
  pear         => true,
  phpunit      => false,
}
```

Optionally the PHP version or configuration root directory can be changed also:

```puppet
class { 'php::globals':
  php_version => '7.0',
  config_root => '/etc/php/7.0',
}->
class { 'php':
  manage_repos => true
}
```

There are more configuration options available. Please refer to the
auto-generated documentation at [REFERENCE.md](REFERENCE.md).

### Defining `php.ini` settings

PHP configuration parameters in `php.ini` files can be defined as parameter
`settings` on the main `php` class, or `php::fpm` / `php::cli` classes,
or `php::extension` resources for each component independently.

These settings are written into their respective `php.ini` file. Global
settings in `php::settings` are merged with the settings of all components.
Please note that settings of extensions are always independent.

In the following example the PHP options and timezone will be set in
all PHP configurations, i.e. the PHP cli application and all php-fpm pools.

```puppet
  class { 'php':
    settings   => {
      'PHP/max_execution_time'  => '90',
      'PHP/max_input_time'      => '300',
      'PHP/memory_limit'        => '64M',
      'PHP/post_max_size'       => '32M',
      'PHP/upload_max_filesize' => '32M',
      'Date/date.timezone'      => 'Europe/Berlin',
    },
  }
```

### Installing extensions

PHP configuration parameters in `php.ini` files can be defined
as parameter `extensions` on the main `php` class. They are
activated for all activated SAPIs.

```puppet
  class { 'php':
    extensions => {
      bcmath    => { },
      imagick   => {
        provider => pecl,
      },
      xmlrpc    => { },
      memcached => {
        provider        => 'pecl',
        header_packages => [ 'libmemcached-devel', ],
      },
      apc       => {
        provider => 'pecl',
        settings => {
          'apc/stat'       => '1',
          'apc/stat_ctime' => '1',
        },
        sapi     => 'fpm',
      },
    },
  }
```

See [the documentation](REFERENCE.md#php--extension) of the `php::extension`
resource for all available parameters and default values.

### Defining php-fpm pools

If different php-fpm pools are required, you can use `php::fpm::pool`
defined resource type. A single pool called `www` will be configured
by default. Specify additional pools like so:

```puppet
  php::fpm::pool { 'www2':
    listen => '127.0.1.1:9000',
  }
```

For an overview of all possible parameters for `php::fpm::pool` resources please
see [its documentation](REFERENCE.md#php--fpm--pool).

### Overriding php-fpm user

By default, php-fpm is set up to run as Apache. If you need to customize that user, you can do that like so:

```puppet
  class { 'php':
    fpm_user  => 'nginx',
    fpm_group => 'nginx',
  }
```

### PHP with one FPM pool per user

This will create one vhost. $users is an array of people having php files at
$fqdn/$user. This code uses voxpupuli/php and voxpupuli/nginx to create
the vhost and one php fpm pool per user. This was tested on Archlinux with
nginx 1.13 and PHP 7.2.3.

```puppet
$users = ['bob', 'alice']

class { 'php':
   ensure       => 'present',
   manage_repos => false,
   fpm          => true,
   dev          => false,
   composer     => false,
   pear         => true,
   phpunit      => false,
   fpm_pools    => {},
}

include nginx

nginx::resource::server{$facts['fqdn']:
  www_root  => '/var/www',
  autoindex => 'on',
}
nginx::resource::location{'dontexportprivatedata':
  server        => $facts['fqdn'],
  location      => '~ /\.',
  location_deny => ['all'],
}
$users.each |$user| {
  # create one fpm pool. will be owned by the specific user
  # fpm socket will be owned by the nginx user 'http'
  php::fpm::pool{$user:
    user         => $user,
    group        => $user,
    listen_owner => 'http',
    listen_group => 'http',
    listen_mode  => '0660',
    listen       => "/var/run/php-fpm/${user}-fpm.sock",
  }
  nginx::resource::location { "${name}_root":
    ensure      => 'present',
    server      => $facts['fqdn'],
    location    => "~ .*${user}\/.*\.php$",
    index_files => ['index.php'],
    fastcgi     => "unix:/var/run/php-fpm/${user}-fpm.sock",
    include     => ['fastcgi.conf'],
  }
}
```

### Alternative examples using Hiera

Alternative to the Puppet DSL code examples above, you may optionally define your PHP configuration using Hiera.

Below are all the examples you see above, but defined in YAML format for use with Hiera.

```yaml
---
php::ensure: latest
php::manage_repos: true
php::fpm: true
php::fpm_user: 'nginx'
php::fpm_group: 'nginx'
php::dev: true
php::composer: true
php::pear: true
php::phpunit: false
php::settings:
  'PHP/max_execution_time': '90'
  'PHP/max_input_time': '300'
  'PHP/memory_limit': '64M'
  'PHP/post_max_size': '32M'
  'PHP/upload_max_filesize': '32M'
  'Date/date.timezone': 'Europe/Berlin'
php::extensions:
  bcmath: {}
  xmlrpc: {}
  imagick:
    provider: pecl
  memcached:
    provider: pecl
    header_packages:
      - libmemcached-dev
  apc:
    provider: pecl
    settings:
      'apc/stat': 1
      'apc/stat_ctime': 1
    sapi: 'fpm'
php::fpm::pools:
  www2:
    listen: '127.0.1.1:9000'
```

## Notes

### Inheriting configuration across multiple Hiera sources

Configuration from Hiera such as `php::fpm::pools` is automatically
lookup up using the "first" merge method. This means that the first
value found is used. If you instead want to merge the hash keys
across multiple Hiera sources, you can use [`lookup_options`] to
set [`hash` or `deep` behaviors] such as in the example
[data/default.yaml](data/default.yaml):

```yaml
lookup_options:
  php::fpm::pools:
    merge: hash
```

[`lookup_options`]: https://puppet.com/docs/puppet/latest/hiera_merging.html#setting_lookup_options_to_refine_the_result_of_a_lookup
[`hash` or `deep` behaviors]: https://puppet.com/docs/puppet/latest/hiera_merging.html#merge_behaviors

### Ubuntu systems and Ondřej's PPA

To use a different PHP version than the Ubuntu one, you can install Ondřej's PPA and set the version explicitly:

```
  class{ 'php::repo::ubuntu': }->
  class { '::php::globals':
    php_version => '7.4',
  }
```

#### Older versions of Ondřej's PPAs are deprecated

The older Ubuntu PPAs run by Ondřej have been deprecated (ondrej/php5, ondrej/php5.6)
in favor of a new PPA: ondrej/php which contains many versions of PHP depending on the release.
Here's an example in hiera of getting PHP 5.6 installed with php-fpm, pear/pecl, and composer:

```puppet
php::globals::php_version: '5.6'
php::fpm: true
php::dev: true
php::composer: true
php::pear: true
php::phpunit: false
```

If you do not specify a php version, in Ubuntu the default will depend on the release you are using.

### Apache support

Apache with `mod_php` is not supported by this module. Please use
[puppetlabs/apache](https://forge.puppetlabs.com/puppetlabs/apache) instead.

We prefer using php-fpm. You can find an example Apache vhost in
`manifests/apache_vhost.pp` that shows you how to use `mod_proxy_fcgi` to
connect to php-fpm.

### ZendPHP support

> Be sure to require the `zend/zend_common` puppet module
> to ensure the correct package repository is being used.

To use ZendPHP, configure the global zend parameters.

```puppet
class { 'php::globals':
  php_version => '7.4',
  flavor      => 'zend',
  zend_creds  => {
    'username' => '<USERNAME>',
    'password' => '<PASSWORD>',
  },
}->
class { 'php':
  fpm        => true,
  fpm_pools  => {
    www      => {
      listen => "127.0.0.1:9000",
    },
  }
}
```

#### ZendPHP soft dependencies on RedHat/CentOS/Rocky

Due to the nature of ZendPHP delivering patched, LTS versions of PHP and its extensions,
RedHat systems sometimes depend on `epel` and the `powertools` repo.

If you're trying to use ZendPHP and running into issues of missing dependencies,
first try installing epel. If the dependencies still can't be found, try
enabling `powertools`.

```puppet
if $facts['os']['family'] == 'RedHat' {
  package { 'epel-release': }

  if Float($php_version) < 7.4 {
    # Depends on puppet/yum
    class { 'yum':
      managed_repos => ['powertools'],
      repos => {
        'powertools' => {
          enabled => true,
        },
      },
    }
  }
}
```

### RedHat/CentOS SCL Users

If you plan to use the SCL repositories with this module you must do the following adjustments:

#### General config

This ensures that the module will create configurations in the directory
`/etc/opt/rh/<php_version>/` (also in php.d/ for extensions). Anyway you have to
manage the SCL repo's by your own.

```puppet
class { 'php::globals':
  php_version => 'rh-php71',
  rhscl_mode  => 'rhscl',
}
-> class { 'php':
  manage_repos => false
}
```

#### Extensions

Extensions in SCL are being installed with packages that cover 1 or more .so files. This is kinda incompatible with
this module, since this module specifies an extension by name and derives the name of the package and the config (.ini)
from it. To manage extensions of SCL packages you must use the following parameters:

```puppet
class { 'php':
  ...
  extensions  => {
    'soap' => {
      ini_prefix => '20-',
    },
  }
}
```

By this you tell the module to configure bz2 and calender while ensuring only the package `common`. Additionally to the
installation of 'common' the ini files 'calender.ini' and 'bz2.ini' will be created by the scheme
`<config_file_prefix><extension_title>`.

A list of commonly used modules:

```puppet
    {
      extensions => {
        'xml' => {
          ini_prefix => '20-',
          multifile_settings => true,
          settings => {
            'dom'  => {},
            'simplexml' => {},
            'xmlwriter' => {},
            'xsl' => {},
            'wddx' => {},
            'xmlreader' => {},
          },
        },
        'soap' => {
          ini_prefix => '20-',
        },
        'imap' => {
          ini_prefix => '20-',
        },
        'intl' => {
          ini_prefix => '20-',
        },
        'gd' => {
          ini_prefix => '20-',
        },
        'mbstring' => {
          ini_prefix => '20-',
        },
        'xmlrpc' => {
          ini_prefix => '20-',
        },
        'pdo' => {
          ini_prefix => '20-',
          multifile_settings => true,
          settings => {
              'pdo'  => {},
              'pdo_sqlite' => {},
              'sqlite3' => {},
            },
        },
        'process' => {
          ini_prefix => '20-',
          multifile_settings => true,
          settings => {
             'posix'  => {},
             'shmop' => {},
             'sysvmsg' => {},
             'sysvsem' => {},
             'sysvshm' => {},
          },
        },
        'mysqlnd' => {
          ini_prefix => '30-',
          multifile_settings => true,
          settings => {
             'mysqlnd'  => {},
             'mysql' => {},
             'mysqli' => {},
             'pdo_mysql' => {},
             'sysvshm' => {},
          },
        },
      }
    }
```

### Facts

We deliver a `phpversion` fact with this module. This is explicitly **NOT** intended
to be used within your puppet manifests as it will only work on your second puppet
run. Its intention is to make querying PHP versions per server easy via PuppetDB or Foreman.

### FreeBSD support

On FreeBSD systems we purge the system-wide `extensions.ini` in favour of
per-module configuration files.

Please also note that support for Composer and PHPUnit on FreeBSD is untested
and thus likely incomplete.

### Running the test suite

To run the tests install the ruby dependencies with `bundler` and execute
`rake`:

```bash
bundle install --path vendor/bundle
bundle exec rake
```

## Bugs & New Features

If you happen to stumble upon a bug, please feel free to create a pull request
with a fix (optionally with a test), and a description of the bug and how it
was resolved.

Or if you're not into coding, simply create an issue adding steps to let us
reproduce the bug and we will happily fix it.

If you have a good idea for a feature or how to improve this module in general,
please create an issue to discuss it. We are very open to feedback. Pull
requests are always welcome.

We hate orphaned and unmaintained Puppet modules as much as you do and
therefore promise that we will continue to maintain this module and keep
response times to issues short. If we happen to lose interest, we will write
a big fat warning into this README to let you know.

## License

The project is released under the permissive MIT license.

The source can be found at
[github.com/voxpupuli/puppet-php](https://github.com/voxpupuli/puppet-php/).

This Puppet module was originally maintained by some fellow puppeteers at
[Mayflower GmbH](https://mayflower.de) and is now maintained by
[Vox Pupuli](https://voxpupuli.org/).
