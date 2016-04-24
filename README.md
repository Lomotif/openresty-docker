
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

    $ docker run -d -v /etc/nginx:/etc/nginx:ro -v /var/log/nginx:/var/log/nginx --name openresty lomotif/openresty

# Applications and Virtual Hosts

Set up virtual hosts as per-normal by including the configurations in `/etc/nginx/sites-available`/`/etc/nginx/sites-enabled`.

However, bear in mind that due to Docker's security measures, mounted volumes cannot contain symlinks, so you'll need to at least
copy the virtualhost configurations into `/etc/nginx/sites-available`. Symlinking from `/etc/nginx/sites-available` to 
`/etc/nginx/sites-enabled` is allowed because the enture `/etc/nginx` is mounted into the container.
