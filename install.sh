#!/bin/bash
#    Altai Private Cloud 
#    Copyright (C) GridDynamics Openstack Core Team, GridDynamics
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 2.1 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

receipt="${1}-node.json"
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


