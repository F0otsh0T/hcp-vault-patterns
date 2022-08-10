#!/bin/sh

## 

set -e
set -x

## Containerfile Template

#### 1 Service
echo '
FROM nginx:1.23.1
LABEL type="mtlsxsign"
WORKDIR /tmp
USER root
RUN mkdir -p /vault/secrets
COPY tmp/SUBCNF /vault/secrets/
COPY www /usr/share/nginx/html/
COPY tmp/SUBCNF/ONEWWW.html /usr/share/nginx/html/
COPY tmp/SUBCNF/SUBCNF.conf /etc/nginx/conf.d/default.conf
RUN chmod 0644 //usr/share/nginx/html/* &&\
    chmod 0644 /etc/nginx/conf.d/default.conf
WORKDIR /vault/secrets
' > template1.Containerfile

#### 2 Services
echo '
FROM nginx:1.23.1
LABEL type="mtlsxsign"
WORKDIR /tmp
USER root
RUN mkdir -p /vault/secrets
COPY tmp/SUBCNF /vault/secrets/
COPY www /usr/share/nginx/html/
COPY tmp/SUBCNF/ONEWWW.html /usr/share/nginx/html/
COPY tmp/SUBCNF/TWOWWW.html /usr/share/nginx/html/
COPY tmp/SUBCNF/SUBCNF.conf /etc/nginx/conf.d/default.conf
RUN chmod 0644 //usr/share/nginx/html/* &&\
    chmod 0644 /etc/nginx/conf.d/default.conf
WORKDIR /vault/secrets
' > template2.Containerfile

#### 3 Services
echo '
FROM nginx:1.23.1
LABEL type="mtlsxsign"
WORKDIR /tmp
USER root
RUN mkdir -p /vault/secrets
COPY tmp/SUBCNF /vault/secrets/
COPY www /usr/share/nginx/html/
COPY tmp/SUBCNF/ONEWWW.html /usr/share/nginx/html/
COPY tmp/SUBCNF/TWOWWW.html /usr/share/nginx/html/
COPY tmp/SUBCNF/THREEWWW.html /usr/share/nginx/html/
COPY tmp/SUBCNF/SUBCNF.conf /etc/nginx/conf.d/default.conf
RUN chmod 0644 //usr/share/nginx/html/* &&\
    chmod 0644 /etc/nginx/conf.d/default.conf
WORKDIR /vault/secrets
' > template3.Containerfile

## Format Template

#### AMF
sed 's/SUBCNF/amf/g' template1.Containerfile \
    | sed 's/ONEWWW/amf/g' \
    > workspace/tmp/amf/amf.Containerfile

#### NEF
sed 's/SUBCNF/nef/g' template1.Containerfile \
    | sed 's/ONEWWW/nef/g' \
    > workspace/tmp/nef/nef.Containerfile

#### PCF
sed 's/SUBCNF/pcf/g' template3.Containerfile \
    | sed 's/ONEWWW/pcf/g' \
    | sed 's/TWOWWW/pcf_n7/g' \
    | sed 's/THREEWWW/pcf_n15/g' \
    > workspace/tmp/pcf/pcf.Containerfile

#### SMF
sed 's/SUBCNF/smf/g' template3.Containerfile \
    | sed 's/ONEWWW/smf/g' \
    | sed 's/TWOWWW/smf_n11/g' \
    | sed 's/THREEWWW/smf_n29/g' \
    > workspace/tmp/smf/smf.Containerfile
