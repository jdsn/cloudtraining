#!/bin/sh
n=$1
if ! [[ $n ]] ; then
    echo "need a number parameter (unique to this system)"
    exit 5
fi
zypper -n in salt-minion
echo master: salt.cloud.suse.de. > /etc/salt/minion.d/master.conf
echo id: training$n.cloud.suse.de. > /etc/salt/minion.d/id.conf
rcsalt-minion restart
