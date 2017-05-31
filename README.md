# WebSphereScripts
Small collection of WebSphere (and Livecycle) scripts.

1) locator-kicker.ksh - Simple script to delete left over .locator file(s) and start Livecycle TCP locators when the server comes online.
2) runWASUpdate.bat - Simple batch file to patch Windows WebSphere servers from a response file.
3) updatewas2 directory:
   * runUpdate.sh - Script to apply patches for WebSphere based on response files. Can also be used to rollback patches. Fix packs/iFix's would be located in a pak folder and all response files and .pak files for this script are located in a /swing directory mounted to all servers for patching and unmounted when complete. Error checking portion is currently broken and I will fix it when I get a chance. Currently I manually move the required response files into the upsatewas2 directory on the /swing filestem (upgrade or rollback) which determines what happens. Response files also need updated with the list of paks being applied/removed. I plan to make this all handled by the script in the future.
   * upgrade dir - Collection of response files for installing patches for my current environment (ND, Forms, DS servers).
   * rollback dir - Collection of response files for rolling back patches for my current environment.
