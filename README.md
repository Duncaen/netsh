# WIP DOES NOT WORK AT ALL!!!

### `conf` variables

Configuration options for each network service should be added to the services
`conf` file.

#### DHCP

```sh
IP="dhcp"
DHCP_CLIENT="dhcpcd"
DHCP_RELEASE_ON_STOP="1"
# DHCPCD_OPTS=""
# DHCLIENT_OPTS=""

IP6="dhcp"
DHCP6_CLIENT="dhcpcd"
# DHCPCD6_OPTS=""
# DHCLIENT6_OPTS=""
```

##### dhcpcd

To use `dhcpcd` you have to enable the `dhcpcd` daemon in master mode `-M, --master` or a `dhcpcd` daemon for the specific interface.

##### dhclient

To use `dhclient` you have to enable the `dhcclient` daemon.

#### Static

```sh
IP="static"
ADDRESS="192.168.123/24 192.168.1.87/24"
ROUTES="192.168.0.0/24"
GATEWAY="192.168.1.1"

IP6="static"
ADDRESS6="1234:5678:9abc:def::1/64 1234:3456::123/96"
ROUTES6="abcd::1234"
GATEWAY6="1234:0:123::abcd"
```

#### Network namespace

The `NETNS` variable adds the network service into a network namespace before anything is configured.
Netork namspaces can be created with the `netns-$NAMESPACE` service type or any other tool, the service does not start until the namespace is available.

```sh
NETNS="ns0"
```

### service names

Based on the service type it takes options from the service name if the option is not provided in `conf`.

A service with the name `/etc/sv/ethernet-TOLOLOL` and `INTERFACE="eth0"` in `conf` is the same as a service named `/etc/sv/ethernet-eth0` without `INTERFACE` in `conf`.

#### ethernet

`ethernet-[$NAME]`

#### bridge

`bridge-[$NAME]`

#### bond

`bond-[$NAME]`

#### netns

`netns-[$NAME]`

#### veth

`veth-[[$PAIR_1]-[$PAIR_2]]`

#### Adding a new network service

```sh
cp -r /etc/sv/$TYPE-generic /etc/sv/$TYPE-$NAME_OR_OPTIONS
echo "INTERFACE=eth0" >> /etc/sv/$TYPE-$NAME_OR_OPTIONS/conf
echo "IP=dhcp" >> /etc/sv/$TYPE-$NAME_OR_OPTIONS/conf
ln -s /etc/sv/$TYPE-$NAME_OR_OPTIONS /var/service
```
