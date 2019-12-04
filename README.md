
# impifan
Use IPMI to monitor and control the fans on a Dell R7910 server through the iDRAC using raw commands

ENABLE/DISABLE Third-Party PCIe card based default system fan response:
ssh to iDRAC interface as root with iDRAC password.
To check current status:

    racadm get system.thermalsettings.ThirdPartyPCIFanResponse

To Disable response:

    racadm set system.thermalsettings.ThirdPartyPCIFanResponse 0

To Enable response:

    racadm set system.thermalsettings.ThirdPartyPCIFanResponse 1

GIT clone to /opt/instinctual/
mv ipmifan.service to /etc/systemd/system/
systemctl enable ipmifan.service

