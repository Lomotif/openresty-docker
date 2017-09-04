
# Setup

Ensure the necessary directories are set up

    $ bin/bootstrap nginx		# Create /etc/nginx
    $ bin/bootstrap logs		# Create /var/log/nginx
    $ bin/bootstrap populate_nginx	# Populate /etc/nginx with default nginx config files

# Configuration

Copy the provided nginx configuration file to the (newly created?) `/etc/nginx`, and edit as necessary

    $ sudo cp nginx/nginx.conf /etc/nginx

This folder, along with `/var/log/nginx` will be mounted in the container at run time

# Running

We set a specific flag on the `docker run` command

    --cpuset-cpu="0,1"

    We set specific CPU affinity to constrain openresty/nginx activity to a few specific CPUs in order
    to not conflict with other containers/applications on the system


    $ docker run -d -v /etc/nginx:/etc/nginx:ro -v /var/log/nginx:/var/log/nginx -p 80:80 -p 443:443 --cpuset-cpus="0,1" --name openresty lomotif/openresty

# Applications and Virtual Hosts

Set up virtual hosts as per-normal by including the configurations in `/etc/nginx/sites-available`/`/etc/nginx/sites-enabled`.

However, bear in mind that due to Docker's security measures, mounted volumes cannot contain symlinks, so you'll need to at least
copy the virtualhost configurations into `/etc/nginx/sites-available`. Symlinking from `/etc/nginx/sites-available` to
`/etc/nginx/sites-enabled` is allowed because the enture `/etc/nginx` is mounted into the container.


# Default site configuration

A `default_server` configuration is included by default in `/etc/nginx/sites-available/default.conf`, and symlinked to `/etc/nginx/sites-enabled/default.conf`. If you prefer to provide your own `default_server` implementation, delete the symlink in `/etc/nginx/sites-enabled/`.


# Auto SSL with LetsEncrypt

This OpenResty Docker image uses [lua-resty-auto-ssl](https://github.com/GUI/lua-resty-auto-ssl) to automatically provision
SSL certificates for the sites hosted in this OpenResty instance.


## Setup


### Allowed Hostnames

We first need to pass the list of hostnames for which we want to be able to provision SSL certificates.

The auto_ssl setup expects a list of comma-separated domain names in the environment variable: `AUTO_SSL_DOMAINS`

    $ docker run -d --name openresty -e AUTO_SSL_DOMAINS=test1.example.com,test2.example.com lomotif/openresty

When including nginx site configurations, simply set the `server_name` directive to one of the domains in the list above


### Testing

When initially setting up auto_ssl, it's recommended to use the staging LetsEncrypt CA and verify that the configuration
works first, before requesting an SSL cert from the production CA.

To activate the producation CA, run the container with the environment variable `AUTO_SSL_PROD_CA` set to either of the strings: `1` or `true`

    $ docker run -d --name openresty -e AUTO_SSL_PROD_CA=1 lomotif/openresty
