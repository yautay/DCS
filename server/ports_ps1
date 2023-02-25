#DCS = 10308 TCP/UDP + 8088 TCP(GUI)
#TacView = 42674 TCP(telemetry) + 42675 TCP(control)

#SRS transponder = 10712 UDP
#SRS = 5004TCP , 5002 TCP

#lotATC Server = 10310 TCP
#lotATC json communications = 8081 TCP (ATC_link)

#TS = 9987 udp(voice) / 30033 tcp(filetransfer)/ 10011 tcp(server_opt)/ 41144 tcp(opt_???)



#DCS_SERVER

# DCS TCP inbound rules
New-NetFirewallRule -DisplayName "DCS TCP Inbound" -Direction Inbound -LocalPort 10308 -Protocol TCP -Action Allow

# DCS UDP inbound rules
New-NetFirewallRule -DisplayName "DCS UDP Inbound" -Direction Inbound -LocalPort 10308 -Protocol UDP -Action Allow

# DCS WebGUI TCP inbound  rules
New-NetFirewallRule -DisplayName "DCS WebGUI TCP Inbound" -Direction Inbound -LocalPort 8088 -Protocol TCP -Action Allow


#TAC_VIEW

# DCS TacView Realtime Telemetry
New-NetFirewallRule -DisplayName "DCS TacView Realtime Telemetry Inbound" -Direction Inbound -LocalPort 42674 -Protocol TCP -Action Allow

# DCS TacView Remote Control
New-NetFirewallRule -DisplayName "DCS TacView Remote Control Inbound" -Direction Inbound -LocalPort 42675 -Protocol TCP -Action Allow

#SRS

# DCS SRS TCP
New-NetFirewallRule -DisplayName "DCS SRS TCP" -Direction Inbound -LocalPort 5004 -Protocol TCP -Action Allow

# DCS SRS TCP2
New-NetFirewallRule -DisplayName "DCS SRS TCP2" -Direction Inbound -LocalPort 5002 -Protocol TCP -Action Allow

# DCS SRS Transponder
New-NetFirewallRule -DisplayName "DCS SRS Transponder" -Direction Inbound -LocalPort 10712 -Protocol UDP -Action Allow

#LotATC

# DCS LotATC Server
New-NetFirewallRule -DisplayName "DCS LotATC Server" -Direction Inbound -LocalPort 10310 -Protocol TCP -Action Allow

# DCS LotATC Server Json
New-NetFirewallRule -DisplayName "DCS LotATC Server Json" -Direction Inbound -LocalPort 8081 -Protocol TCP -Action Allow

# TS

# DCS TeamSpeak Voice
New-NetFirewallRule -DisplayName "DCS TeamSpeak Voice" -Direction Inbound -LocalPort 9987 -Protocol UDP -Action Allow

# DCS TeamSpeak Files
New-NetFirewallRule -DisplayName "DCS TeamSpeak Files" -Direction Inbound -LocalPort 30033 -Protocol TCP -Action Allow

# DCS TeamSpeak Serverlist
New-NetFirewallRule -DisplayName "DCS TeamSpeak List" -Direction Inbound -LocalPort 10011 -Protocol TCP -Action Allow


