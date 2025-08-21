# Filtering and Analyzing grep Results: From Raw Data to Actionable Intelligence

## Table of Contents
- [The Challenge: Information Overload](#the-challenge-information-overload)
- [Data Filtering Strategies](#data-filtering-strategies)
- [Pattern Recognition and Grouping](#pattern-recognition-and-grouping)
- [Statistical Analysis of Log Data](#statistical-analysis-of-log-data)
- [Noise Reduction Techniques](#noise-reduction-techniques)
- [Contextual Analysis Methods](#contextual-analysis-methods)
- [Visualization and Reporting](#visualization-and-reporting)
- [Automated Intelligence Extraction](#automated-intelligence-extraction)
- [Real-World Analysis Workflows](#real-world-analysis-workflows)
- [Advanced Filtering Pipelines](#advanced-filtering-pipelines)

## The Challenge: Information Overload

### Common Problems with Raw grep Results

```bash
# Problem: Too much output
grep "error" /var/log/messages
# Result: Thousands of lines, mostly noise

# Problem: No context or patterns
grep "failed" /var/log/auth.log
# Result: Individual events without understanding trends

# Problem: Mixed severity levels
grep -i "warning\|error\|critical" /var/log/messages
# Result: Cannot distinguish critical from minor issues
```

### The Solution: Multi-Stage Analysis Pipeline

```
Raw Logs → grep → Filter → Group → Analyze → Visualize → Action
    ↓         ↓       ↓       ↓        ↓         ↓        ↓
 1000K+    100K+    1K+    100+     10+       5+      1-3
 entries   entries entries entries patterns  issues  actions
```

## Data Filtering Strategies

### 1. **Time-Based Filtering**

```bash
# Recent activity only (last 24 hours)
grep "$(date '+%b %d')" /var/log/messages | grep -i error

# Business hours only (9 AM - 5 PM)
grep -E " (09|1[0-7]):[0-9]{2}:[0-9]{2}" /var/log/messages | grep -i error

# Exclude maintenance windows (weekends, nights)
grep "$(date '+%b %d')" /var/log/messages | grep -i error | \
    grep -v -E " (0[0-6]|2[2-3]):[0-9]{2}:[0-9]{2}"

# Focus on peak hours
grep "$(date '+%b %d')" /var/log/messages | grep -E " (1[0-6]):[0-9]{2}:[0-9]{2}" | grep -i error
```

### 2. **Severity-Based Filtering**

```bash
# Critical issues only
grep -E "(critical|fatal|panic|emergency)" /var/log/messages -i

# Exclude informational messages
grep -i error /var/log/messages | grep -v -E "(info|notice|debug)"

# High-priority security events
grep -E "(failed.*root|authentication.*fail|privilege.*escalation)" /var/log/auth.log -i

# Filter by log level hierarchy
grep -E "(FATAL|ERROR|WARN)" /var/log/application.log | grep -v -E "(DEBUG|INFO|TRACE)"
```

### 3. **Source-Based Filtering**

```bash
# Exclude routine/expected sources
grep -i error /var/log/messages | grep -v -E "(logrotate|anacron|CRON)"

# Focus on specific services
grep -i error /var/log/messages | grep -E "(httpd|nginx|mysql|postgres)"

# Exclude known false positives
grep "failed" /var/log/auth.log | grep -v -E "(test-user|monitoring-user)"

# System vs application errors
grep -i error /var/log/messages | grep -E "(kernel|systemd|dbus)" # System
grep -i error /var/log/messages | grep -v -E "(kernel|systemd|dbus)" # Application
```

## Pattern Recognition and Grouping

### 1. **Frequency Analysis**

```bash
# Count error types
grep -i error /var/log/messages | awk '{print $5}' | sort | uniq -c | sort -nr

# Most frequent error messages
grep -i error /var/log/messages | awk '{$1=$2=$3=$4=$5=""; print $0}' | sort | uniq -c | sort -nr | head -10

# Time-based frequency
grep -i error /var/log/messages | grep "$(date '+%b %d')" | \
    cut -d' ' -f3 | cut -d':' -f1 | sort | uniq -c

# IP-based frequency analysis
grep "failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

### 2. **Pattern Grouping**

```bash
# Group by error type
group_errors() {
    local logfile="$1"
    echo "=== Connection Errors ==="
    grep -i "connection.*error\|connection.*failed\|connection.*timeout" "$logfile" | wc -l
    
    echo "=== Authentication Errors ==="
    grep -i "auth.*error\|authentication.*failed\|login.*failed" "$logfile" | wc -l
    
    echo "=== Resource Errors ==="
    grep -i "memory.*error\|disk.*error\|space.*error" "$logfile" | wc -l
    
    echo "=== Permission Errors ==="
    grep -i "permission.*denied\|access.*denied\|forbidden" "$logfile" | wc -l
}

# Group by service impact
service_impact_analysis() {
    echo "=== High Impact (User-Facing) ==="
    grep -i error /var/log/messages | grep -E "(httpd|nginx|apache|web)" | wc -l
    
    echo "=== Medium Impact (Backend) ==="
    grep -i error /var/log/messages | grep -E "(mysql|postgres|database|cache)" | wc -l
    
    echo "=== Low Impact (System) ==="
    grep -i error /var/log/messages | grep -E "(cron|logrotate|backup)" | wc -l
}
```

### 3. **Correlation Analysis**

```bash
# Find correlated events (within 5 minutes)
correlate_events() {
    local timestamp="$1"
    local logfile="/var/log/messages"
    
    # Extract hour and minute for time window
    local hour=$(echo "$timestamp" | cut -d':' -f1)
    local minute=$(echo "$timestamp" | cut -d':' -f2)
    
    echo "=== Events around $timestamp ==="
    grep "$hour:$minute" "$logfile" | grep -v "$timestamp"
}

# Sequence analysis
sequence_analysis() {
    echo "=== Common Error Sequences ==="
    grep -i error /var/log/messages | grep "$(date '+%b %d')" | \
        awk '{print $3, $5}' | \
        while read time service; do
            echo "$time,$service"
        done | sort | \
        awk -F, 'prev_time && ($1 - prev_time < 300) {print prev_service " → " $2} {prev_time=$1; prev_service=$2}'
}
```

## Statistical Analysis of Log Data

### 1. **Error Rate Analysis**

```bash
# Calculate error rates
error_rate_analysis() {
    local logfile="$1"
    local date_pattern="$(date '+%b %d')"
    
    total_entries=$(grep "$date_pattern" "$logfile" | wc -l)
    error_entries=$(grep "$date_pattern" "$logfile" | grep -i error | wc -l)
    
    if [ "$total_entries" -gt 0 ]; then
        error_rate=$(echo "scale=2; $error_entries * 100 / $total_entries" | bc)
        echo "Total entries: $total_entries"
        echo "Error entries: $error_entries"
        echo "Error rate: $error_rate%"
    fi
}

# Trend analysis
trend_analysis() {
    echo "=== Error Trend Analysis (Last 7 Days) ==="
    for i in {0..6}; do
        date_check=$(date -d "$i days ago" '+%b %d')
        error_count=$(grep "$date_check" /var/log/messages | grep -i error | wc -l)
        echo "$date_check: $error_count errors"
    done
}

# Peak analysis
peak_analysis() {
    echo "=== Peak Error Hours Today ==="
    grep "$(date '+%b %d')" /var/log/messages | grep -i error | \
        cut -d' ' -f3 | cut -d':' -f1 | sort | uniq -c | sort -nr | head -5
}
```

### 2. **Threshold-Based Alerting**

```bash
# Smart threshold detection
smart_threshold_alert() {
    local service="$1"
    local logfile="/var/log/messages"
    local date_pattern="$(date '+%b %d')"
    
    # Calculate baseline (average errors per day over last 7 days)
    total_errors=0
    for i in {1..7}; do
        date_check=$(date -d "$i days ago" '+%b %d')
        daily_errors=$(grep "$date_check" "$logfile" | grep -i "$service" | grep -i error | wc -l)
        total_errors=$((total_errors + daily_errors))
    done
    
    baseline=$((total_errors / 7))
    current_errors=$(grep "$date_pattern" "$logfile" | grep -i "$service" | grep -i error | wc -l)
    
    # Alert if current > 2x baseline
    if [ "$current_errors" -gt $((baseline * 2)) ]; then
        echo "ALERT: $service errors ($current_errors) exceed baseline ($baseline)"
    fi
}

# Burst detection
burst_detection() {
    local threshold=10
    local time_window=5  # minutes
    
    echo "=== Burst Detection (>$threshold errors in $time_window minutes) ==="
    grep -i error /var/log/messages | grep "$(date '+%b %d')" | \
        awk '{print $3}' | \
        while read timestamp; do
            # Convert to minutes since midnight
            hour=$(echo "$timestamp" | cut -d':' -f1)
            minute=$(echo "$timestamp" | cut -d':' -f2)
            total_minutes=$((hour * 60 + minute))
            echo "$total_minutes"
        done | sort -n | uniq -c | awk -v threshold="$threshold" '$1 > threshold {print "Burst at " $2 " minutes: " $1 " errors"}'
}
```

## Noise Reduction Techniques

### 1. **Common Noise Patterns**

```bash
# Filter out routine maintenance
filter_maintenance() {
    grep -i error /var/log/messages | \
        grep -v -E "(logrotate|anacron|updatedb|mlocate)" | \
        grep -v -E "(backup.*complete|backup.*success)" | \
        grep -v -E "(certificate.*renew|ssl.*update)"
}

# Remove test/development noise
filter_test_noise() {
    grep -i error /var/log/messages | \
        grep -v -E "(test|staging|dev|localhost)" | \
        grep -v -E "(curl.*test|wget.*test)" | \
        grep -v -E "(monitoring.*check|health.*check)"
}

# Filter application startup noise
filter_startup_noise() {
    grep -i error /var/log/messages | \
        grep -v -E "(starting|initializing|loading)" | \
        grep -v -E "(configuration.*loaded|service.*ready)"
}
```

### 2. **Intelligent Filtering**

```bash
# Context-aware filtering
intelligent_filter() {
    local raw_output="$1"
    
    # Step 1: Remove known false positives
    echo "$raw_output" | grep -v -E "(connection reset by peer|broken pipe)" |
    
    # Step 2: Keep only errors with context
    grep -E "(failed.*[0-9]|error.*code|exception.*at|timeout.*after)" |
    
    # Step 3: Remove duplicate consecutive errors
    awk '!seen[substr($0, 17)]++ {print}' |
    
    # Step 4: Keep only recent errors (last 4 hours)
    grep -E "$(date '+%b %d') ($(date -d '4 hours ago' '+%H')|$(date -d '3 hours ago' '+%H')|$(date -d '2 hours ago' '+%H')|$(date -d '1 hour ago' '+%H')|$(date '+%H')):"
}

# Severity-based intelligent filtering
severity_filter() {
    local input="$1"
    
    # Critical (immediate attention)
    echo "=== CRITICAL ==="
    echo "$input" | grep -i -E "(fatal|critical|panic|emergency|segfault)"
    
    # High (urgent attention)
    echo "=== HIGH ==="
    echo "$input" | grep -i -E "(error.*failed|connection.*lost|authentication.*denied)" | \
        grep -v -i -E "(retry|attempt|temporary)"
    
    # Medium (needs attention)
    echo "=== MEDIUM ==="
    echo "$input" | grep -i error | grep -v -i -E "(fatal|critical|panic|emergency)"
    
    # Low (informational)
    echo "=== LOW ==="
    echo "$input" | grep -i -E "(warning|notice)" | head -10
}
```

## Contextual Analysis Methods

### 1. **Before/After Context**

```bash
# Analyze events leading to errors
error_context_analysis() {
    local error_pattern="$1"
    local logfile="$2"
    
    echo "=== Context Analysis for: $error_pattern ==="
    
    # Find error occurrences and show context
    grep -n "$error_pattern" "$logfile" | while read line; do
        line_number=$(echo "$line" | cut -d':' -f1)
        
        echo "--- Error at line $line_number ---"
        # Show 3 lines before and 2 lines after
        sed -n "$((line_number-3)),$((line_number+2))p" "$logfile" | \
            sed "s/^/  /" | \
            sed "${line_number}s/^  />>/"
        echo ""
    done
}

# Timeline reconstruction
timeline_reconstruction() {
    local service="$1"
    local start_time="$2"  # Format: "HH:MM"
    local end_time="$3"    # Format: "HH:MM"
    
    echo "=== Timeline for $service ($start_time - $end_time) ==="
    
    grep "$service" /var/log/messages | \
        grep "$(date '+%b %d')" | \
        awk -v start="$start_time" -v end="$end_time" '
            {
                time = substr($3, 1, 5)
                if (time >= start && time <= end) print $0
            }' | \
        sort -k3
}
```

### 2. **Cross-Log Correlation**

```bash
# Correlate across multiple log files
cross_log_correlation() {
    local timestamp="$1"  # Format: "MMM DD HH:MM"
    
    echo "=== Cross-Log Correlation for $timestamp ==="
    
    echo "--- System Log ---"
    grep "$timestamp" /var/log/messages 2>/dev/null | head -3
    
    echo "--- Auth Log ---"
    grep "$timestamp" /var/log/auth.log 2>/dev/null | head -3
    
    echo "--- Application Log ---"
    grep "$timestamp" /var/log/httpd/error_log 2>/dev/null | head -3
    
    echo "--- Database Log ---"
    grep "$timestamp" /var/log/mysql/error.log 2>/dev/null | head -3
}

# Service dependency analysis
service_dependency_analysis() {
    local primary_service="$1"
    local time_window="$2"  # minutes
    
    echo "=== Dependency Analysis for $primary_service ==="
    
    # Find primary service errors
    primary_errors=$(grep "$primary_service" /var/log/messages | \
                    grep "$(date '+%b %d')" | \
                    grep -i error)
    
    if [ -n "$primary_errors" ]; then
        echo "$primary_errors" | while read error_line; do
            error_time=$(echo "$error_line" | awk '{print $3}')
            
            echo "--- Dependencies around $error_time ---"
            # Check dependent services within time window
            grep -E "(database|cache|queue|storage)" /var/log/messages | \
                grep "$error_time" | head -3
        done
    fi
}
```

## Visualization and Reporting

### 1. **Text-Based Dashboards**

```bash
# Create a summary dashboard
create_dashboard() {
    local date_pattern="${1:-$(date '+%b %d')}"
    
    echo "┌─────────────────────────────────────────────────┐"
    echo "│           SYSTEM STATUS DASHBOARD              │"
    echo "│                 $date_pattern                      │"
    echo "├─────────────────────────────────────────────────┤"
    
    # Error summary
    total_errors=$(grep "$date_pattern" /var/log/messages | grep -i error | wc -l)
    critical_errors=$(grep "$date_pattern" /var/log/messages | grep -i -E "(critical|fatal|panic)" | wc -l)
    auth_failures=$(grep "$date_pattern" /var/log/auth.log | grep -i "failed" | wc -l)
    
    printf "│ Total Errors: %6d                         │\n" "$total_errors"
    printf "│ Critical Errors: %3d                          │\n" "$critical_errors"
    printf "│ Auth Failures: %5d                          │\n" "$auth_failures"
    echo "├─────────────────────────────────────────────────┤"
    
    # Top error sources
    echo "│ Top Error Sources:                              │"
    grep "$date_pattern" /var/log/messages | grep -i error | \
        awk '{print $5}' | sort | uniq -c | sort -nr | head -3 | \
        while read count source; do
            printf "│   %-20s %6d              │\n" "$source" "$count"
        done
    
    echo "└─────────────────────────────────────────────────┘"
}

# Generate hourly error graph (ASCII)
hourly_error_graph() {
    echo "=== Hourly Error Distribution ==="
    grep "$(date '+%b %d')" /var/log/messages | grep -i error | \
        cut -d' ' -f3 | cut -d':' -f1 | sort | uniq -c | \
        while read count hour; do
            printf "%02d:00 [%3d] " "$hour" "$count"
            for ((i=1; i<=count/5; i++)); do printf "█"; done
            echo ""
        done
}
```

### 2. **Report Generation**

```bash
# Generate comprehensive report
generate_report() {
    local report_date="${1:-$(date '+%Y-%m-%d')}"
    local report_file="error_report_$report_date.txt"
    
    {
        echo "SYSTEM ERROR ANALYSIS REPORT"
        echo "Generated: $(date)"
        echo "Report Date: $report_date"
        echo "=========================================="
        echo ""
        
        # Executive Summary
        echo "EXECUTIVE SUMMARY"
        echo "-----------------"
        total_errors=$(grep "$(date -d "$report_date" '+%b %d')" /var/log/messages | grep -i error | wc -l)
        echo "Total errors detected: $total_errors"
        
        if [ "$total_errors" -gt 100 ]; then
            echo "Status: HIGH - Requires immediate attention"
        elif [ "$total_errors" -gt 50 ]; then
            echo "Status: MEDIUM - Monitor closely"
        else
            echo "Status: LOW - Normal operations"
        fi
        echo ""
        
        # Detailed Analysis
        echo "DETAILED ANALYSIS"
        echo "----------------"
        
        echo "1. Critical Errors:"
        grep "$(date -d "$report_date" '+%b %d')" /var/log/messages | \
            grep -i -E "(critical|fatal|panic)" | head -5
        echo ""
        
        echo "2. Most Frequent Errors:"
        grep "$(date -d "$report_date" '+%b %d')" /var/log/messages | \
            grep -i error | awk '{$1=$2=$3=$4=$5=""; print $0}' | \
            sort | uniq -c | sort -nr | head -5
        echo ""
        
        echo "3. Service Impact Analysis:"
        service_impact_analysis
        echo ""
        
        echo "4. Recommendations:"
        generate_recommendations "$total_errors"
        
    } > "$report_file"
    
    echo "Report generated: $report_file"
}

# Generate actionable recommendations
generate_recommendations() {
    local error_count="$1"
    
    if [ "$error_count" -gt 100 ]; then
        echo "- Immediate investigation required"
        echo "- Check system resources (CPU, memory, disk)"
        echo "- Review service configurations"
        echo "- Consider scaling infrastructure"
    elif [ "$error_count" -gt 50 ]; then
        echo "- Schedule detailed analysis within 24 hours"
        echo "- Monitor error trends"
        echo "- Review recent changes"
    else
        echo "- Continue regular monitoring"
        echo "- Archive logs for trend analysis"
    fi
}
```

## Automated Intelligence Extraction

### 1. **Smart Pattern Detection**

```bash
# Detect anomalies automatically
anomaly_detection() {
    local logfile="$1"
    local service="$2"
    
    echo "=== Anomaly Detection for $service ==="
    
    # Get baseline error rate (last 7 days average)
    total_errors=0
    for i in {1..7}; do
        date_check=$(date -d "$i days ago" '+%b %d')
        daily_errors=$(grep "$date_check" "$logfile" | grep -i "$service" | grep -i error | wc -l)
        total_errors=$((total_errors + daily_errors))
    done
    baseline=$((total_errors / 7))
    
    # Get current error rate
    current_errors=$(grep "$(date '+%b %d')" "$logfile" | grep -i "$service" | grep -i error | wc -l)
    
    # Detect anomalies
    if [ "$current_errors" -gt $((baseline * 3)) ]; then
        echo "🚨 CRITICAL ANOMALY: Current errors ($current_errors) are 3x baseline ($baseline)"
    elif [ "$current_errors" -gt $((baseline * 2)) ]; then
        echo "⚠️  WARNING: Current errors ($current_errors) are 2x baseline ($baseline)"
    else
        echo "✅ NORMAL: Current errors ($current_errors) within baseline ($baseline)"
    fi
}

# Extract actionable insights
extract_insights() {
    local logfile="$1"
    
    echo "=== ACTIONABLE INSIGHTS ==="
    
    # Insight 1: Recurring patterns
    echo "1. RECURRING ISSUES:"
    recurring_patterns=$(grep -i error "$logfile" | \
        awk '{$1=$2=$3=""; print $0}' | \
        sort | uniq -c | sort -nr | head -3 | \
        awk '$1 > 5 {print "   - Occurs " $1 " times: " substr($0, index($0,$2))}')
    
    if [ -n "$recurring_patterns" ]; then
        echo "$recurring_patterns"
    else
        echo "   - No significant recurring patterns detected"
    fi
    
    # Insight 2: Service impact
    echo "2. SERVICE IMPACT:"
    critical_services=$(grep -i error "$logfile" | \
        grep -E "(httpd|nginx|mysql|postgres)" | wc -l)
    if [ "$critical_services" -gt 0 ]; then
        echo "   - $critical_services errors affecting critical services"
    else
        echo "   - No critical service impact detected"
    fi
    
    # Insight 3: Time patterns
    echo "3. TIME PATTERNS:"
    peak_hour=$(grep -i error "$logfile" | grep "$(date '+%b %d')" | \
        cut -d' ' -f3 | cut -d':' -f1 | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
    if [ -n "$peak_hour" ]; then
        echo "   - Peak error hour: ${peak_hour}:00"
    fi
}
```

### 2. **Automated Prioritization**

```bash
# Prioritize issues automatically
auto_prioritize() {
    local logfile="$1"
    
    echo "=== AUTOMATED ISSUE PRIORITIZATION ==="
    
    # Priority 1: Critical system failures
    p1_count=$(grep -i -E "(panic|fatal|critical.*system|kernel.*oops)" "$logfile" | wc -l)
    if [ "$p1_count" -gt 0 ]; then
        echo "🔴 PRIORITY 1 ($p1_count issues): System critical failures"
        grep -i -E "(panic|fatal|critical.*system)" "$logfile" | head -3 | sed 's/^/     /'
    fi
    
    # Priority 2: Service outages
    p2_count=$(grep -i -E "(service.*failed|connection.*refused|timeout.*error)" "$logfile" | wc -l)
    if [ "$p2_count" -gt 0 ]; then
        echo "🟡 PRIORITY 2 ($p2_count issues): Service availability"
        grep -i -E "(service.*failed|connection.*refused)" "$logfile" | head -2 | sed 's/^/     /'
    fi
    
    # Priority 3: Security concerns
    p3_count=$(grep -i -E "(authentication.*failed|access.*denied|privilege.*escalation)" "$logfile" | wc -l)
    if [ "$p3_count" -gt 5 ]; then  # Only if frequent
        echo "🟠 PRIORITY 3 ($p3_count issues): Security concerns"
        echo "     Multiple authentication failures detected"
    fi
    
    # Priority 4: Performance issues
    p4_count=$(grep -i -E "(slow.*response|high.*load|memory.*limit)" "$logfile" | wc -l)
    if [ "$p4_count" -gt 0 ]; then
        echo "🟢 PRIORITY 4 ($p4_count issues): Performance degradation"
    fi
}
```

## Real-World Analysis Workflows

### 1. **Incident Response Workflow**

```bash
#!/bin/bash
# Comprehensive incident analysis workflow
incident_analysis() {
    local service="$1"
    local time_window="${2:-60}"  # minutes
    
    echo "🚨 INCIDENT ANALYSIS: $service"
    echo "Time window: Last $time_window minutes"
    echo "======================================="
    
    # Step 1: Quick overview
    echo "1. QUICK OVERVIEW"
    recent_errors=$(grep -i "$service" /var/log/messages | \
                   grep "$(date '+%b %d %H:')" | \
                   grep -i error | wc -l)
    echo "   Recent errors: $recent_errors"
    
    # Step 2: Critical issues first
    echo "2. CRITICAL ISSUES"
    grep -i "$service" /var/log/messages | \
        grep -i -E "(critical|fatal|panic)" | \
        tail -3 | sed 's/^/   /'
    
    # Step 3: Error patterns
    echo "3. ERROR PATTERNS"
    grep -i "$service" /var/log/messages | \
        grep -i error | \
        awk '{$1=$2=$3=$4=$5=""; print $0}' | \
        sort | uniq -c | sort -nr | head -3 | \
        sed 's/^/   /'
    
    # Step 4: Timeline
    echo "4. RECENT TIMELINE"
    grep -i "$service" /var/log/messages | \
        grep "$(date '+%b %d %H:')" | \
        tail -5 | sed 's/^/   /'
    
    # Step 5: Recommendations
    echo "5. IMMEDIATE ACTIONS"
    if [ "$recent_errors" -gt 10 ]; then
        echo "   - Check service status: systemctl status $service"
        echo "   - Review configuration files"
        echo "   - Check system resources"
    else
        echo "   - Continue monitoring"
        echo "   - No immediate action required"
    fi
}

# Security incident analysis
security_analysis() {
    echo "🔒 SECURITY INCIDENT ANALYSIS"
    echo "============================="
    
    # Failed login analysis
    echo "1. AUTHENTICATION FAILURES"
    failed_logins=$(grep "Failed password" /var/log/auth.log | \
                   grep "$(date '+%b %d')" | wc -l)
    echo "   Total failed logins today: $failed_logins"
    
    if [ "$failed_logins" -gt 20 ]; then
        echo "   🚨 HIGH: Potential brute force attack"
        echo "   Top attacking IPs:"
        grep "Failed password" /var/log/auth.log | \
            grep "$(date '+%b %d')" | \
            awk '{print $11}' | sort | uniq -c | sort -nr | head -3 | \
            sed 's/^/      /'
    fi
    
    # Privilege escalation attempts
    echo "2. PRIVILEGE ESCALATION"
    sudo_failures=$(grep -E "sudo.*FAILED" /var/log/auth.log | \
                   grep "$(date '+%b %d')" | wc -l)
    echo "   Sudo failures today: $sudo_failures"
    
    # Unusual access patterns
    echo "3. UNUSUAL ACCESS PATTERNS"
    night_logins=$(grep "Accepted" /var/log/auth.log | \
                  grep "$(date '+%b %d')" | \
                  grep -E " 0[0-6]:[0-9]{2}:[0-9]{2}" | wc -l)
    echo "   Night-time logins (00:00-06:59): $night_logins"
}
```

### 2. **Performance Analysis Workflow**

```bash
# Performance degradation analysis
performance_analysis() {
    echo "⚡ PERFORMANCE ANALYSIS"
    echo "======================"
    
    # Memory issues
    echo "1. MEMORY ANALYSIS"
    oom_kills=$(grep -i "killed process" /var/log/messages | \
               grep "$(date '+%b %d')" | wc -l)
    echo "   OOM kills today: $oom_kills"
    
    if [ "$oom_kills" -gt 0 ]; then
        echo "   Recent OOM victims:"
        grep -i "killed process" /var/log/messages | \
            grep "$(date '+%b %d')" | \
            tail -3 | sed 's/^/      /'
    fi
    
    # Disk issues
    echo "2. DISK ANALYSIS"
    disk_errors=$(grep -i "disk.*error\|i/o.*error" /var/log/messages | \
                 grep "$(date '+%b %d')" | wc -l)
    echo "   Disk errors today: $disk_errors"
    
    # Application performance
    echo "3. APPLICATION PERFORMANCE"
    slow_queries=$(grep -i "slow" /var/log/mysql/error.log 2>/dev/null | wc -l)
    echo "   MySQL slow queries: $slow_queries"
    
    web_errors=$(grep -E " 5[0-9][0-9] " /var/log/httpd/access_log 2>/dev/null | \
                grep "$(date '+%d/%b/%Y')" | wc -l)
    echo "   Web server 5xx errors: $web_errors"
}
```

## Advanced Filtering Pipelines

### 1. **Multi-Stage Filtering Pipeline**

```bash
# Advanced multi-stage filtering
advanced_filter_pipeline() {
    local logfile="$1"
    local output_file="$2"
    
    # Stage 1: Time filtering (last 24 hours)
    grep "$(date '+%b %d')" "$logfile" |
    
    # Stage 2: Severity filtering (errors and above)
    grep -i -E "(error|critical|fatal|panic)" |
    
    # Stage 3: Noise reduction
    grep -v -E "(test|debug|info.*only)" |
    
    # Stage 4: Deduplication (similar messages)
    awk '!seen[substr($0,17,50)]++' |
    
    # Stage 5: Service priority filtering
    grep -E "(httpd|nginx|mysql|postgres|ssh)" |
    
    # Stage 6: Context enrichment
    while read line; do
        echo "$line"
        # Add context if this is a critical error
        if echo "$line" | grep -i -E "(critical|fatal)" > /dev/null; then
            echo "  >> REQUIRES IMMEDIATE ATTENTION"
        fi
    done > "$output_file"
    
    echo "Filtered results saved to: $output_file"
}

# Intelligent log analysis pipeline
intelligent_analysis() {
    local logfile="$1"
    
    echo "🤖 INTELLIGENT LOG ANALYSIS"
    echo "==========================="
    
    # Create temporary working files
    temp_dir=$(mktemp -d)
    raw_errors="$temp_dir/raw_errors.log"
    filtered_errors="$temp_dir/filtered_errors.log"
    analyzed_errors="$temp_dir/analyzed_errors.log"
    
    # Pipeline Stage 1: Extract relevant entries
    grep -i -E "(error|warning|critical|failed)" "$logfile" > "$raw_errors"
    
    # Pipeline Stage 2: Apply intelligent filtering
    advanced_filter_pipeline "$raw_errors" "$filtered_errors"
    
    # Pipeline Stage 3: Pattern analysis
    {
        echo "=== PATTERN ANALYSIS ==="
        awk '{print $5}' "$filtered_errors" | sort | uniq -c | sort -nr | head -5
        echo ""
        
        echo "=== TIME DISTRIBUTION ==="
        cut -d' ' -f3 "$filtered_errors" | cut -d':' -f1 | sort | uniq -c
        echo ""
        
        echo "=== TOP ISSUES ==="
        head -10 "$filtered_errors"
        
    } > "$analyzed_errors"
    
    # Display results
    cat "$analyzed_errors"
    
    # Cleanup
    rm -rf "$temp_dir"
}
```

### 2. **Real-Time Intelligence Pipeline**

```bash
# Real-time intelligent monitoring
real_time_intelligence() {
    echo "🔄 STARTING REAL-TIME INTELLIGENCE MONITORING"
    echo "============================================="
    
    tail -f /var/log/messages | while read line; do
        # Skip if not an error/warning
        if ! echo "$line" | grep -i -E "(error|warning|critical|failed)" > /dev/null; then
            continue
        fi
        
        # Extract key information
        timestamp=$(echo "$line" | awk '{print $1, $2, $3}')
        service=$(echo "$line" | awk '{print $5}')
        message=$(echo "$line" | cut -d' ' -f6-)
        
        # Intelligent classification
        if echo "$message" | grep -i -E "(critical|fatal|panic)" > /dev/null; then
            priority="🔴 CRITICAL"
            action="IMMEDIATE"
        elif echo "$message" | grep -i -E "(error.*failed|connection.*lost)" > /dev/null; then
            priority="🟡 HIGH"
            action="URGENT"
        elif echo "$message" | grep -i "warning" > /dev/null; then
            priority="🟢 MEDIUM"
            action="MONITOR"
        else
            priority="ℹ️  LOW"
            action="LOG"
        fi
        
        # Output intelligent alert
        echo "[$timestamp] $priority [$service] $action"
        echo "  Message: $message"
        echo "  ---"
        
        # Optional: Send alerts for critical issues
        if [ "$action" = "IMMEDIATE" ]; then
            echo "ALERT: Critical issue detected - $message" | logger -t INTELLIGENCE
        fi
    done
}
```

## Summary: From Raw Data to Intelligence

### The Information Extraction Process

```
Raw grep output → Filter → Group → Analyze → Visualize → Act
     (1M+ lines)    (10K)   (100)    (10)       (5)     (1-3)
```

### Key Principles for Useful Information Extraction:

1. **Start with Time Windows** - Focus on relevant timeframes
2. **Apply Severity Filters** - Critical issues first
3. **Remove Noise** - Filter out routine/expected messages  
4. **Group by Patterns** - Similar issues together
5. **Quantify Everything** - Counts, rates, trends
6. **Add Context** - Before/after events, correlations
7. **Prioritize Actions** - What needs immediate attention
8. **Automate Intelligence** - Scripts for recurring analysis

This systematic approach transforms overwhelming log data into actionable intelligence that drives effective troubleshooting and system management decisions.
