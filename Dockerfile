FROM nginx:1 AS fail

COPY /nginx/config.conf /etc/nginx/conf.d/default.conf
COPY /server/server.pem /etc/nginx/ssl/server.pem
COPY /server/server-key.pem /etc/nginx/ssl/server-key.pem

FROM fail AS success

COPY /ca/ca.pem /usr/local/share/ca-certificates/ca.crt
RUN update-ca-certificates
