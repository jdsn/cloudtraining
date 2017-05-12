#!/bin/bash

set -x
log_file=/root/.prepare-mkcloud.log
exec >  >(exec tee -ia $log_file)
exec 2> >(exec tee -ia $log_file >&2)

t=cloudtraining
s=cloud-lvm.sparse
d=deploycloud
lvmsize=800

function action
{
  echo
  echo "$1"
  sleep 1
}

action "Set LVM filter"
sed -i -e 's:^ *filter = .*:filter = [ "r|/dev/.*/by-path/.*|", "r|/dev/.*/by-id/.*|", "r|/dev/fd.*|", "r|/dev/cdrom|", "r|/dev/mapper/cloud-|", "r|/dev/cloud/|", "r|/dev/mapper/drbd-|", "r|/dev/drbd/|", "r|/dev/dm-|", "a/.*/" ]:' /etc/lvm/lvm.conf

action "Set accept_ra (workaround for libvirt bug)"
ra="net.ipv6.conf.all.accept_ra=2"
echo "# Workaround for libvirt bug:
$ra" > /etc/sysctl.d/10-mkcloud.conf
sysctl $ra

pushd ~
action "Getting the automation Git Repository"
curl https://raw.githubusercontent.com/SUSE-Cloud/automation/master/scripts/jenkins/update_automation | bash

action "Fetching Example mkcloud Configuration"
git clone https://github.com/jdsn/cloudtraining.git

action "Setting up Loop Device for Cloud LVM"
pushd ~/$t
if  [[ $(( ($lvmsize + 1) * 1014 * 1024 )) -ge $(df --output=avail -k ./ | tail -n1 ) ]] ; then
  echo "Error: Not enough free space for a sparse file of ${lvmsize}G size."
  exit 1
fi
dd if=/dev/zero of=$s bs=1 count=0 seek=${lvmsize}G
sed -i -e "s/%SPARSE%/$s/g" $d
popd

popd
action "Done"

cat << EOF
1.
  cd ~/$t

2.
Running setuphost function to prepare the machine for mkcloud:
  ./deploycloud 0 setuphost

3.
Deploy clouds with it by using mkcloud targets:

  ./deploycloud 1 plain

Get help from mkcloud:
  ./deploycloud 0 help
or
  ~/github.com/SUSE-Cloud/automation/scripts/mkcloud help
EOF
