trap 'exit $?' ERR
log () { 
    printf "%s\t***\t%s\n" "$(date +[%FT%T%:z])" "$1" 
} 

DIR=$1
export ROLE=$2
receipt=$3
export ALTAI_LOG=$DIR/install.log

cat  >$DIR/solo.rb <<EOF
file_cache_path "$DIR"
cookbook_path "$DIR/cookbooks"
role_path "$DIR/roles"
EOF

export GIT=`git log --format=%H -n 1`

log "Altai release"
git log -n 1

log "update system"
#yum clean all
#yum -y update

log "install ruby"
yum -y install ruby ruby-devel ruby-ri ruby-rdoc ruby-static rubygems make gcc >> $ALTAI_LOG

log "install chef"
gem install --no-rdoc --no-ri chef-solr >> $ALTAI_LOG

log "install uuid"
gem install --no-rdoc --no-ri uuid >> $ALTAI_LOG

log "run cookbook"
chef-solo -c solo.rb -j "$receipt" -N "$ROLE"


