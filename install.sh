#!/bin/bash

DIR=$(readlink -f $(dirname $0))

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
cat  >$DIR/solo.rb <<EOF
file_cache_path "$DIR"
cookbook_path "$DIR/cookbooks"
role_path "$DIR/roles"
EOF

(cd $DIR
GIT=$(git log HEAD | head -n1 | awk '{print $2}')
echo "DevGrig ${1} ($GIT)" > /etc/devgrid-release 
)

#exec &> >(tee -a install.log)
exec > $DIR/install.log
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


