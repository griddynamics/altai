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

define :try do
  bash "try #{params[:name]}" do
    environment params[:environment]
    code <<-EOH
        CODE() {
	    #{params[:code]}
	}

	trace() { trap 'ERR=$?' ERR; set -Ex; $1 2>&1; set +Ex; trap ERR; } 2>&-
	try() {
	    local output=$( trace $1 )
	    if [[ "$output" =~ "ERR=" ]] 
	    then
		echo -e "\e[1m\e[31m ERR \e[37m$1\e[0m"
		exitcode=`echo "$output" | perl -ne 'print /ERR=(.*)/'`   
		echo "$output" | sed $'s/.*ERR=\(.*\)/\a\033[36mEXIT CODE: \\1\033[0m/g'
		exit $exitcode
	    else
		echo "$output" >> $ALTAI_LOG
	    fi
	}
	try CODE
    EOH
    end
end
