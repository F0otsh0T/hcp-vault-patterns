#!/bin/sh

## 

set -e
set -x

## HTML Template

#### AMF SELF
echo '<html><body><h1>AMF @ SELF</h1></body></html>' > workspace/tmp/amf/amf.html

#### NEF SELF
echo '<html><body><h1>NEF @ SELF</h1></body></html>' > workspace/tmp/nef/nef.html

#### PCF SELF N7 N15
echo '<html><body><h1>PCF @ SELF</h1></body></html>' > workspace/tmp/pcf/pcf.html
echo '<html><body><h1>PCF @ N7</h1></body></html>' > workspace/tmp/pcf/pcf_n7.html
echo '<html><body><h1>PCF @ N15</h1></body></html>' > workspace/tmp/pcf/pcf_n15.html

#### SMF SELF N11 N29
echo '<html><body><h1>SMF @ SELF</h1></body></html>' > workspace/tmp/smf/smf.html
echo '<html><body><h1>SMF @ N11</h1></body></html>' > workspace/tmp/smf/smf_n11.html
echo '<html><body><h1>SMF @ N29</h1></body></html>' > workspace/tmp/smf/smf_n29.html
