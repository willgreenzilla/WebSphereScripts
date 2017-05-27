echo stopping nodeagent
call F:\WebSphere\WAS70\AppServer\bin\stopNode.bat

echo applying WAS patch
call F:\WebSphere\UpdateInstaller\update.bat -silent -options "C:\WASPATCH\responsefile.updateWAS.txt"

echo verifying patch installed
call F:\WebSphere\WAS70\AppServer\bin\versioninfo.bat -maintenancePackages

echo starting nodeagent
call F:\WebSphere\WAS70\AppServer\bin\startNode.bat