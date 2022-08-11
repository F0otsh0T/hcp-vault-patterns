#!/bin/sh

## 

set -e
set -x

## HTML Template

#### AMF N??
echo '<html><body><h1>AMF @ N</h1></body></html>' > workspace/tmp/amf/amf_n.html

#### NEF N??
echo '<html><body><h1>NEF @ N</h1></body></html>' > workspace/tmp/nef/nef_n.html

#### PCF N7 N15
echo '<html><body><h1>PCF @ N7</h1></body></html>' > workspace/tmp/pcf/pcf_n7.html
echo '<html><body><h1>PCF @ N15</h1></body></html>' > workspace/tmp/pcf/pcf_n15.html

#### SMF N11 N29
echo '<html><body><h1>SMF @ N11</h1></body></html>' > workspace/tmp/smf/smf_n11.html
echo '<html><body><h1>SMF @ N29</h1></body></html>' > workspace/tmp/smf/smf_n29.html
