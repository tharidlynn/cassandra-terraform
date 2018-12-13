#!/usr/bin/env bash
#


sudo apt-get update
sudo apt-get install openjdk-8-jdk -y
sudo echo "deb http://www.apache.org/dist/cassandra/debian 36x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
sudo curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
sudo apt-key adv --keyserver pool.sks-keyservers.net --recv-key A278B781FE4B2BDA
sudo apt-get update
sudo apt-get install cassandra -y

node=$1
if [ -z "${node}" ]; then
    echo "Please specify your node"
    exit 1
fi

sudo service cassandra stop
cd /etc/cassandra
sudo cp cassandra.yaml cassandra.yaml.bak
sudo sed -i "s/cluster_name: 'Test Cluster'/cluster_name: 'My Cluster'/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/seeds: \"127.0.0.1\"/seeds: \"10.0.1.22, 10.0.2.22\"/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/rpc_address: localhost/rpc_address: 0.0.0.0/g" /etc/cassandra/cassandra.yaml
if [ $node == "1" ]; then
sudo sed -i "s/listen_address: localhost/listen_address: 10.0.1.22/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/# broadcast_rpc_address: 1.2.3.4/broadcast_rpc_address: 10.0.1.22/g" /etc/cassandra/cassandra.yaml
elif [ $node == "2" ]; then
sudo sed -i "s/listen_address: localhost/listen_address: 10.0.2.22/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/# broadcast_rpc_address: 1.2.3.4/broadcast_rpc_address: 10.0.2.22/g" /etc/cassandra/cassandra.yaml
elif [ $node == "3" ]; then
sudo sed -i "s/listen_address: localhost/listen_address: 10.0.3.22/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/# broadcast_rpc_address: 1.2.3.4/broadcast_rpc_address: 10.0.3.22/g" /etc/cassandra/cassandra.yaml
else
    echo "$HELP"
    exit 1
fi

sudo rm -rf /var/lib/cassandra/data/system/*
sudo service cassandra start