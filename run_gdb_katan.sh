#!/bin/bash
INTERFACE="eth1"

sudo ip link add name ipip0 type ipip external
sudo ip link add name ipip60 type ip6tnl external
sudo ip link set up dev ipip0
sudo ip link set up dev ipip60
sudo tc qd add  dev $INTERFACE clsact
sudo gdb --args ./build/example_grpc/katran_server_grpc \
   	-balancer_prog ./bpf/balancer_kern.o \
   	-default_mac 8a:ed:d6:a6:eb:26 \
   	-forwarding_cores="0,1,2,3" \
   	-healthchecker_prog ./bpf/healthchecking_ipip.o \
   	-intf=$INTERFACE \
   	-ipip_intf=ipip0 \
   	-ipip6_intf=ipip60 \
   	-lru_size=10
