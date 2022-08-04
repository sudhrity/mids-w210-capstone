FROM nginx

RUN ["/bin/bash", "-c", "rm /etc/localtime"]

RUN ["/bin/bash", "-c", "ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime"]

RUN ["/bin/bash", "-c", "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original"]

COPY nginx.conf.w205 /etc/nginx/nginx.conf.w205

RUN ["/bin/bash", "-c", "ln -s /etc/nginx/nginx.conf.w205 /etc/nginx/nginx.conf"]

COPY w205_cert.pem /etc/nginx/w205_cert.pem

COPY w205.key /etc/nginx/w205.key


