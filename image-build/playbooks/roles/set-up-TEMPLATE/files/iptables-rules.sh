#!/bin/sh
IPT="/sbin/iptables"

# By default, drop everything except outgoing traffic
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT


## General Rules
################

# Allow incoming and outgoing for loopback interfaces
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# ICMP rule
$IPT -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# Allow established connections:
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


## SPECIFIC PORTS FOR THE COMPONENT - THE FOLLOWING ARE EXAMPLES
################################################################

# Allow HTTP and HTTPS
$IPT -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
$IPT -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
