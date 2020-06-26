#!/bin/sh
#
# Copyright (C) Nginx, Inc.

TEST=/usr/bin/test
MKDIR=/bin/mkdir
CHOWN=/bin/chown
CHMOD=/bin/chmod
RM=/bin/rm
MV=/bin/mv
SED=/bin/sed
[ -x /sbin/service ] && SERVICE=/sbin/service || SERVICE=/usr/sbin/service
RSYNC=/usr/bin/rsync
NGINX=/usr/sbin/nginx
SSH=/usr/bin/ssh
DIFF=/usr/bin/diff
SUDO=/usr/bin/sudo
GREP=/bin/grep
WC=/usr/bin/wc
USERPREFIX=

ID=`/usr/bin/id -u`

LOCKFILE=/tmp/nginx-sync.lock
CONF=/etc/nginx-sync.conf
BACKUPDIR=/var/lib/nginx-sync
SSHKEY="$HOME/.ssh/id_rsa"
MAXBACKUPCOPY=9
RSYNCVERB="-q"
DIFFVERB="-rq"
MINDEPTH=2
EXIT=0

set_sudo_prefix() {
    # we will need to run all local and remote commands with SUDO,
    # and rsync/ssh as the non-root user if desired, you can whitelist 
    # following commands in /etc/sudoers
    for VAR in TEST MKDIR CHOWN CHMOD RM MV SED SERVICE RSYNC NGINX DIFF; do
        eval $VAR=\"\$SUDO \$$VAR\"
    done

    USERPREFIX="$USER@"
    SSH="$SSH -t"
    RRSYNCPARAMS="-e \"ssh -i $SSHKEY\" --rsync-path=\"$RSYNC\""
}

check_remote_rsync() {
    $SSH $1 $RSYNC --version >/dev/null
    if [ $? -ne 0 ]; then
        echo "rsync binary check failed on $1"
        return 1
        EXIT=2
    else
        return 0
    fi
}

check_remote_nginx() {
   $SSH $1 $NGINX -v >/dev/null
    if [ $? -ne 0 ]; then
        echo "nginx binary check failed on $1"
        return 1
        EXIT=2
    else
        return 0
    fi
}

check_remote_nginx_conf() {
    echo " * Testing nginx config on $1"
    echo

    $SSH $1 $NGINX -t
    if [ $? -ne 0 ]; then
        echo "nginx configuration check failed on $1"
        return 1
        EXIT=2
    else
        return 0
    fi
}

backup_remote_nginx_conf() {
    echo " * Backing up configuration on $1"
    echo

    $SSH $1 "$TEST ! -e $BACKUPDIR && $MKDIR -p $BACKUPDIR"
    if [ $? -ne 0 ]; then
        echo "Cannot create backup directory $BACKUPDIR on $1"
        echo "Please fix the issue manually."
        return 1
        EXIT=2
    fi

    for file in $CONFPATHS; do
        $SSH $1 "$TEST -e $file"

        if [ $? -ne 0 ]; then
            continue
        fi

        $SSH $1 "$RSYNC -aR $RSYNCVERB $EXCLUDEARGS $file $BACKUPDIR"

        if [ $? -ne 0 ]; then
            echo "Failed to backup $file to $BACKUPDIR on $1"
            echo "Please fix the issue manually."
            return 1
            EXIT=2
        fi
    done

    return 0
}

restore_remote_nginx_conf() {
    echo " * Restoring old configuration on $1"
    echo

    for file in $CONFPATHS; do
        $SSH $1 "$TEST -e $file"

        if [ $? -ne 0 ]; then
            continue
        fi

        $SSH $1 "if $TEST -d $BACKUPDIR/$file;\
            then $RSYNC -a $RSYNCVERB --delete $EXCLUDEARGS $BACKUPDIR/$file/ $file;\
            else $RSYNC -a $RSYNCVERB --delete $EXCLUDEARGS $BACKUPDIR/$file $file; fi"

        if [ $? -ne 0 ]; then
            echo "Failed to restore $file on $1"
            echo "Please fix the issue manually."
            return 1
            EXIT=2
        fi
    done

    return 0
}

update_remote_nginx_conf() {
    echo " * Updating configuration on $1"
    echo

    for file in $CONFPATHS; do
        $SSH $1 "$TEST -e $file || $TEST -d `dirname $file`"

        if [ $? -ne 0 ]; then
            continue
        fi

        if $TEST -d $file ; then
            eval $RSYNC -a $RSYNCVERB $RRSYNCPARAMS --delete $EXCLUDEARGS $file/ $1:$file
        elif $TEST -f $file ; then
            eval $RSYNC -a $RSYNCVERB $RRSYNCPARAMS --delete $EXCLUDEARGS $file $1:$file
        else
            continue
        fi

        if [ $? -ne 0 ]; then
            echo "Failed to update $file on $1"
            echo "Please fix the issue manually."
            return 1
            EXIT=2
        fi
    done

    return 0
}

cmp_remote_config() {
    echo " * Comparing local and remote configs"
    echo

    # can do this as non-root
    LOCALCONFDIR=`mktemp -dq /tmp/localconf.XXXXXXXX`
    REMOTECONFDIR=`mktemp -dq /tmp/remoteconf.XXXXXXXX`

    if [ -z "$LOCALCONFDIR" -o -z "$REMOTECONFDIR" ]; then
        echo "Failed to create tmp directories"
        exit 1
    fi

    for file in $CONFPATHS; do
        $RSYNC -aR $RSYNCVERB $EXCLUDEARGS $file $LOCALCONFDIR/ || \
            echo "Failed to copy $file to $LOCALCONFDIR"
        eval $RSYNC -aR $RSYNCVERB $RRSYNCPARAMS $EXCLUDEARGS $1:$file \
            $REMOTECONFDIR/ || \
            echo "Failed to copy $1:$file to $REMOTECONFDIR"
    done

    echo " * Comparing configs on master node and $1:"
    echo
    $DIFF $DIFFVERB $LOCALCONFDIR $REMOTECONFDIR | \
        sed "s|$LOCALCONFDIR|local:|" |sed "s|$REMOTECONFDIR|remote:|"

    $RM -rf $LOCALCONFDIR
    $RM -rf $REMOTECONFDIR

}

post_sync_remote_replace() {
    if [ ! -z "$POSTSYNC" ]; then
        echo " * Adjusting configuration on $1"
        echo

        for r in $POSTSYNC;do
            REPLACESTR=${r##*|}
            FILENAME=${r%%|*}
            if $SSH $1 "$TEST ! -f $FILENAME"; then
                echo "File $FILENAME is listed in POSTSYNC, but does not exist"
                continue
            fi
            echo "Editing file $FILENAME on $1"
            $SSH $1 "$SED -i'' $REPLACESTR $FILENAME"
        done
    fi

    return 0
}

delete_remote_nginx_backup() {
    $SSH $1 "$TEST -e $BACKUPDIR" || return 0

    echo " * Deleting remote backup directory"
    echo

    $SSH $1 "$TEST -d $BACKUPDIR && $RM -rf $BACKUPDIR"

    if [ $? -eq 0 ]; then
        return 0
    else
        echo "Cannot find or delete directory $BACKUPDIR on $1"
        echo "Please fix the issue manually."
        return 1
        EXIT=2
    fi
}

save_local_conf() {
    echo " * Testing local nginx configuration file"
    echo
    $NGINX -t
    if [ $? -ne 0 ]; then
        echo "Config file test failed, exiting"
        exit 1
    fi

    if ! $TEST -e $BACKUPDIR ; then
        $MKDIR -p $BACKUPDIR
        $CHMOD 700 $BACKUPDIR
    fi

    if ! $TEST -d $BACKUPDIR ; then
        echo "$BACKUPDIR exists already and it is not a directory, exiting"
        exit 1
    fi

    $TEST -d $BACKUPDIR/old && $RM -rf $BACKUPDIR/old
    $TEST -d $BACKUPDIR/$MAXBACKUPCOPY && \
        $MV $BACKUPDIR/$MAXBACKUPCOPY $BACKUPDIR/old
    for i in `seq $MAXBACKUPCOPY -1 0`; do
        $TEST -d $BACKUPDIR/$i && $MV $BACKUPDIR/$i $BACKUPDIR/$(($i + 1))
    done

    $MKDIR -p $BACKUPDIR/0
    for file in $CONFPATHS; do
        $RSYNC -aR $RSYNCVERB $EXCLUDEARGS $file $BACKUPDIR/0/
        if [ $? -ne 0 ]; then
            echo "Failed to save local copy of $file directory"
            EXIT=1
        fi
    done

    if [ $EXIT -ne 0 ]; then
        echo "Config backup failed, exiting"
        exit 1
    fi

}

usage() {
    echo
    echo `basename $0` " [-h | -c node_address| -C] [-r] [-d] [-u] [-l logfile]"
    echo `basename $0` " without arguments synchronizes configs from the master node"
    echo "to the slave nodes"
    echo "  -c compares local configs with configs on node_address"
    echo "  -C compares local configs with configs of other nodes"
    echo "  -r enables verbose rsync output"
    echo "  -d enables verbose diff output"
    echo "  -u run without sudo if started from non root user"
    echo "  -l saves script output to the logfile"
    echo
    echo "Prerequisites:"
    echo " * config file /etc/nginx-sync.conf"
    echo " * set up ssh key authentication between nodes"
    echo
    echo "Config variables define a list of values, one per line:"
    echo "NODES - list of the slave nodes"
    echo "CONFPATHS - paths to directories and files to be synchronized"
    echo "EXCLUDE - patterns to be excluded from synchronization"
    echo "POSTSYNC - filename|sed_expression to be run after synchronization"
    echo
    echo "To setup ssh key authentication it is required:"
    echo " * to generate key pair on the master node run"
    echo "   'ssh-keygen -t rsa -b 2048' command from the root user"
    echo " * copy public key /root/.ssh/id_rsa.pub to the slave nodes as"
    echo "   /root/.ssh/authorized_keys"
    echo " * add directive 'PermitRootLogin without-password', that allows"
    echo "   only key authentication to log in with root credentials, to the"
    echo "   /etc/ssh/sshd_config on the slave nodes and reload sshd"
    echo " * to ensure key authentication works run from the master node"
    echo "   ssh <slave node> echo test"
    echo "   command, where <slave node> is slave node's name or ip address"
    echo
    echo " Sample config file content:"
    echo
    echo "NODES=\"node2.example.com"
    echo "node3.example.com\""
    echo "CONFPATHS=\"/etc/nginx"
    echo "/etc/ssl/nginx\""
    echo "EXCLUDE=\"default.conf\""
    echo
    exit
}

init() {
    args=`getopt "c:l:hdruC" $1` || usage
    set -- $args

    for opt
    do
        case "$opt" in
            -h) usage; shift;;
            -c) CMPHOST=$2; shift; shift;;
            -l) LOGFILE=$2; shift; shift;;
            -r) RSYNCVERB="-v"; shift;;
            -d) DIFFVERB="-ru"; shift;;
            -u) UNPRIVILIGED=1; shift;;
            -C) CMPNODES=1; shift;;
            --) shift; break;;
        esac
    done

    if [ -n "$CMPHOST" -a -n "$CMPNODES" ]; then
        echo "-c and -C options are mutually exclusive"
        exit 1
    fi

    unset NODES CONFPATHS EXCLUDE POSTSYNC

    if [ -f $CONF ]; then
        . $CONF
    else
        echo "Configuration file $CONF does not exist."
        usage
    fi

    if [ ! -z "$EXCLUDE" ]; then
        for i in $EXCLUDE; do
            EXCLUDEARGS=`echo "$EXCLUDEARGS --exclude=$i"`
        done
    fi

    if [ -e $LOCKFILE ]; then
        echo "lockfile exists, probably another copy of the script is running"
        exit 1
    else
        touch $LOCKFILE
    fi
    trap 'rm -f $LOCKFILE; echo; echo " * Synchronization ended at" `/bin/date -u`' 0 1 2 3 15
}

check_prerequisites() {
    echo " * Checking prerequisites"
    echo

    if [ -z "$CONFPATHS" ]; then
        echo "Configuration file $CONF does not define variable \$CONFPATHS"
        echo "with paths to synchronize"
        exit 1
    fi

    for file in $CONFPATHS; do
        DEPTH=`echo $file | $GREP -o '/' | $WC -l`
        if [ $DEPTH -lt $MINDEPTH ]; then
            echo "Path $file depth is less than minimal depth $MINDEPTH, exiting"
            exit 1
        fi
    done

    if [ -z "$NODES" -a -z "$CMPHOST" ]; then
        echo "Configuration file $CONF does not define variable \$NODES"
        echo "with names or ip addresses of the other nginx nodes"
        exit 1
    fi

    if [ ! -x $SSH ]; then
        echo "$SSH not found, please install ssh, exiting"
        exit 1
    fi

    if [ ! -x $RSYNC ]; then
        echo "$RSYNC not found, please install rsync, exiting"
        exit 1
    fi

    if [ ! -x $NGINX ]; then
        echo "$NGINX not found, please install nginx-plus, exiting"
        exit 1
    fi

    if [ ! -x $DIFF ]; then
        echo "$DIFF not found, please install diff, exiting"
        exit 1
    fi
}

main() {
    echo " * Synchronization started at" `/bin/date -u`
    echo
    check_prerequisites

    if [ -z "$ID" -o $ID -ne 0 ]; then
        if [ -z "$UNPRIVILIGED" ]; then
            # please be aware that running as non-root and using sudo
            # is no more secure than running as root

            set_sudo_prefix
        fi
    fi 

    if [ -n "$CMPHOST" ]; then
        check_remote_rsync $USERPREFIX$CMPHOST && \
            cmp_remote_config $USERPREFIX$CMPHOST
        exit $EXIT
    fi

    if [ -n "$CMPNODES" ]; then
        for n in $NODES; do
            n=$USERPREFIX$n
            check_remote_rsync $n || continue
            cmp_remote_config $n
        done
        exit $EXIT
    fi

    save_local_conf

    for n in $NODES; do
        n=$USERPREFIX$n
        check_remote_rsync $n || continue
        check_remote_nginx $n || continue
        delete_remote_nginx_backup $n || continue
        backup_remote_nginx_conf $n || continue

        if ! update_remote_nginx_conf $n; then
            restore_remote_nginx_conf $n
            continue
        fi

        if ! post_sync_remote_replace $n; then
            restore_remote_nginx_conf $n
            continue
        fi

        if ! check_remote_nginx_conf $n; then
            restore_remote_nginx_conf $n
            continue
        fi

        if $SSH $n "$SERVICE nginx status > /dev/null"; then
            $SSH $n "$SERVICE nginx reload" && continue
            echo "nginx failed to reload on $n, restoring previous config"
            restore_remote_nginx_conf $n && $SSH $n "$SERVICE nginx reload"
        else
            echo "nginx is not running on $n, skipping reload"
        fi
    done

    exit $EXIT
}

init "$*"

if [ -z "$LOGFILE" ]; then
    main
else
    if [ ! -e $LOGFILE ]; then
        /usr/bin/touch $LOGFILE
        if [ $? -ne 0 ]; then
            echo "Failed to create log file $LOGFILE"
            exit 1
        fi
    elif [ ! -f $LOGFILE ]; then
        echo "$LOGFILE exists and is not a file"
        exit 1
    fi

    main 2>&1 | /usr/bin/tee -ai $LOGFILE
fi
