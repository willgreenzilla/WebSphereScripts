#!/bin/ksh

####################################################################################################
##### runUpdate.sh                                                                            ######
##### v3.1 - 05/10/2017                                                                       ######
##### will green / karen dapsis                                                               ######
####################################################################################################
##### Script to apply / rollback WebSphere patches                                            ######
#####                                                                                         ######
##### Use example: sudo ./runUpdate.sh                                                        ######
####################################################################################################

# Determine if root or not, kick if not root, continue if root
WHOAMI=$(/usr/bin/whoami)
if [[ $WHOAMI != "root"  ]] ; then
    echo "Exiting, you need to be the root user"
fi

# Set variable(s)
SWINGDIR="/swing"
ERRORCOUNTER=0

# Set umask
umask 022

# Kill WAS
echo "Shutting down WAS......\n"
/usr/local/scripts/manageWas.sh -s all -a stop
echo "\nWAS has been STOPPED!\n"

# Check for /swing directory, if missing, mount /swing
if [[ ! -d "$SWINGDIR/updatewas2" ]]; then
    print "Mounting the /swing directory......"
    /usr/sbin/mount opnim02:/export/repository/swing /swing

else
    print "SWING DIR is already mounted! Moving on......\n"

fi

# Gather response files
RESPONSE_FILES=$(ls -p $SWINGDIR/updatewas2/ | grep -v / | grep resp)

# Loop through response files for WAS, WASDS, WASND
for RESPONSE_FILE in $RESPONSE_FILES
do
    WASINSTALL_DIR=$(cat $SWINGDIR/updatewas2/$RESPONSE_FILE | grep product.location | awk -F '=' '{ print $2 }' | sed 's/\"//g')
    if [[ -d $WASINSTALL_DIR ]]; then
        # Set update install to variable
        COMMAND="/usr/IBM/WebSphere/UpdateInstaller/update.sh -silent -options $SWINGDIR/updatewas2/$RESPONSE_FILE"

        # Run update install
        echo "Executing: $COMMAND"
        $COMMAND

        # Determine log file location, set variables
        echo "Checking for INSTCONFSUCCESS in the updatelog.txt"
        FIXFILE=$(cat $SWINGDIR/updatewas2/$RESPONSE_FILE | grep maintenance.package | awk -F '=' '{ print $2 }' | sed 's/\"//g')
        FIXFILE=$(basename $FIXFILE)
        FIXNOPAK=$(echo $FIXFILE | awk -F. '{print $1"."$2"."$3"."$4}')
        LOGFILE="$WASINSTALL_DIR/logs/update/${FIXNOPAK}.install/updatelog.txt"

        # Check for error code, if no error, report success, if error, report fail (NEEDS FIXED, FALSE SUCCESS MESSAGES)
        if [[ $? -eq 0 ]] ; then
	    echo "\nUpdate of $FIXFILE to $WASINSTALL_DIR was SUCCESSFUL!\n"
            # Verification of successful install, check versionInfo maintenancePackage script for installed packs
            $WASINSTALL_DIR/bin/versionInfo.sh -maintenancePackages | tail -n21 | awk '/Maintenance Package ID/{n=NR+3} n>=NR'
        else
	    ERRORCOUNTER=$((ERRORCOUNTER+1))
	    echo "!!! >> Update of $FIXFILE to $WASINSTALL_DIR has FAILED << !!!"
	    echo "CHECK LOG: $LOGFILE"
        fi
    fi
done

# Start WAS if no erorrs had been detected
if [ $ERRORCOUNTER -eq 0 ]; then
    echo "\nStarting WAS apps......\n"
   /usr/local/scripts/manageWas.sh -s boot -a start
   echo "\nUnmounting the /swing directory......\n"
   /usr/sbin/umount /swing

else
    echo "Correct the << $ERRORCOUNTER >> indicated ERROR(S) and then run runUpdate script again to patch and then\nstart WAS apps manually by using the below command:\n/usr/local/scripts/manageWas.sh -s boot -a start\n"
fi

echo "\n>>>>> DONE <<<<<"

exit
