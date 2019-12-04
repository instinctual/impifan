# impifan
Use IPMI to monitor and control the fans on a Dell R7910 server through the iDRAC using raw commands

ENABLE/DISABLE Third-Party PCIe card based default system fan response:

Enable the "IPMI over LAN" in iDRAC of the target machine, this can ben done via iDRAC Web GUI or BIOS Setup. 
Set Third-Party PCIe Card Default Cooling Response Logic To Disabled

ipmitool -I lanplus -H -U -P raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x01 0x00 0x00 

Set Third-Party PCIe Card Default Cooling Response Logic To Enabled

ipmitool -I lanplus -H -U -P raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x00 0x00 0x00 

Get Third-Party PCIe Card Default Cooling Response Logic Status

ipmitool -I lanplus -H -U -P raw 0x30 0xce 0x01 0x16 0x05 0x00 0x00 0x00 

The response data is:

16 05 00 00 00 05 00 01 00 00 (Disabled)

﻿16 05 00 00 00 05 00 00 00 00 (Enabled)

GIT clone to /opt/instinctual/
mv ipmifan.service to /etc/systemd/system/
systemctl enable ipmifan.service
