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

if [[ $# -ne 1 || ("$1" != 'master' && "$1" != 'compute') ]]
then
    usage
fi

receipt="${1}-node.json"
./_install.sh "$DIR" "$1" "$receipt" 2>&1 | tee -a $DIR/install.log

exit ${PIPESTATUS[0]} 
