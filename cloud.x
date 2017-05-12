# example configuration for an mkcloud deployment
#
# copy this file to cloud.1 (next is cloud.2 ... aso.) and do modifications
# then run  e.g. ./deploycloud 1 plain

export nodenumber=2
export cloudsource=susecloud7

# disable optional services
export want_ceilometer_proposal=0
export want_aodh_proposal=0
export want_monasca_proposal=0
export want_manila_proposal=0
export want_sahara_proposal=0
export want_barbican_proposal=0
export want_tempest_proposal=0
