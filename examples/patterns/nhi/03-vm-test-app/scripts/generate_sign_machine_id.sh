#!/bin/bash

name=$1
commonname=$name
country=AU
organization=HashiCorp

if [ -z "$name" ]
then
    echo "Argument not present."
    echo "Useage $0 [common name]"

    exit 99
fi

echo "generating machine-id key request for $name"

# generate private key
openssl genrsa -des3 -out $name.key 2048 -noout

# generate machine-d certificate signing request
echo "generating certificate request for $name"
openssl req -new -key $name.key -out $name.csr \
    -subj "/C=$country/O=$organization/CN=$commonname/"

echo "---------------------------"
echo "-----Below is your CSR-----"
echo "---------------------------"
echo
cat $name.csr

echo
echo "---------------------------"
echo "-----Below is your Key-----"
echo "---------------------------"
echo
cat $name.key
