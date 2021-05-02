#!/bin/sh
IPT="/sbin/iptables"

echo -n "Loading iptables rules..."

# Reset policies and flush old rules
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -t nat --flush
$IPT -t mangle --flush
$IPT --flush
$IPT --delete-chain


echo "rules reset."
