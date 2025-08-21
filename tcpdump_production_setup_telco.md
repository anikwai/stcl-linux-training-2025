# tcpdump Production Setup for Telco Engineers

## Table of Contents
- [Production Environment Considerations](#production-environment-considerations)
- [Infrastructure Requirements](#infrastructure-requirements)
- [Installation and Configuration](#installation-and-configuration)
- [Telco-Specific Use Cases](#telco-specific-use-cases)
- [Monitoring and Alerting](#monitoring-and-alerting)
- [Performance Optimization](#performance-optimization)
- [Security and Compliance](#security-and-compliance)
- [Automation and Orchestration](#automation-and-orchestration)
- [Troubleshooting Common Issues](#troubleshooting-common-issues)
- [Integration with Telco Systems](#integration-with-telco-systems)

## Production Environment Considerations

### High-Volume Network Environments
Telco networks handle massive traffic volumes requiring specialized configurations:

```bash
# High-performance capture with large buffers
sudo tcpdump -i any -B 16384 -w /var/captures/production_$(date +%Y%m%d_%H%M%S).pcap

# Ring buffer for continuous capture (100MB files, keep 50 files)
sudo tcpdump -i any -C 100 -W 50 -w /var/captures/rotating_capture.pcap
```

### Network Interface Optimization
```bash
# Check interface capabilities
ethtool -k eth0

# Disable unnecessary features for packet capture
sudo ethtool -K eth0 gso off tso off ufo off gro off lro off

# Increase ring buffer sizes
sudo ethtool -G eth0 rx 4096 tx 4096
```

## Infrastructure Requirements

### Hardware Specifications

#### Minimum Requirements (Small Cell Sites)
- **CPU**: 4 cores, 2.4GHz
- **RAM**: 8GB
- **Storage**: 500GB NVMe SSD
- **Network**: 1Gbps NICs

#### Recommended Requirements (Core Network)
- **CPU**: 16+ cores, 3.0GHz+
- **RAM**: 32GB+
- **Storage**: 2TB+ NVMe SSD RAID
- **Network**: 10Gbps+ NICs with SR-IOV support

#### Enterprise/Carrier Grade
- **CPU**: 32+ cores, high-frequency
- **RAM**: 64GB+
- **Storage**: 10TB+ enterprise NVMe
- **Network**: 25/40/100Gbps NICs
- **Additional**: Hardware timestamping, DPDK support

### Storage Architecture
```bash
# Create dedicated partition for captures
sudo mkdir -p /var/captures
sudo mount /dev/sdb1 /var/captures

# Set up automated cleanup
echo "find /var/captures -name '*.pcap' -mtime +7 -delete" | sudo crontab -e
```

## Installation and Configuration

### Enterprise Linux Distribution Setup
```bash
# RHEL/CentOS Enterprise Setup
sudo yum groupinstall "Development Tools"
sudo yum install tcpdump libpcap-devel wireshark-cli

# Ubuntu/Debian Setup
sudo apt update
sudo apt install tcpdump libpcap-dev tshark build-essential

# Install additional tools for Telco environments
sudo yum install nmap-ncat socat iperf3 mtr
```

### System Tuning for Production
```bash
# Kernel network buffer tuning
echo 'net.core.rmem_max = 268435456' | sudo tee -a /etc/sysctl.conf
echo 'net.core.rmem_default = 268435456' | sudo tee -a /etc/sysctl.conf
echo 'net.core.wmem_max = 268435456' | sudo tee -a /etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 5000' | sudo tee -a /etc/sysctl.conf

# Apply changes
sudo sysctl -p
```

### User and Permission Setup
```bash
# Create dedicated capture user
sudo useradd -r -s /bin/false capture-user
sudo usermod -a -G wireshark capture-user

# Set up sudo rules for capture operations
echo 'capture-user ALL=(ALL) NOPASSWD: /usr/bin/tcpdump' | sudo tee /etc/sudoers.d/tcpdump
```

## Telco-Specific Use Cases

### 1. SIP/VoIP Traffic Analysis
```bash
# Capture SIP signaling traffic
sudo tcpdump -i any -n 'port 5060 or port 5061' -w sip_capture.pcap

# RTP media stream capture
sudo tcpdump -i any -n 'portrange 10000-20000' -w rtp_capture.pcap

# Combined SIP and RTP with time correlation
sudo tcpdump -i any -n '(port 5060 or port 5061 or portrange 10000-20000)' \
  -w voip_full_capture_$(date +%Y%m%d_%H%M%S).pcap
```

### 2. Diameter Protocol Monitoring
```bash
# Capture Diameter traffic (typically port 3868)
sudo tcpdump -i any -n 'port 3868' -w diameter_capture.pcap

# Multi-port Diameter capture for different applications
sudo tcpdump -i any -n 'port 3868 or port 3869 or port 3870' -w diameter_multi.pcap
```

### 3. GTP Tunnel Analysis (4G/5G Core)
```bash
# GTP-C control plane (port 2123)
sudo tcpdump -i any -n 'port 2123' -w gtp_control.pcap

# GTP-U user plane (port 2152)
sudo tcpdump -i any -n 'port 2152' -w gtp_user.pcap

# Combined GTP capture with inner packet analysis
sudo tcpdump -i any -n '(port 2123 or port 2152)' -vv -w gtp_full.pcap
```

### 4. RADIUS Authentication Monitoring
```bash
# RADIUS authentication and accounting
sudo tcpdump -i any -n '(port 1812 or port 1813)' -w radius_capture.pcap

# CoA (Change of Authorization) traffic
sudo tcpdump -i any -n 'port 3799' -w radius_coa.pcap
```

### 5. BGP Route Monitoring
```bash
# BGP session monitoring
sudo tcpdump -i any -n 'port 179' -w bgp_capture.pcap

# BGP with specific peer analysis
sudo tcpdump -i any -n 'port 179 and host 10.0.0.1' -w bgp_peer_capture.pcap
```

## Monitoring and Alerting

### Real-time Monitoring Scripts
```bash
#!/bin/bash
# /usr/local/bin/telco-monitor.sh

# Monitor for SIP failures
monitor_sip_failures() {
    sudo tcpdump -i any -n -l 'port 5060' | while read line; do
        if echo "$line" | grep -q "SIP/2.0 [4-6][0-9][0-9]"; then
            echo "$(date): SIP Error detected: $line" | logger -t SIP_MONITOR
            # Send alert to monitoring system
            curl -X POST "http://monitoring-server/api/alert" \
                 -d "service=SIP&message=Error detected&details=$line"
        fi
    done
}

# Monitor for high error rates
monitor_error_rates() {
    while true; do
        errors=$(sudo tcpdump -i any -n -c 1000 'icmp[icmptype] != icmp-echo and icmp[icmptype] != icmp-echoreply' 2>/dev/null | wc -l)
        if [ "$errors" -gt 50 ]; then
            echo "$(date): High error rate detected: $errors errors in 1000 packets" | logger -t ERROR_MONITOR
        fi
        sleep 60
    done
}
```

### Integration with SNMP Monitoring
```bash
# Create SNMP extend for packet capture status
echo 'extend tcpdump-status /usr/local/bin/check-tcpdump-status.sh' | sudo tee -a /etc/snmp/snmpd.conf

# Script to check tcpdump processes
cat << 'EOF' | sudo tee /usr/local/bin/check-tcpdump-status.sh
#!/bin/bash
active_captures=$(pgrep tcpdump | wc -l)
if [ "$active_captures" -eq 0 ]; then
    echo "0"  # No active captures
else
    echo "1"  # Active captures running
fi
EOF

sudo chmod +x /usr/local/bin/check-tcpdump-status.sh
```

## Performance Optimization

### CPU Affinity and Process Isolation
```bash
# Pin tcpdump to specific CPU cores
sudo taskset -c 0,1 tcpdump -i eth0 -w capture.pcap

# Use isolcpus kernel parameter for dedicated cores
# Add to GRUB: isolcpus=2,3,4,5

# Start tcpdump on isolated cores
sudo taskset -c 2 tcpdump -i eth0 -w high_perf_capture.pcap
```

### Memory Management
```bash
# Increase memory limits for capture processes
echo 'capture-user soft memlock unlimited' | sudo tee -a /etc/security/limits.conf
echo 'capture-user hard memlock unlimited' | sudo tee -a /etc/security/limits.conf

# Use huge pages for better performance
echo 1024 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
```

### Network Interface Tuning
```bash
# Optimize for packet capture
sudo ethtool -C eth0 rx-usecs 0 rx-frames 1
sudo ethtool -G eth0 rx 4096

# Enable hardware timestamping if available
sudo ethtool -T eth0
sudo tcpdump -i eth0 --time-stamp-type host -w timestamped_capture.pcap
```

## Security and Compliance

### Access Control
```bash
# Create capture groups with restricted access
sudo groupadd capture-operators
sudo usermod -a -G capture-operators telco-engineer

# Secure capture directory
sudo mkdir -p /secure/captures
sudo chown root:capture-operators /secure/captures
sudo chmod 750 /secure/captures
```

### Data Encryption and Protection
```bash
# Encrypt captures at rest
sudo cryptsetup luksFormat /dev/sdc
sudo cryptsetup luksOpen /dev/sdc secure_captures
sudo mkfs.ext4 /dev/mapper/secure_captures
sudo mount /dev/mapper/secure_captures /secure/captures

# Automated encryption for sensitive captures
encrypt_capture() {
    local capture_file="$1"
    gpg --cipher-algo AES256 --compress-algo 1 --symmetric --output "${capture_file}.gpg" "$capture_file"
    shred -vfz -n 3 "$capture_file"
}
```

### Audit Logging
```bash
# Enable auditd for capture activities
sudo auditctl -w /usr/bin/tcpdump -p x -k packet_capture
sudo auditctl -w /var/captures -p wa -k capture_files

# Custom audit rule for sensitive protocols
sudo auditctl -a always,exit -F arch=b64 -S socket -F a0=2 -k network_access
```

## Automation and Orchestration

### Automated Capture Management
```bash
#!/bin/bash
# /usr/local/bin/auto-capture-manager.sh

CAPTURE_DIR="/var/captures"
MAX_DISK_USAGE=80
RETENTION_DAYS=30

# Function to start protocol-specific captures
start_telco_captures() {
    # SIP capture
    sudo tcpdump -i any -n 'port 5060 or port 5061' -C 50 -W 20 \
        -w "${CAPTURE_DIR}/sip_$(date +%Y%m%d).pcap" &
    
    # Diameter capture
    sudo tcpdump -i any -n 'port 3868' -C 50 -W 20 \
        -w "${CAPTURE_DIR}/diameter_$(date +%Y%m%d).pcap" &
    
    # GTP capture
    sudo tcpdump -i any -n 'port 2123 or port 2152' -C 100 -W 10 \
        -w "${CAPTURE_DIR}/gtp_$(date +%Y%m%d).pcap" &
}

# Disk space management
cleanup_old_captures() {
    current_usage=$(df "$CAPTURE_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$current_usage" -gt "$MAX_DISK_USAGE" ]; then
        find "$CAPTURE_DIR" -name "*.pcap" -mtime +$RETENTION_DAYS -delete
    fi
}

# Health check function
check_capture_health() {
    for proto in sip diameter gtp; do
        if ! pgrep -f "${proto}_" > /dev/null; then
            echo "$(date): $proto capture not running, restarting..." | logger -t CAPTURE_HEALTH
            # Restart specific capture
        fi
    done
}
```

### Integration with Configuration Management
```yaml
# Ansible playbook example
---
- name: Deploy tcpdump for Telco environment
  hosts: telco_nodes
  become: yes
  tasks:
    - name: Install tcpdump and dependencies
      package:
        name: 
          - tcpdump
          - libpcap-devel
          - wireshark-cli
        state: present

    - name: Create capture directories
      file:
        path: /var/captures
        state: directory
        owner: capture-user
        group: capture-operators
        mode: '0755'

    - name: Deploy capture scripts
      template:
        src: auto-capture-manager.sh.j2
        dest: /usr/local/bin/auto-capture-manager.sh
        mode: '0755'

    - name: Configure systemd service
      template:
        src: tcpdump-capture.service.j2
        dest: /etc/systemd/system/tcpdump-capture.service
      notify: reload systemd
```

### Container Deployment
```dockerfile
# Dockerfile for containerized packet capture
FROM centos:8

RUN yum update -y && \
    yum install -y tcpdump libpcap wireshark-cli && \
    yum clean all

RUN useradd -r -s /bin/false capture-user

COPY capture-scripts/ /usr/local/bin/
COPY config/ /etc/capture/

VOLUME ["/captures"]

USER capture-user
CMD ["/usr/local/bin/start-telco-captures.sh"]
```

## Troubleshooting Common Issues

### High Packet Loss
```bash
# Check for dropped packets
sudo netstat -i
sudo cat /proc/net/dev

# Monitor system resources during capture
sudo iostat -x 1 &
sudo tcpdump -i any -w test_capture.pcap &
sudo top -p $(pgrep tcpdump)
```

### Performance Bottlenecks
```bash
# Identify bottlenecks
sudo perf top -p $(pgrep tcpdump)

# Check for buffer overruns
dmesg | grep -i "receive buffer"

# Monitor capture statistics
sudo tcpdump -i any -c 10000 -q > /dev/null
# Check the packet statistics at the end
```

### Storage Issues
```bash
# Monitor disk I/O during capture
sudo iotop -p $(pgrep tcpdump)

# Check filesystem performance
sudo fio --name=random-write --ioengine=posixaio --rw=randwrite \
    --bs=4k --numjobs=1 --size=1g --iodepth=1 --runtime=60 \
    --time_based --directory=/var/captures
```

## Integration with Telco Systems

### OSS/BSS Integration
```python
#!/usr/bin/env python3
# Integration with OSS systems

import subprocess
import requests
import json
from datetime import datetime

class TelcoPacketCapture:
    def __init__(self, oss_endpoint, api_key):
        self.oss_endpoint = oss_endpoint
        self.api_key = api_key
        
    def start_targeted_capture(self, subscriber_id, duration=300):
        """Start capture for specific subscriber"""
        # Get subscriber context from OSS
        subscriber_info = self.get_subscriber_context(subscriber_id)
        
        # Build capture filter based on subscriber info
        capture_filter = self.build_subscriber_filter(subscriber_info)
        
        # Start capture
        capture_cmd = [
            'sudo', 'tcpdump', '-i', 'any', '-n',
            capture_filter,
            '-w', f'/var/captures/subscriber_{subscriber_id}_{datetime.now().strftime("%Y%m%d_%H%M%S")}.pcap'
        ]
        
        return subprocess.Popen(capture_cmd)
    
    def get_subscriber_context(self, subscriber_id):
        """Retrieve subscriber information from OSS"""
        response = requests.get(
            f"{self.oss_endpoint}/subscriber/{subscriber_id}",
            headers={'Authorization': f'Bearer {self.api_key}'}
        )
        return response.json()
```

### Network Function Integration
```bash
# Integration with VNF/CNF environments
# Capture from container network interfaces
sudo tcpdump -i docker0 -w container_traffic.pcap

# Kubernetes pod network capture
kubectl exec -it packet-capture-pod -- tcpdump -i eth0 -w /captures/pod_traffic.pcap

# Service mesh traffic capture (Istio/Envoy)
sudo tcpdump -i any 'port 15001 or port 15006' -w service_mesh.pcap
```

### SIEM Integration
```bash
#!/bin/bash
# Send capture events to SIEM

send_to_siem() {
    local event_type="$1"
    local details="$2"
    
    curl -X POST "https://siem-server/api/events" \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer $SIEM_API_KEY" \
         -d "{
               \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)\",
               \"event_type\": \"$event_type\",
               \"source\": \"tcpdump\",
               \"details\": \"$details\"
             }"
}

# Monitor for security events
sudo tcpdump -i any -n -l | while read line; do
    if echo "$line" | grep -E "(flood|scan|attack)"; then
        send_to_siem "security_event" "$line"
    fi
done
```

## Best Practices Summary

### Production Deployment Checklist
- [ ] Hardware sizing based on traffic volume
- [ ] Network interface optimization
- [ ] Storage architecture with adequate IOPS
- [ ] User access controls and permissions
- [ ] Monitoring and alerting setup
- [ ] Automated capture management
- [ ] Security compliance measures
- [ ] Documentation and runbooks
- [ ] Disaster recovery procedures
- [ ] Integration with existing tools

### Key Performance Indicators (KPIs)
- Packet capture rate vs. network throughput
- Packet loss percentage
- Storage utilization and retention
- System resource utilization
- Alert response times
- Mean time to resolution (MTTR)

This production setup guide provides Telco engineers with enterprise-grade deployment strategies for tcpdump in high-volume, mission-critical environments.
