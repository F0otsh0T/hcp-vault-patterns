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
COPY tmp/REPLACECNF /vault/secrets/
COPY www /usr/share/nginx/html/
COPY tmp/REPLACECNF/REPLACEPAGE1.html /usr/share/nginx/html/
COPY tmp/REPLACECNF/REPLACECNF.conf /etc/nginx/conf.d/default.conf
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
COPY tmp/REPLACECNF /vault/secrets/
COPY www /usr/share/nginx/html/
COPY tmp/REPLACECNF/REPLACEPAGE1.html /usr/share/nginx/html/
COPY tmp/REPLACECNF/REPLACEPAGE2.html /usr/share/nginx/html/
COPY tmp/REPLACECNF/REPLACECNF.conf /etc/nginx/conf.d/default.conf
RUN chmod 0644 //usr/share/nginx/html/* &&\
    chmod 0644 /etc/nginx/conf.d/default.conf
WORKDIR /vault/secrets
' > template2.Containerfile

## Format Template

#### AMF
sed 's/REPLACECNF/amf/g' template1.Containerfile \
    | sed 's/REPLACEPAGE1/amf_n/g' \
    > workspace/tmp/amf/amf.Containerfile

#### NEF
sed 's/REPLACECNF/nef/g' template1.Containerfile \
    | sed 's/REPLACEPAGE1/nef_n/g' \
    > workspace/tmp/nef/nef.Containerfile

#### PCF
sed 's/REPLACECNF/pcf/g' template2.Containerfile \
    | sed 's/REPLACEPAGE1/pcf_n7/g' \
    | sed 's/REPLACEPAGE2/pcf_n15/g' \
    > workspace/tmp/pcf/pcf.Containerfile

#### SMF
sed 's/REPLACECNF/smf/g' template2.Containerfile \
    | sed 's/REPLACEPAGE1/smf_n11/g' \
    | sed 's/REPLACEPAGE2/smf_n29/g' \
    > workspace/tmp/smf/smf.Containerfile
