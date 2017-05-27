#!/bin/ksh

####################################################################################################
##### locator-kicker.ksh                                                                      ######
##### v0.1 - 7/8/2015                                                                         ######
##### will green                                                                              ######
####################################################################################################
##### Starts the lc tcp locators (called from inittab) on boot before WAS is booted           ######
####################################################################################################

# Variables
dsdotlocator="/LiveCycleDS/lib/caching/.locator"
formsdotlocator="/LiveCycleForms/lib/caching/.locator"

# DS: Check for .locator, delete if found
if [ -f "$dsdotlocator" ]
then
	rm $dsdotlocator
fi

# FORMS: Check for .locator, delete if found
if [ -f "$formsdotlocator" ]
then
	rm $formsdotlocator
fi

# Start DS locator
ksh /LiveCycleDS/lib/caching/startlocator.sh

# Start FORMS locator
ksh /LiveCycleForms/lib/caching/startlocator.sh
