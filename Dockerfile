# To keep this Dockerfile simple, we rely on `ledermann/base`,
# which is based on the official Ruby image and adds Nginx, Node.js and Yarn
FROM ledermann/base
LABEL maintainer="neogalaxy45@gmail.com"

# Install PostgreSQL client and ImageMagick
RUN apt-get update && \
    apt-get install -y libpq-dev && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set some config
ENV RAILS_LOG_TO_STDOUT true

# Workdir
RUN mkdir -p /home/app
WORKDIR /home/app

# Install gems
ADD Gemfile* /home/app/
ADD docker /home/app/docker/
RUN bash docker/bundle.sh

# Add the Rails app
ADD . /home/

# Create user and group
RUN groupadd --gid 9999 app && \
    useradd --uid 9999 --gid app app && \
    chown -R app:app /home/app

# Precompile assets
RUN RAILS_ENV=production SECRET_KEY_BASE=foo bundle exec rake assets:precompile --trace

# Add the nginx site and config
RUN rm -rf /etc/nginx/sites-available/default
ADD docker/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80

# Save timestamp of image building
RUN date -u > BUILD_TIME

# Start up
CMD "docker/startup.sh"
