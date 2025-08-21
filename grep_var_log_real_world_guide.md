# Real-World grep Commands for /var/log Analysis

## Table of Contents
- [Essential grep Basics for Log Analysis](#essential-grep-basics-for-log-analysis)
- [System Administration Scenarios](#system-administration-scenarios)
- [Security and Intrusion Detection](#security-and-intrusion-detection)
- [Application Troubleshooting](#application-troubleshooting)
- [Performance and Resource Monitoring](#performance-and-resource-monitoring)
- [Network and Service Analysis](#network-and-service-analysis)
- [Database and Application Logs](#database-and-application-logs)
- [Advanced grep Techniques](#advanced-grep-techniques)
- [Log Rotation and Time-based Analysis](#log-rotation-and-time-based-analysis)
- [Automation and Scripting](#automation-and-scripting)

## Essential grep Basics for Log Analysis

### Key Options for Log Files
```bash
# Most useful grep options for log analysis
-i        # Ignore case
-n        # Show line numbers
-A NUM    # Show NUM lines after match
-B NUM    # Show NUM lines before match
-C NUM    # Show NUM lines before and after match
-v        # Invert match (show non-matching lines)
-c        # Count matches only
-l        # Show only filenames with matches
-r        # Recursive search
-E        # Extended regex (same as egrep)
-F        # Fixed strings (same as fgrep)
--color   # Colorize matches
-w        # Match whole words only
-x        # Match whole lines only
```

### Common Log File Locations
```bash
/var/log/messages      # General system messages (RHEL/CentOS)
/var/log/syslog        # General system messages (Debian/Ubuntu)
/var/log/auth.log      # Authentication logs (Debian/Ubuntu)
/var/log/secure        # Authentication logs (RHEL/CentOS)
/var/log/kern.log      # Kernel messages
/var/log/dmesg         # Boot messages
/var/log/cron          # Cron job logs
/var/log/maillog       # Mail server logs
/var/log/httpd/        # Apache logs
/var/log/nginx/        # Nginx logs
/var/log/mysql/        # MySQL logs
/var/log/audit/        # SELinux/audit logs
```

## System Administration Scenarios

### 1. **Boot and System Issues**

```bash
# Recent boot errors
grep -i "error\|fail\|panic\|oops" /var/log/dmesg

# Failed systemd services
grep -i "failed\|error" /var/log/messages | grep systemd

# Boot time analysis
grep -E "kernel:|systemd:" /var/log/messages | tail -100

# Hardware issues
grep -i "hardware\|temperature\|thermal\|fan" /var/log/messages

# Memory issues
grep -i "out of memory\|oom\|killed process" /var/log/messages

# Disk errors
grep -i "disk\|ata\|scsi\|i/o error" /var/log/messages

# Mount/filesystem issues
grep -i "mount\|filesystem\|ext4\|xfs" /var/log/messages
```

### 2. **User Authentication and Access**

```bash
# Failed login attempts
grep -i "failed\|failure" /var/log/auth.log

# Successful SSH logins
grep "Accepted" /var/log/auth.log

# Failed SSH attempts with details
grep "Failed password" /var/log/auth.log | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | uniq -c | sort -nr

# Root access attempts
grep -i "root" /var/log/auth.log | grep -i "fail\|denied"

# Sudo usage
grep "sudo:" /var/log/auth.log

# User account creation/modification
grep -E "useradd|userdel|usermod|passwd" /var/log/messages

# Login from specific IP
grep "192.168.1.100" /var/log/auth.log

# Brute force detection
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr | head -10
```

### 3. **System Resource Monitoring**

```bash
# High CPU usage alerts
grep -i "cpu\|load" /var/log/messages

# Memory warnings
grep -i "memory\|swap" /var/log/messages

# Disk space issues
grep -i "no space\|disk full" /var/log/messages

# Process crashes
grep -i "segfault\|core dump\|killed" /var/log/messages

# Service restarts
grep -i "restart\|reload" /var/log/messages | grep -E "httpd|nginx|mysql|postgres"
```

## Security and Intrusion Detection

### 1. **Attack Detection**

```bash
# Potential SQL injection attempts (web logs)
grep -i "union\|select\|insert\|delete\|drop\|script" /var/log/httpd/access_log

# XSS attempts
grep -i "script\|javascript\|onclick\|onerror" /var/log/httpd/access_log

# Directory traversal attempts
grep -E "\.\./|\.\.\\|%2e%2e" /var/log/httpd/access_log

# Suspicious user agents
grep -E "(sqlmap|nmap|nikto|burp|acunetix)" /var/log/httpd/access_log

# Multiple failed login attempts from same IP
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | awk '$1 > 5'

# Port scanning detection
grep -i "port.*scan\|nmap" /var/log/messages

# Privilege escalation attempts
grep -i "su:\|sudo:" /var/log/auth.log | grep -i "fail\|incorrect"
```

### 2. **Network Security**

```bash
# Firewall drops
grep -i "drop\|reject\|deny" /var/log/messages

# Unusual network connections
grep -E "connection.*refused|timeout" /var/log/messages

# VPN connection issues
grep -i "vpn\|openvpn\|ipsec" /var/log/messages

# DNS issues or potential DNS poisoning
grep -i "dns\|resolver" /var/log/messages | grep -i "fail\|error"

# Large file uploads (potential data exfiltration)
grep " 200 " /var/log/httpd/access_log | awk '$10 > 10000000' | tail -20
```

### 3. **SELinux/AppArmor Denials**

```bash
# SELinux denials
grep "avc.*denied" /var/log/messages

# AppArmor denials
grep "apparmor.*DENIED" /var/log/messages

# Audit log analysis
grep "type=AVC" /var/log/audit/audit.log

# Policy violations
grep -i "policy\|violation" /var/log/messages
```

## Application Troubleshooting

### 1. **Web Server Analysis (Apache/Nginx)**

```bash
# Error analysis
grep -E "(404|500|502|503)" /var/log/httpd/access_log | tail -50

# Most requested pages
awk '{print $7}' /var/log/httpd/access_log | sort | uniq -c | sort -nr | head -20

# Traffic by IP address
awk '{print $1}' /var/log/httpd/access_log | sort | uniq -c | sort -nr | head -20

# Slow requests (if using custom log format)
awk '$NF > 5000 {print $0}' /var/log/httpd/access_log  # Requests taking >5 seconds

# Error patterns in error log
grep -E "(error|warning|critical)" /var/log/httpd/error_log | tail -100

# Memory or resource issues
grep -i "memory\|resource\|limit" /var/log/httpd/error_log

# Configuration issues
grep -i "config\|syntax" /var/log/httpd/error_log

# SSL/TLS issues
grep -i "ssl\|tls\|certificate" /var/log/httpd/error_log
```

### 2. **Database Issues**

```bash
# MySQL errors
grep -i "error\|warning" /var/log/mysql/error.log | tail -50

# Connection issues
grep -i "connection\|connect" /var/log/mysql/error.log

# Performance issues
grep -i "slow\|timeout\|lock" /var/log/mysql/error.log

# Authentication failures
grep -i "access denied\|authentication" /var/log/mysql/error.log

# PostgreSQL errors
grep -E "(ERROR|WARNING|FATAL)" /var/log/postgresql/postgresql-*.log

# Database crashes
grep -i "crash\|abort\|panic" /var/log/mysql/error.log
```

### 3. **Application-Specific Logs**

```bash
# Java application errors
grep -E "(Exception|Error|FATAL)" /var/log/application.log | head -20

# PHP errors
grep -i "php\|fatal\|parse error" /var/log/httpd/error_log

# Python application errors
grep -E "(Traceback|Error|Exception)" /var/log/application.log

# Node.js errors
grep -E "(Error|Exception|TypeError)" /var/log/nodejs/app.log

# Memory leaks in applications
grep -i "memory.*leak\|heap" /var/log/application.log
```

## Performance and Resource Monitoring

### 1. **System Performance Issues**

```bash
# High load alerts
grep -i "load average" /var/log/messages

# I/O wait issues
grep -i "iowait\|blocked" /var/log/messages

# Network performance issues
grep -i "network.*slow\|timeout" /var/log/messages

# Swap usage warnings
grep -i "swap" /var/log/messages | grep -i "warn\|critical"

# Process resource usage
grep -E "process.*memory|process.*cpu" /var/log/messages

# File descriptor exhaustion
grep -i "too many open files" /var/log/messages
```

### 2. **Storage and Filesystem**

```bash
# Disk space warnings
grep -i "disk.*full\|space.*low" /var/log/messages

# Filesystem errors
grep -i "ext4\|xfs\|filesystem" /var/log/messages | grep -i "error"

# RAID issues
grep -i "raid\|md[0-9]" /var/log/messages | grep -i "fail\|error"

# LVM issues
grep -i "lvm\|logical volume" /var/log/messages

# Backup job status
grep -i "backup\|rsync" /var/log/messages | grep -E "(fail|success|complete)"
```

## Network and Service Analysis

### 1. **Network Connectivity**

```bash
# Network interface issues
grep -i "eth0\|wlan0\|interface" /var/log/messages | grep -i "down\|up\|link"

# DHCP issues
grep -i "dhcp" /var/log/messages

# DNS resolution problems
grep -i "dns\|resolver" /var/log/messages | grep -i "fail\|timeout"

# Network timeouts
grep -i "timeout\|unreachable" /var/log/messages

# Routing issues
grep -i "route\|gateway" /var/log/messages
```

### 2. **Service Monitoring**

```bash
# Service start/stop events
grep -E "(start|stop|restart)" /var/log/messages | grep -E "(httpd|nginx|mysql|ssh)"

# Cron job monitoring
grep -i "cron" /var/log/cron | grep -E "(CMD|started|finished)"

# Failed cron jobs
grep -E "error|fail" /var/log/cron

# Mail server issues
grep -E "(postfix|sendmail|dovecot)" /var/log/maillog | grep -i "error\|fail"

# Time synchronization
grep -i "ntp\|chronyd" /var/log/messages
```

## Database and Application Logs

### 1. **Advanced Database Analysis**

```bash
# Deadlock detection
grep -i "deadlock" /var/log/mysql/error.log -A 10

# Slow query analysis
grep -i "slow" /var/log/mysql/mysql-slow.log | head -20

# Connection pool exhaustion
grep -i "connection.*pool\|too many connections" /var/log/mysql/error.log

# Replication issues
grep -i "slave\|replication" /var/log/mysql/error.log

# Index usage warnings
grep -i "index" /var/log/mysql/mysql-slow.log | grep -v "using index"
```

### 2. **Web Application Performance**

```bash
# Response time analysis (assuming custom log format)
awk '{print $NF}' /var/log/httpd/access_log | sort -n | tail -100  # Slowest requests

# Error rate over time
grep "$(date '+%d/%b/%Y')" /var/log/httpd/access_log | awk '{print $9}' | sort | uniq -c

# Bot traffic detection
grep -E "(bot|crawler|spider)" /var/log/httpd/access_log -i | wc -l

# Cache hit/miss analysis
grep -E "(HIT|MISS)" /var/log/httpd/access_log | awk '{print $12}' | sort | uniq -c

# Geographic analysis (if using GeoIP)
awk '{print $15}' /var/log/httpd/access_log | sort | uniq -c | sort -nr | head -10
```

## Advanced grep Techniques

### 1. **Complex Pattern Matching**

```bash
# Multiple patterns with OR logic
grep -E "(error|fail|warning)" /var/log/messages

# Multiple patterns with AND logic (using multiple greps)
grep "error" /var/log/messages | grep "mysql"

# Negative lookahead simulation
grep "error" /var/log/messages | grep -v "harmless"

# Case-insensitive with word boundaries
grep -iw "fail" /var/log/messages

# Exact line matching
grep -x "Error: Connection lost" /var/log/application.log

# Fixed string search (faster for literals)
fgrep "192.168.1.1" /var/log/messages
```

### 2. **Context and Formatting**

```bash
# Show 5 lines before and after each match
grep -C 5 "error" /var/log/messages

# Show line numbers with matches
grep -n "fail" /var/log/auth.log

# Show only filenames containing pattern
grep -l "error" /var/log/*.log

# Count occurrences
grep -c "login" /var/log/auth.log

# Suppress filename in output (useful for single files)
grep -h "pattern" /var/log/messages

# Show matches with binary file detection
grep -a "pattern" /var/log/binary.log
```

### 3. **Regular Expressions for Logs**

```bash
# IP addresses
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' /var/log/messages

# Email addresses
grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' /var/log/maillog

# URLs
grep -E 'https?://[^\s]+' /var/log/httpd/access_log

# MAC addresses
grep -E '([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}' /var/log/messages

# Process IDs
grep -E 'pid[[:space:]]*[0-9]+' /var/log/messages

# Timestamps (various formats)
grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]][0-9]{2}:[0-9]{2}:[0-9]{2}' /var/log/messages
```

## Log Rotation and Time-based Analysis

### 1. **Working with Rotated Logs**

```bash
# Search across all rotated logs
grep "pattern" /var/log/messages*

# Search in compressed logs
zgrep "error" /var/log/messages.*.gz

# Combine current and rotated logs
(grep "pattern" /var/log/messages; zgrep "pattern" /var/log/messages.*.gz)

# Search by date range (last 7 days)
find /var/log -name "messages*" -mtime -7 -exec grep "pattern" {} \;

# Search in specific timeframe
grep "Dec 15" /var/log/messages | grep "10:3[0-9]"  # Between 10:30-10:39
```

### 2. **Time-based Analysis**

```bash
# Today's errors
grep "$(date '+%b %d')" /var/log/messages | grep -i error

# Yesterday's logs
grep "$(date -d yesterday '+%b %d')" /var/log/messages

# Last hour's activity
grep "$(date '+%b %d %H:')" /var/log/messages

# Specific time window
grep "Dec 15 1[0-2]:" /var/log/messages  # Between 10:00-12:59

# Weekend activity
grep -E "(Sat|Sun)" /var/log/messages | grep "$(date '+%b')"

# Night time activity (potential suspicious)
grep -E " 0[0-6]:[0-9]{2}:[0-9]{2}" /var/log/auth.log
```

## Automation and Scripting

### 1. **Log Monitoring Scripts**

```bash
#!/bin/bash
# Real-time error monitoring
tail -f /var/log/messages | grep --line-buffered -i error | while read line; do
    echo "$(date): $line" | tee -a /var/log/error_alerts.log
    # Send alert notification here
done

# Security monitoring script
#!/bin/bash
check_security() {
    local logfile="/var/log/auth.log"
    local alert_file="/tmp/security_alerts.log"
    
    # Check for brute force attempts
    failed_attempts=$(grep "Failed password" "$logfile" | grep "$(date '+%b %d')" | wc -l)
    if [ "$failed_attempts" -gt 10 ]; then
        echo "ALERT: $failed_attempts failed login attempts today" >> "$alert_file"
    fi
    
    # Check for root login attempts
    root_attempts=$(grep "root" "$logfile" | grep "Failed" | grep "$(date '+%b %d')" | wc -l)
    if [ "$root_attempts" -gt 0 ]; then
        echo "ALERT: Root login attempts detected: $root_attempts" >> "$alert_file"
    fi
}

# Performance monitoring
#!/bin/bash
check_performance() {
    # Check for out of memory errors
    oom_count=$(grep "Out of memory" /var/log/messages | grep "$(date '+%b %d')" | wc -l)
    if [ "$oom_count" -gt 0 ]; then
        echo "PERFORMANCE ALERT: OOM events detected: $oom_count"
    fi
    
    # Check for high load
    load_warnings=$(grep "load average" /var/log/messages | grep "$(date '+%b %d')" | wc -l)
    if [ "$load_warnings" -gt 5 ]; then
        echo "PERFORMANCE ALERT: Multiple high load warnings: $load_warnings"
    fi
}
```

### 2. **Log Analysis Functions**

```bash
# Function to analyze failed logins by IP
analyze_failed_logins() {
    local logfile="${1:-/var/log/auth.log}"
    echo "=== Failed Login Analysis ==="
    grep "Failed password" "$logfile" | \
    awk '{print $11}' | sort | uniq -c | sort -nr | head -10 | \
    while read count ip; do
        echo "IP: $ip - Failed attempts: $count"
    done
}

# Function to check service availability
check_service_logs() {
    local service="$1"
    local logfile="${2:-/var/log/messages}"
    echo "=== $service Service Analysis ==="
    
    # Recent starts/stops
    grep -i "$service" "$logfile" | grep -E "(start|stop|restart)" | tail -5
    
    # Recent errors
    grep -i "$service" "$logfile" | grep -i error | tail -5
}

# Function to generate daily summary
daily_summary() {
    local date_pattern="${1:-$(date '+%b %d')}"
    echo "=== Daily Summary for $date_pattern ==="
    
    echo "Errors: $(grep "$date_pattern" /var/log/messages | grep -ci error)"
    echo "Warnings: $(grep "$date_pattern" /var/log/messages | grep -ci warning)"
    echo "Failed logins: $(grep "$date_pattern" /var/log/auth.log | grep -c "Failed password")"
    echo "Successful logins: $(grep "$date_pattern" /var/log/auth.log | grep -c "Accepted")"
    echo "Service restarts: $(grep "$date_pattern" /var/log/messages | grep -c restart)"
}
```

### 3. **One-liners for Quick Analysis**

```bash
# Top 10 error-generating processes
grep -i error /var/log/messages | awk '{print $5}' | sort | uniq -c | sort -nr | head -10

# Hourly error distribution
grep -i error /var/log/messages | grep "$(date '+%b %d')" | cut -d' ' -f3 | cut -d':' -f1 | sort | uniq -c

# Most active IPs in auth log
awk '/sshd/ {print $11}' /var/log/auth.log | sort | uniq -c | sort -nr | head -10

# Services with most restarts
grep restart /var/log/messages | awk '{print $6}' | sort | uniq -c | sort -nr

# Find configuration file changes
grep -i "config" /var/log/messages | grep "$(date '+%b %d')"

# Memory usage warnings over time
grep -i "memory" /var/log/messages | awk '{print $1" "$2" "$3}' | sort | uniq -c
```

## Real-World Troubleshooting Scenarios

### Scenario 1: Website Down
```bash
# Check web server status
grep -E "(start|stop|restart|error)" /var/log/httpd/error_log | tail -20

# Check for resource issues
grep -i "memory\|resource\|limit" /var/log/httpd/error_log | tail -10

# Check recent errors
grep "$(date '+%d/%b/%Y')" /var/log/httpd/access_log | grep " 5[0-9][0-9] " | tail -20

# Check system resources
grep -i "memory\|cpu\|load" /var/log/messages | grep "$(date '+%b %d')" | tail -10
```

### Scenario 2: Database Performance Issues
```bash
# Check for connection issues
grep -i "connection" /var/log/mysql/error.log | tail -20

# Look for slow queries
grep -i "slow" /var/log/mysql/error.log | tail -10

# Check for deadlocks
grep -i "deadlock" /var/log/mysql/error.log -A 5 | tail -20

# System resource impact
grep -i "mysql" /var/log/messages | grep -E "(memory|cpu|killed)" | tail -10
```

### Scenario 3: Security Incident Response
```bash
# Unusual login patterns
grep "$(date '+%b %d')" /var/log/auth.log | grep -E "(Accepted|Failed)" | \
awk '{print $3" "$9" "$11}' | sort | uniq -c

# Privilege escalation attempts
grep -E "sudo:|su:" /var/log/auth.log | grep "$(date '+%b %d')" | grep -i fail

# Network-based attacks
grep -E "(drop|reject|deny)" /var/log/messages | grep "$(date '+%b %d')" | tail -20

# File system changes
grep -E "(chmod|chown|rm|mv)" /var/log/messages | grep "$(date '+%b %d')"
```

This comprehensive guide provides practical grep commands for real-world log analysis, covering system administration, security monitoring, troubleshooting, and automation scenarios that every Linux administrator encounters.
