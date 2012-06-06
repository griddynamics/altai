#!/bin/bash


function usage() {
    echo "Usage:   $0  master"
    echo "    or   $0  compute"
    exit 1
}

log () { printf "%s\t%s\n" "`date`" "$1"; } >&2

if [[ $# -ne 1 || ("$1" != 'master' && "$1" != 'compute') ]]; then
    usage
fi

receipt="${1}_node.json"
#exec &> >(tee -a install.log)
exec > install.log
log "* update system"
#yum clean all
#yum -y update

log "install ruby"
yum -y install ruby ruby-devel ruby-ri ruby-rdoc ruby-static rubygems make gcc

log "install chef"
gem install --no-rdoc --no-ri chef-solr

log "install uuid"
gem install --no-rdoc --no-ri uuid

log "run cookbook"
chef-solo -c solo.rb -j "$receipt"
