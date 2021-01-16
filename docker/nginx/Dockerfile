FROM nginx:alpine

RUN apk update

ENV APP_ROOT /var/www/app
WORKDIR $APP_ROOT

RUN mkdir log

# copy over static assets
COPY public public/

COPY nginx.conf /tmp/docker.nginx
RUN envsubst '$APP_ROOT' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf

EXPOSE 80
# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "nginx", "-g", "daemon off;" ]
