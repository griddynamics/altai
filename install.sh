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
    echo "Usage:   $0  [master|compute]"
    echo "      master  - install controlling node"
    echo "      compute - install compute node"
    exit 1
}

if [ $1 = '--accept-eula' ]; then 
    shift
else 
    cat ./EULA.txt
    read -p "If you agree with the terms, please click y to proceed, otherwise click n to terminate the installation process: " -r -n 1
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
  
if [[ $# -ne 1 || ("$1" != 'master' && "$1" != 'compute') ]]
then
    usage
fi

receipt="${1}-node.json"
touch /var/log/altai-install.log
chmod 600 /var/log/altai-install.log
./_install.sh "$DIR" "$1" "$receipt" 2>&1 | tee -a /var/log/altai-install.log


exit ${PIPESTATUS[0]} 
