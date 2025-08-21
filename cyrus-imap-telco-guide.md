# Cyrus IMAP Server Guide for Telco Engineers and ccTLD Administrators

## Table of Contents
1. [Overview](#overview)
2. [Installation](#installation)
3. [Initial Configuration](#initial-configuration)
4. [Security Configuration](#security-configuration)
5. [User Management](#user-management)
6. [Mailbox Management](#mailbox-management)
7. [Monitoring and Maintenance](#monitoring-and-maintenance)
8. [Troubleshooting](#troubleshooting)
9. [Telco-Specific Considerations](#telco-specific-considerations)
10. [ccTLD Administrator Tasks](#cctld-administrator-tasks)

## Overview

Cyrus IMAP is an enterprise-grade email server solution ideal for telecommunications companies and ccTLD registries that need:
- High availability and scalability
- Multi-domain support
- Advanced security features
- Compliance with regulatory requirements
- Integration with existing authentication systems

## Installation

### Prerequisites
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required dependencies
sudo apt install -y build-essential autotools-dev automake libtool
sudo apt install -y libssl-dev libsasl2-dev libpcre3-dev
sudo apt install -y libjansson-dev libxml2-dev libsqlite3-dev
```

### Install Cyrus IMAP
```bash
# Install Cyrus IMAP server and tools
sudo apt install -y cyrus-imapd cyrus-admin cyrus-clients cyrus-common

# Install additional utilities
sudo apt install -y cyrus-pop3d cyrus-murder cyrus-nntpd
```

### Verify Installation
```bash
# Check service status
sudo systemctl status cyrus-imapd

# Verify installed version
dpkg -l | grep cyrus
```

## Initial Configuration

### 1. Stop Services Before Configuration
```bash
sudo systemctl stop cyrus-imapd
sudo systemctl stop saslauthd
```

### 2. Main Configuration File
Edit `/etc/imapd.conf`:
```bash
sudo nano /etc/imapd.conf
```

**Basic Configuration:**
```
# Server identification
servername: mail.yourdomain.com
postmaster: postmaster@yourdomain.com

# Partitions and paths
configdirectory: /var/lib/cyrus
partition-default: /var/spool/cyrus/mail
partition-news: /var/spool/cyrus/news

# Authentication
sasl_pwcheck_method: saslauthd
sasl_mech_list: PLAIN LOGIN DIGEST-MD5 CRAM-MD5

# Security
allowplaintext: no
tls_cert_file: /etc/ssl/certs/cyrus.pem
tls_key_file: /etc/ssl/private/cyrus.key
tls_ca_file: /etc/ssl/certs/ca-certificates.crt

# Virtual domains (important for Telco/ccTLD)
virtdomains: userid
defaultdomain: yourdomain.com

# Quotas (important for service management)
quotawarn: 90
timeout: 30

# Logging
syslog_prefix: cyrus

# Performance tuning for high load
maxlogins_per_host: 10
maxlogins_per_user: 10
```

### 3. SASL Configuration
Edit `/etc/default/saslauthd`:
```bash
sudo nano /etc/default/saslauthd
```

```
START=yes
DESC="SASL Authentication Daemon"
NAME="saslauthd"
MECHANISMS="pam"
MECH_OPTIONS=""
THREADS=5
OPTIONS="-c -m /var/run/saslauthd"
```

### 4. Create SSL Certificates
```bash
# Generate self-signed certificate (for testing)
sudo openssl req -new -x509 -days 365 -nodes \
  -out /etc/ssl/certs/cyrus.pem \
  -keyout /etc/ssl/private/cyrus.key

# Set proper permissions
sudo chmod 600 /etc/ssl/private/cyrus.key
sudo chown cyrus:mail /etc/ssl/private/cyrus.key
sudo chown cyrus:mail /etc/ssl/certs/cyrus.pem
```

### 5. Initialize Database
```bash
# Create cyrus directories and initialize
sudo -u cyrus /usr/sbin/mkimap

# Start services
sudo systemctl enable saslauthd
sudo systemctl start saslauthd
sudo systemctl enable cyrus-imapd
sudo systemctl start cyrus-imapd
```

## Security Configuration

### 1. Firewall Rules
```bash
# Allow IMAP/IMAPS ports
sudo ufw allow 143/tcp  # IMAP
sudo ufw allow 993/tcp  # IMAPS
sudo ufw allow 110/tcp  # POP3
sudo ufw allow 995/tcp  # POP3S

# For management (restrict to admin networks)
sudo ufw allow from 192.168.1.0/24 to any port 4190  # ManageSieve
```

### 2. Access Control Lists
```bash
# Set up admin user
echo "admin_user: cyrus" | sudo tee -a /etc/imapd.conf
echo "cyrus" | sudo saslpasswd2 -c cyrus
```

### 3. TLS/SSL Hardening
Add to `/etc/imapd.conf`:
```
tls_versions: tls1_2 tls1_3
tls_ciphers: ECDHE+AESGCM:ECDHE+AES256:ECDHE+AES128:!aNULL:!MD5:!DSS
tls_eccurve: prime256v1
tls_prefer_server_ciphers: yes
```

## User Management

### 1. Create Administrative User
```bash
# Create cyrus admin user
sudo cyradm --user cyrus localhost
```

In cyradm shell:
```
cm user.admin@yourdomain.com
sam user.admin@yourdomain.com cyrus all
quit
```

### 2. Useful User Management Commands

**Create User Mailbox:**
```bash
# Via cyradm
cyradm --user cyrus localhost
cm user.john.doe@yourdomain.com
setquota user.john.doe@yourdomain.com STORAGE 1048576  # 1GB in KB
```

**Command Line User Creation Script:**
```bash
#!/bin/bash
# create_user.sh
USER=$1
DOMAIN=$2
QUOTA=$3

echo "cm user.${USER}@${DOMAIN}" | cyradm --user cyrus localhost
echo "setquota user.${USER}@${DOMAIN} STORAGE ${QUOTA}" | cyradm --user cyrus localhost
```

### 3. Bulk User Management
```bash
# Create users from CSV file
while IFS=',' read -r username domain quota; do
  echo "cm user.${username}@${domain}" | cyradm --user cyrus localhost
  echo "setquota user.${username}@${domain} STORAGE ${quota}" | cyradm --user cyrus localhost
done < users.csv
```

## Mailbox Management

### 1. Essential Cyradm Commands
```bash
# List mailboxes
lm

# List mailboxes for specific domain
lm user.*@example.com

# Create shared mailbox
cm shared.support@yourdomain.com

# Set ACLs (Access Control Lists)
sam user.john@yourdomain.com john.doe@yourdomain.com lrswipkxtecda

# Check quota usage
quota user.john@yourdomain.com

# Reconstruct mailbox (repair)
reconstruct user.john@yourdomain.com

# Delete mailbox
dm user.john@yourdomain.com
```

### 2. ACL Permissions Reference
- **l** - lookup (mailbox is visible to LIST/LSUB)
- **r** - read (SELECT the mailbox, perform STATUS)
- **s** - keep seen/unseen information across sessions
- **w** - write (set or clear flags other than SEEN and DELETED)
- **i** - insert (perform APPEND, COPY into mailbox)
- **p** - post (send mail to submission address for mailbox)
- **k** - create mailboxes (CREATE new sub-mailboxes)
- **x** - delete mailbox (DELETE mailbox, old mailbox name in RENAME)
- **t** - delete messages (set or clear DELETED flag via STORE)
- **e** - perform EXPUNGE and expunge as a part of CLOSE
- **c** - change ACLs (perform SETACL/DELETEACL/GETACL)
- **d** - delete messages (STORE DELETED flag, perform EXPUNGE)
- **a** - administer (perform operations admin-level operations)

### 3. Quota Management
```bash
# Set quota (in kilobytes)
setquota user.john@yourdomain.com STORAGE 2097152  # 2GB

# Remove quota
setquota user.john@yourdomain.com STORAGE none

# Check quota usage across all users
echo "lq" | cyradm --user cyrus localhost | grep STORAGE
```

## Monitoring and Maintenance

### 1. Log Monitoring
```bash
# Real-time log monitoring
sudo tail -f /var/log/mail.log
sudo tail -f /var/log/auth.log

# Filter Cyrus-specific logs
sudo journalctl -u cyrus-imapd -f

# Check for authentication failures
sudo grep "authentication failed" /var/log/mail.log
```

### 2. Performance Monitoring Scripts

**Check Active Connections:**
```bash
#!/bin/bash
# check_connections.sh
echo "Active IMAP connections:"
ss -tn | grep :143 | wc -l
echo "Active IMAPS connections:"
ss -tn | grep :993 | wc -l
```

**Mailbox Statistics:**
```bash
#!/bin/bash
# mailbox_stats.sh
echo "Total mailboxes:" 
echo "lm" | cyradm --user cyrus localhost | grep -c "user\."

echo "Quota usage summary:"
echo "lq" | cyradm --user cyrus localhost | grep STORAGE | awk '{total+=$4; used+=$3} END {printf "Used: %.2f GB / Total: %.2f GB (%.1f%%)\n", used/1024/1024, total/1024/1024, (used/total)*100}'
```

### 3. Backup Procedures
```bash
#!/bin/bash
# backup_cyrus.sh
BACKUP_DIR="/backup/cyrus/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup configuration
cp -r /etc/imapd.conf "$BACKUP_DIR/"
cp -r /etc/cyrus.conf "$BACKUP_DIR/"

# Backup mail data
rsync -av /var/spool/cyrus/ "$BACKUP_DIR/mail/"
rsync -av /var/lib/cyrus/ "$BACKUP_DIR/config/"

# Backup user database
echo "lm" | cyradm --user cyrus localhost > "$BACKUP_DIR/mailboxes.txt"
echo "lq" | cyradm --user cyrus localhost > "$BACKUP_DIR/quotas.txt"
```

## Troubleshooting

### 1. Common Issues and Solutions

**Service Won't Start:**
```bash
# Check configuration syntax
sudo /usr/sbin/imapd -C /etc/imapd.conf -M /etc/cyrus.conf

# Check permissions
sudo chown -R cyrus:mail /var/lib/cyrus
sudo chown -R cyrus:mail /var/spool/cyrus

# Check SASL authentication
sudo testsaslauthd -u testuser -p testpass -s imap
```

**Connection Issues:**
```bash
# Test IMAP connection
telnet localhost 143
# Commands: a001 capability, a002 logout

# Test IMAPS connection
openssl s_client -connect localhost:993
```

**Mailbox Corruption:**
```bash
# Reconstruct specific mailbox
echo "reconstruct user.john@example.com" | cyradm --user cyrus localhost

# Reconstruct all mailboxes
sudo -u cyrus /usr/sbin/ctl_mboxlist -d > /tmp/mailboxes.txt
sudo -u cyrus /usr/sbin/reconstruct -f /tmp/mailboxes.txt
```

### 2. Debug Commands
```bash
# Enable debug logging
echo "debug: 1" | sudo tee -a /etc/imapd.conf

# Check database consistency
sudo -u cyrus /usr/sbin/cyr_dbtool /var/lib/cyrus/mailboxes.db show

# Verify quotas
sudo -u cyrus /usr/sbin/quota -f /var/lib/cyrus/quotas.db
```

## Telco-Specific Considerations

### 1. High Availability Setup
```bash
# Install clustering tools
sudo apt install -y heartbeat pacemaker

# Configure replication (in /etc/imapd.conf)
sync_host: replica.yourdomain.com
sync_authname: repluser
sync_realm: yourdomain.com
sync_password: replpass
```

### 2. Load Balancing Configuration
```nginx
# nginx.conf for IMAP load balancing
stream {
    upstream imap_backend {
        server 10.0.1.100:143 weight=3 max_fails=2 fail_timeout=30s;
        server 10.0.1.101:143 weight=3 max_fails=2 fail_timeout=30s;
        server 10.0.1.102:143 weight=2 max_fails=2 fail_timeout=30s;
    }
    
    server {
        listen 143;
        proxy_pass imap_backend;
        proxy_timeout 1s;
        proxy_responses 1;
    }
}
```

### 3. Network Monitoring Integration
```bash
# SNMP monitoring setup
sudo apt install -y snmp snmp-mibs-downloader

# Custom SNMP script for Cyrus metrics
#!/bin/bash
# snmp_cyrus_metrics.sh
CONNECTIONS=$(ss -tn | grep :143 | wc -l)
MAILBOXES=$(echo "lm" | cyradm --user cyrus localhost | grep -c "user\.")
echo "Connections: $CONNECTIONS, Mailboxes: $MAILBOXES"
```

### 4. Regulatory Compliance
```bash
# Data retention policy script
#!/bin/bash
# retention_cleanup.sh
RETENTION_DAYS=2555  # 7 years

find /var/spool/cyrus -name "*.msg" -mtime +$RETENTION_DAYS -exec rm {} \;
```

## ccTLD Administrator Tasks

### 1. Multi-Domain Management
```bash
# Add new ccTLD domain
echo "virtdomains: userid" >> /etc/imapd.conf

# Create domain-specific admin
echo "cm user.admin@.nic.country" | cyradm --user cyrus localhost
echo "sam user.admin@.nic.country admin@.nic.country all" | cyradm --user cyrus localhost
```

### 2. Registry Staff Email Management
```bash
#!/bin/bash
# create_registry_structure.sh

DOMAIN="registry.country"
DEPARTMENTS=("admin" "technical" "legal" "billing")

for dept in "${DEPARTMENTS[@]}"; do
  echo "cm shared.${dept}@${DOMAIN}" | cyradm --user cyrus localhost
  echo "sam shared.${dept}@${DOMAIN} ${dept}-group@${DOMAIN} lrswipkxtecda" | cyradm --user cyrus localhost
done
```

### 3. Automated Reporting for Registry Operations
```bash
#!/bin/bash
# registry_email_report.sh

REPORT_DATE=$(date +%Y-%m-%d)
REPORT_FILE="/tmp/email_report_${REPORT_DATE}.txt"

echo "Email System Report for Registry - $REPORT_DATE" > $REPORT_FILE
echo "================================================" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Active mailboxes per domain
echo "Active Mailboxes by Domain:" >> $REPORT_FILE
echo "lm" | cyradm --user cyrus localhost | grep -E "@.*\." | cut -d'@' -f2 | sort | uniq -c >> $REPORT_FILE

echo "" >> $REPORT_FILE
echo "Storage Usage Summary:" >> $REPORT_FILE
echo "lq" | cyradm --user cyrus localhost | grep STORAGE | \
  awk '{total+=$4; used+=$3} END {printf "Used: %.2f GB / Allocated: %.2f GB (%.1f%% utilization)\n", used/1024/1024, total/1024/1024, (used/total)*100}' >> $REPORT_FILE

# Email report
mail -s "Daily Registry Email Report" admin@registry.country < $REPORT_FILE
```

### 4. Security Auditing for ccTLD
```bash
#!/bin/bash
# security_audit.sh

echo "=== Cyrus Security Audit Report ==="
echo "Date: $(date)"
echo ""

# Check for failed logins
echo "Failed Login Attempts (last 24 hours):"
sudo grep "authentication failed" /var/log/mail.log | grep "$(date --date='1 day ago' '+%b %d')" | wc -l

# Check SSL certificate expiry
echo ""
echo "SSL Certificate Status:"
openssl x509 -in /etc/ssl/certs/cyrus.pem -noout -dates

# Check for unusual quota usage
echo ""
echo "Users exceeding 90% quota:"
echo "lq" | cyradm --user cyrus localhost | awk '$3/$4 > 0.9 {print $1 " - " int(($3/$4)*100) "% used"}'
```

## Performance Tuning

### 1. Configuration Optimization
```bash
# Add to /etc/imapd.conf for high-load environments
maxforkrate: 100
maxchild: 250
maxlogins_per_host: 50
timeout: 10
poptimeout: 10
imapidletimeout: 60

# Memory optimization
mmap_reread_frequency: 60
duplicate_db: skiplist
ptscache_db: berkeley
statuscache_db: berkeley
```

### 2. System-Level Tuning
```bash
# Increase file descriptor limits
echo "cyrus soft nofile 65536" >> /etc/security/limits.conf
echo "cyrus hard nofile 65536" >> /etc/security/limits.conf

# TCP optimization for email servers
echo "net.core.somaxconn = 1024" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 2048" >> /etc/sysctl.conf
sysctl -p
```

## Maintenance Scripts

### 1. Daily Maintenance
```bash
#!/bin/bash
# daily_maintenance.sh

# Expire old messages
echo "Running message expiry..."
sudo -u cyrus /usr/sbin/cyr_expire -E 30 -D 90

# Compact databases
echo "Compacting databases..."
sudo -u cyrus /usr/sbin/ctl_cyrusdb -c

# Clean temporary files
find /var/spool/cyrus/stage. -type f -mtime +1 -delete

echo "Daily maintenance completed: $(date)"
```

### 2. Weekly Maintenance
```bash
#!/bin/bash
# weekly_maintenance.sh

# Full database reconstruction check
echo "Checking database integrity..."
sudo -u cyrus /usr/sbin/ctl_mboxlist -d | head -5

# Update seen database
sudo -u cyrus /usr/sbin/ctl_cyrusdb -r

# Generate usage statistics
echo "Generating weekly statistics..."
/path/to/registry_email_report.sh

echo "Weekly maintenance completed: $(date)"
```

This guide provides a comprehensive foundation for managing Cyrus IMAP in telecommunications and ccTLD registry environments. Adapt configurations based on your specific requirements and security policies.
