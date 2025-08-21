# Post-grep Analysis Tools: Deep Dive into Filtered Data

## Table of Contents
- [The Analysis Pipeline](#the-analysis-pipeline)
- [Text Processing and Analysis Tools](#text-processing-and-analysis-tools)
- [Statistical Analysis Tools](#statistical-analysis-tools)
- [Visualization and Reporting Tools](#visualization-and-reporting-tools)
- [Database and Query Tools](#database-and-query-tools)
- [Specialized Log Analysis Tools](#specialized-log-analysis-tools)
- [Programming Languages for Analysis](#programming-languages-for-analysis)
- [Real-Time Analysis Tools](#real-time-analysis-tools)
- [Integration and Workflow Tools](#integration-and-workflow-tools)
- [Advanced Analytics and Machine Learning](#advanced-analytics-and-machine-learning)

## The Analysis Pipeline

### From Filtered Data to Insights

```
grep Results → Text Processing → Statistical Analysis → Visualization → Action
     ↓              ↓                    ↓                  ↓           ↓
  (Filtered)    (awk/sed/cut)      (R/Python)         (Graphs/Charts)  (Alerts)
   10K lines      Structured         Patterns          Dashboards      Tickets
                    Data            Correlations        Reports        Fixes
```

### Analysis Workflow Categories

| Stage | Tools | Purpose | Output |
|-------|-------|---------|--------|
| **Text Processing** | awk, sed, cut, sort, uniq | Structure and clean data | Normalized datasets |
| **Statistical Analysis** | R, Python, Excel | Find patterns, trends, correlations | Statistical insights |
| **Visualization** | gnuplot, matplotlib, Grafana | Create charts, graphs, dashboards | Visual representations |
| **Database Storage** | SQLite, MySQL, InfluxDB | Store and query historical data | Structured queries |
| **Reporting** | LaTeX, Jupyter, markdown | Generate reports and documentation | Professional reports |

## Text Processing and Analysis Tools

### 1. **awk - Pattern Scanning and Processing**

```bash
# Extract and analyze specific fields from grep results
grep "error" /var/log/messages | awk '
{
    # Extract timestamp, service, and error count
    date = $1 " " $2
    time = $3
    service = $5
    
    # Count errors by service
    service_errors[service]++
    
    # Count errors by hour
    hour = substr(time, 1, 2)
    hourly_errors[hour]++
    
    # Track error messages
    error_msg = ""
    for(i=6; i<=NF; i++) error_msg = error_msg $i " "
    message_count[error_msg]++
}
END {
    print "=== ERROR ANALYSIS REPORT ==="
    print "\n1. ERRORS BY SERVICE:"
    for(svc in service_errors) {
        printf "   %-20s: %d\n", svc, service_errors[svc]
    }
    
    print "\n2. ERRORS BY HOUR:"
    for(h in hourly_errors) {
        printf "   %02d:00: %d errors\n", h, hourly_errors[h]
    }
    
    print "\n3. TOP ERROR MESSAGES:"
    # Sort by frequency (requires external sort)
    for(msg in message_count) {
        if(message_count[msg] > 2) {
            printf "   [%d] %s\n", message_count[msg], substr(msg, 1, 60)
        }
    }
}'

# Advanced awk analysis with calculations
analyze_response_times() {
    grep "response_time" access.log | awk '
    {
        response_time = $NF
        total_time += response_time
        count++
        
        # Track response time buckets
        if(response_time < 100) fast++
        else if(response_time < 500) medium++
        else if(response_time < 1000) slow++
        else very_slow++
        
        # Track by endpoint
        endpoint = $7
        endpoint_times[endpoint] += response_time
        endpoint_count[endpoint]++
    }
    END {
        avg_time = total_time / count
        
        print "=== RESPONSE TIME ANALYSIS ==="
        printf "Average response time: %.2f ms\n", avg_time
        printf "Total requests: %d\n\n", count
        
        print "Response Time Distribution:"
        printf "  Fast (<100ms):     %d (%.1f%%)\n", fast, (fast/count)*100
        printf "  Medium (100-500):  %d (%.1f%%)\n", medium, (medium/count)*100
        printf "  Slow (500-1000):   %d (%.1f%%)\n", slow, (slow/count)*100
        printf "  Very Slow (>1000): %d (%.1f%%)\n", very_slow, (very_slow/count)*100
        
        print "\nSlowest Endpoints:"
        for(ep in endpoint_times) {
            avg_ep = endpoint_times[ep] / endpoint_count[ep]
            if(avg_ep > avg_time * 1.5) {
                printf "  %-30s: %.2f ms (%d requests)\n", ep, avg_ep, endpoint_count[ep]
            }
        }
    }'
}
```

### 2. **sed - Stream Editor for Filtering and Transformation**

```bash
# Clean and transform grep results
process_error_logs() {
    grep "ERROR" application.log | 
    sed 's/\[.*\]//g' |                    # Remove bracketed timestamps
    sed 's/ERROR:/ERROR /g' |              # Normalize error prefix
    sed 's/  */ /g' |                      # Collapse multiple spaces
    sed '/test\|debug/d' |                 # Remove test/debug lines
    sed 's/.*ERROR \(.*\)/\1/' |           # Extract just the error message
    sort | uniq -c | sort -nr              # Count and sort by frequency
}

# Extract specific patterns and reformat
extract_ip_analysis() {
    grep "failed login" auth.log |
    sed -n 's/.*from \([0-9.]*\).*/\1/p' | # Extract IP addresses
    sort | uniq -c | sort -nr |             # Count occurrences
    sed 's/^ *\([0-9]*\) \(.*\)/\2: \1 attempts/' # Reformat output
}

# Transform timestamps to standard format
normalize_timestamps() {
    grep "error" mixed_format.log |
    sed 's/\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)/\3\/\2\/\1/g' | # ISO to DD/MM/YYYY
    sed 's/T/ /g' |                        # Replace T with space
    sed 's/\.[0-9]*Z//g'                   # Remove milliseconds and Z
}
```

### 3. **cut, sort, uniq - Data Extraction and Aggregation**

```bash
# Field extraction and analysis pipeline
analyze_log_patterns() {
    local logfile="$1"
    
    echo "=== LOG PATTERN ANALYSIS ==="
    
    # Most common error types
    echo "1. Most Common Error Types:"
    grep -i error "$logfile" |
    cut -d' ' -f5- |                       # Get message part
    cut -d':' -f1 |                        # Get error type
    sort | uniq -c | sort -nr | head -10
    
    # Hourly distribution
    echo -e "\n2. Hourly Error Distribution:"
    grep -i error "$logfile" |
    cut -d' ' -f3 |                        # Extract time
    cut -d':' -f1 |                        # Get hour
    sort -n | uniq -c |
    awk '{printf "%02d:00 - %d errors\n", $2, $1}'
    
    # Top source IPs (if applicable)
    echo -e "\n3. Top Source IPs:"
    grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "$logfile" |
    grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' |
    sort | uniq -c | sort -nr | head -10
}

# Complex field extraction with multiple delimiters
extract_complex_fields() {
    # Extract user, action, and result from complex log format
    grep "user_action" application.log |
    cut -d'|' -f2,4,6 |                    # Extract specific fields
    tr '|' '\t' |                          # Convert to tab-separated
    sort -k2 | uniq -c |                   # Sort by action, count
    awk '{printf "%-20s %-15s: %d times\n", $3, $4, $1}'
}
```

## Statistical Analysis Tools

### 1. **R - Statistical Computing and Graphics**

```r
# R script for log analysis
#!/usr/bin/env Rscript

# Read filtered grep results
analyze_error_trends <- function(logfile) {
    # Read the log data
    data <- read.table(logfile, header=FALSE, sep=" ", fill=TRUE, 
                       col.names=c("month", "day", "time", "host", "service", "message"))
    
    # Convert time to proper format
    data$datetime <- as.POSIXct(paste(data$month, data$day, data$time), 
                               format="%b %d %H:%M:%S")
    
    # Error frequency analysis
    error_counts <- table(data$service)
    
    # Create visualizations
    png("error_distribution.png", width=800, height=600)
    barplot(sort(error_counts, decreasing=TRUE)[1:10], 
            main="Top 10 Services by Error Count",
            las=2, cex.names=0.8)
    dev.off()
    
    # Time series analysis
    hourly_errors <- aggregate(rep(1, nrow(data)), 
                              by=list(hour=format(data$datetime, "%H")), 
                              FUN=sum)
    
    png("hourly_trends.png", width=800, height=600)
    plot(hourly_errors$hour, hourly_errors$x, type="b",
         main="Hourly Error Distribution",
         xlab="Hour of Day", ylab="Error Count")
    dev.off()
    
    # Statistical summary
    cat("=== STATISTICAL ANALYSIS ===\n")
    cat("Total errors:", nrow(data), "\n")
    cat("Unique services:", length(unique(data$service)), "\n")
    cat("Time span:", range(data$datetime), "\n")
    
    # Return analysis results
    return(list(
        total_errors = nrow(data),
        top_services = head(sort(error_counts, decreasing=TRUE), 5),
        peak_hour = hourly_errors$hour[which.max(hourly_errors$x)]
    ))
}

# Correlation analysis
correlation_analysis <- function(error_log, performance_log) {
    # Read both datasets
    errors <- read.table(error_log, header=FALSE)
    performance <- read.table(performance_log, header=FALSE)
    
    # Create time series
    error_ts <- ts(errors$V1, frequency=24)  # Hourly data
    perf_ts <- ts(performance$V1, frequency=24)
    
    # Calculate correlation
    correlation <- cor(error_ts, perf_ts, use="complete.obs")
    
    cat("Correlation between errors and performance:", correlation, "\n")
    
    # Plot correlation
    png("correlation_plot.png", width=800, height=600)
    plot(error_ts, perf_ts, 
         main=paste("Error vs Performance Correlation (r =", round(correlation, 3), ")"),
         xlab="Error Count", ylab="Performance Metric")
    abline(lm(perf_ts ~ error_ts), col="red")
    dev.off()
}

# Anomaly detection
detect_anomalies <- function(data_file) {
    data <- read.table(data_file, header=FALSE)$V1
    
    # Calculate statistical thresholds
    mean_val <- mean(data, na.rm=TRUE)
    sd_val <- sd(data, na.rm=TRUE)
    
    # Identify anomalies (values beyond 2 standard deviations)
    anomalies <- which(abs(data - mean_val) > 2 * sd_val)
    
    cat("Detected", length(anomalies), "anomalies\n")
    cat("Anomaly values:", data[anomalies], "\n")
    
    return(anomalies)
}
```

### 2. **Python - Data Analysis and Visualization**

```python
#!/usr/bin/env python3
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import re

class LogAnalyzer:
    def __init__(self, log_file):
        self.log_file = log_file
        self.df = self.parse_logs()
    
    def parse_logs(self):
        """Parse grep results into structured DataFrame"""
        data = []
        with open(self.log_file, 'r') as f:
            for line in f:
                # Parse standard syslog format
                parts = line.strip().split()
                if len(parts) >= 5:
                    timestamp = f"{parts[0]} {parts[1]} {parts[2]}"
                    hostname = parts[3]
                    service = parts[4].rstrip(':')
                    message = ' '.join(parts[5:])
                    
                    data.append({
                        'timestamp': timestamp,
                        'hostname': hostname,
                        'service': service,
                        'message': message
                    })
        
        df = pd.DataFrame(data)
        
        # Convert timestamp to datetime
        current_year = datetime.now().year
        df['datetime'] = pd.to_datetime(f"{current_year} " + df['timestamp'], 
                                       format='%Y %b %d %H:%M:%S')
        
        return df
    
    def service_analysis(self):
        """Analyze errors by service"""
        service_counts = self.df['service'].value_counts()
        
        # Create visualization
        plt.figure(figsize=(12, 8))
        service_counts.head(10).plot(kind='bar')
        plt.title('Top 10 Services by Error Count')
        plt.xlabel('Service')
        plt.ylabel('Error Count')
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.savefig('service_analysis.png')
        plt.close()
        
        return service_counts
    
    def temporal_analysis(self):
        """Analyze error patterns over time"""
        # Hourly analysis
        self.df['hour'] = self.df['datetime'].dt.hour
        hourly_counts = self.df['hour'].value_counts().sort_index()
        
        # Daily analysis
        self.df['day'] = self.df['datetime'].dt.day
        daily_counts = self.df['day'].value_counts().sort_index()
        
        # Create subplots
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))
        
        # Hourly distribution
        hourly_counts.plot(kind='line', ax=ax1, marker='o')
        ax1.set_title('Hourly Error Distribution')
        ax1.set_xlabel('Hour of Day')
        ax1.set_ylabel('Error Count')
        
        # Daily distribution
        daily_counts.plot(kind='bar', ax=ax2)
        ax2.set_title('Daily Error Distribution')
        ax2.set_xlabel('Day of Month')
        ax2.set_ylabel('Error Count')
        
        plt.tight_layout()
        plt.savefig('temporal_analysis.png')
        plt.close()
        
        return hourly_counts, daily_counts
    
    def message_clustering(self):
        """Cluster similar error messages"""
        from sklearn.feature_extraction.text import TfidfVectorizer
        from sklearn.cluster import KMeans
        
        # Vectorize messages
        vectorizer = TfidfVectorizer(max_features=100, stop_words='english')
        message_vectors = vectorizer.fit_transform(self.df['message'])
        
        # Perform clustering
        n_clusters = min(10, len(self.df) // 10)  # Adaptive cluster count
        kmeans = KMeans(n_clusters=n_clusters, random_state=42)
        clusters = kmeans.fit_predict(message_vectors)
        
        # Add clusters to dataframe
        self.df['cluster'] = clusters
        
        # Analyze clusters
        cluster_analysis = {}
        for i in range(n_clusters):
            cluster_messages = self.df[self.df['cluster'] == i]['message']
            cluster_analysis[i] = {
                'count': len(cluster_messages),
                'sample_messages': cluster_messages.head(3).tolist()
            }
        
        return cluster_analysis
    
    def anomaly_detection(self):
        """Detect anomalous error patterns"""
        # Calculate hourly error rates
        hourly_errors = self.df.groupby([self.df['datetime'].dt.date, 
                                        self.df['datetime'].dt.hour]).size()
        
        # Statistical anomaly detection
        mean_rate = hourly_errors.mean()
        std_rate = hourly_errors.std()
        threshold = mean_rate + 2 * std_rate
        
        anomalies = hourly_errors[hourly_errors > threshold]
        
        print(f"Detected {len(anomalies)} anomalous hours:")
        for (date, hour), count in anomalies.items():
            print(f"  {date} {hour:02d}:00 - {count} errors (threshold: {threshold:.1f})")
        
        return anomalies
    
    def generate_report(self):
        """Generate comprehensive analysis report"""
        print("=== LOG ANALYSIS REPORT ===")
        print(f"Total records analyzed: {len(self.df)}")
        print(f"Date range: {self.df['datetime'].min()} to {self.df['datetime'].max()}")
        print(f"Unique services: {self.df['service'].nunique()}")
        
        # Service analysis
        print("\nTop 5 Services by Error Count:")
        service_counts = self.service_analysis()
        for service, count in service_counts.head(5).items():
            print(f"  {service}: {count}")
        
        # Temporal analysis
        print("\nTemporal Analysis:")
        hourly, daily = self.temporal_analysis()
        peak_hour = hourly.idxmax()
        peak_day = daily.idxmax()
        print(f"  Peak error hour: {peak_hour:02d}:00 ({hourly.max()} errors)")
        print(f"  Peak error day: {peak_day} ({daily.max()} errors)")
        
        # Anomaly detection
        print("\nAnomaly Detection:")
        anomalies = self.anomaly_detection()
        
        # Message clustering
        print("\nMessage Clustering:")
        clusters = self.message_clustering()
        for cluster_id, info in clusters.items():
            print(f"  Cluster {cluster_id}: {info['count']} messages")
            for msg in info['sample_messages']:
                print(f"    - {msg[:60]}...")

# Usage example
if __name__ == "__main__":
    analyzer = LogAnalyzer('filtered_errors.log')
    analyzer.generate_report()
```

### 3. **GNU Plot - Command-line Plotting**

```bash
# Create time-series plots from grep results
create_error_timeline() {
    local logfile="$1"
    
    # Extract hourly error counts
    grep -i error "$logfile" | 
    awk '{print substr($3,1,2)}' | 
    sort -n | uniq -c | 
    awk '{print $2, $1}' > hourly_errors.dat
    
    # Generate gnuplot script
    cat << 'EOF' > plot_errors.gp
set terminal png size 800,600
set output 'error_timeline.png'
set title 'Hourly Error Distribution'
set xlabel 'Hour of Day'
set ylabel 'Error Count'
set grid
set style data linespoints
plot 'hourly_errors.dat' using 1:2 title 'Errors' with linespoints pt 7
EOF
    
    # Generate plot
    gnuplot plot_errors.gp
    echo "Plot saved as error_timeline.png"
}

# Create service comparison chart
create_service_comparison() {
    local logfile="$1"
    
    # Extract service error counts
    grep -i error "$logfile" | 
    awk '{print $5}' | 
    sort | uniq -c | sort -nr | head -10 | 
    awk '{print NR, $1, "\"" $2 "\""}' > service_errors.dat
    
    # Generate gnuplot script
    cat << 'EOF' > plot_services.gp
set terminal png size 1000,600
set output 'service_comparison.png'
set title 'Top 10 Services by Error Count'
set ylabel 'Error Count'
set style data histograms
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xtic rotate by -45 scale 0
plot 'service_errors.dat' using 2:xtic(3) title 'Errors' with boxes
EOF
    
    gnuplot plot_services.gp
    echo "Service comparison saved as service_comparison.png"
}

# Create correlation heatmap
create_correlation_matrix() {
    local logfile="$1"
    
    # Create data matrix (hour vs service)
    awk '{
        hour = substr($3,1,2)
        service = $5
        matrix[hour][service]++
    }
    END {
        # Output matrix format for gnuplot
        for(h=0; h<24; h++) {
            for(s in service_list) {
                printf "%d %s %d\n", h, s, (matrix[h][s] ? matrix[h][s] : 0)
            }
        }
    }' "$logfile" > correlation_matrix.dat
    
    # Create heatmap plot
    cat << 'EOF' > heatmap.gp
set terminal png size 1200,800
set output 'error_heatmap.png'
set title 'Error Distribution Heatmap (Hour vs Service)'
set xlabel 'Hour'
set ylabel 'Service'
set pm3d map
set palette defined (0 "blue", 1 "green", 2 "yellow", 3 "red")
splot 'correlation_matrix.dat' using 1:2:3
EOF
    
    gnuplot heatmap.gp
    echo "Heatmap saved as error_heatmap.png"
}
```

## Database and Query Tools

### 1. **SQLite - Lightweight Database Analysis**

```bash
#!/bin/bash
# Import grep results into SQLite for analysis

create_log_database() {
    local logfile="$1"
    local dbfile="logs.db"
    
    # Create database schema
    sqlite3 "$dbfile" << 'EOF'
CREATE TABLE IF NOT EXISTS log_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT,
    hostname TEXT,
    service TEXT,
    message TEXT,
    severity TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_timestamp ON log_entries(timestamp);
CREATE INDEX IF NOT EXISTS idx_service ON log_entries(service);
CREATE INDEX IF NOT EXISTS idx_severity ON log_entries(severity);
EOF
    
    # Parse and import log data
    awk '{
        timestamp = $1 " " $2 " " $3
        hostname = $4
        service = $5
        gsub(":", "", service)  # Remove colon from service name
        message = ""
        for(i=6; i<=NF; i++) message = message $i " "
        
        # Determine severity
        severity = "INFO"
        if(match(message, /[Ee][Rr][Rr][Oo][Rr]/)) severity = "ERROR"
        if(match(message, /[Ww][Aa][Rr][Nn]/)) severity = "WARN"
        if(match(message, /[Cc][Rr][Ii][Tt][Ii][Cc][Aa][Ll]/)) severity = "CRITICAL"
        if(match(message, /[Ff][Aa][Tt][Aa][Ll]/)) severity = "FATAL"
        
        # Escape single quotes for SQL
        gsub("'\''", "'\'''\''", message)
        
        print "INSERT INTO log_entries (timestamp, hostname, service, message, severity) VALUES (" \
              "'\'''"timestamp"'\'', '\''" hostname "'\'', '\''" service "'\'', '\''" message "'\'', '\''" severity "'\'');"
    }' "$logfile" | sqlite3 "$dbfile"
    
    echo "Database created: $dbfile"
}

# Advanced SQL queries for log analysis
run_log_queries() {
    local dbfile="logs.db"
    
    echo "=== DATABASE LOG ANALYSIS ==="
    
    # Top services by error count
    echo "1. Top Services by Error Count:"
    sqlite3 -column -header "$dbfile" << 'EOF'
SELECT service, COUNT(*) as error_count, 
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM log_entries), 2) as percentage
FROM log_entries 
WHERE severity IN ('ERROR', 'CRITICAL', 'FATAL')
GROUP BY service 
ORDER BY error_count DESC 
LIMIT 10;
EOF
    
    # Hourly error distribution
    echo -e "\n2. Hourly Error Distribution:"
    sqlite3 -column -header "$dbfile" << 'EOF'
SELECT substr(timestamp, -8, 2) as hour, 
       COUNT(*) as error_count,
       AVG(LENGTH(message)) as avg_msg_length
FROM log_entries 
WHERE severity IN ('ERROR', 'CRITICAL', 'FATAL')
GROUP BY hour 
ORDER BY hour;
EOF
    
    # Error trends by severity
    echo -e "\n3. Error Trends by Severity:"
    sqlite3 -column -header "$dbfile" << 'EOF'
SELECT severity, COUNT(*) as count,
       MIN(timestamp) as first_occurrence,
       MAX(timestamp) as last_occurrence
FROM log_entries 
GROUP BY severity 
ORDER BY count DESC;
EOF
    
    # Services with increasing error rates
    echo -e "\n4. Services with Recent Error Spikes:"
    sqlite3 -column -header "$dbfile" << 'EOF'
WITH recent_errors AS (
    SELECT service, COUNT(*) as recent_count
    FROM log_entries 
    WHERE datetime(created_at) > datetime('now', '-1 hour')
    AND severity IN ('ERROR', 'CRITICAL', 'FATAL')
    GROUP BY service
),
historical_avg AS (
    SELECT service, COUNT(*)/24.0 as avg_hourly
    FROM log_entries 
    WHERE datetime(created_at) <= datetime('now', '-1 hour')
    AND severity IN ('ERROR', 'CRITICAL', 'FATAL')
    GROUP BY service
)
SELECT r.service, r.recent_count, 
       COALESCE(h.avg_hourly, 0) as historical_avg,
       ROUND(r.recent_count / COALESCE(h.avg_hourly, 1), 2) as spike_ratio
FROM recent_errors r
LEFT JOIN historical_avg h ON r.service = h.service
WHERE r.recent_count > COALESCE(h.avg_hourly, 1) * 2
ORDER BY spike_ratio DESC;
EOF
    
    # Most common error patterns
    echo -e "\n5. Most Common Error Patterns:"
    sqlite3 -column -header "$dbfile" << 'EOF'
SELECT substr(message, 1, 50) as error_pattern, 
       COUNT(*) as occurrences,
       GROUP_CONCAT(DISTINCT service) as affected_services
FROM log_entries 
WHERE severity IN ('ERROR', 'CRITICAL', 'FATAL')
GROUP BY substr(message, 1, 50)
HAVING occurrences > 2
ORDER BY occurrences DESC 
LIMIT 15;
EOF
}
```

### 2. **InfluxDB - Time Series Database**

```bash
# Import log data into InfluxDB for time series analysis
import_to_influxdb() {
    local logfile="$1"
    local database="logs"
    
    # Create database
    curl -POST "http://localhost:8086/query" --data-urlencode "q=CREATE DATABASE $database"
    
    # Convert log entries to InfluxDB line protocol
    awk '{
        # Parse timestamp (convert to epoch nanoseconds)
        cmd = "date -d \"" $1 " " $2 " " $3 "\" +%s%N"
        cmd | getline timestamp
        close(cmd)
        
        service = $5
        gsub(":", "", service)
        
        # Extract numeric values if present
        error_count = 1
        response_time = 0
        if(match($0, /response_time:([0-9.]+)/, arr)) {
            response_time = arr[1]
        }
        
        # Determine severity level (numeric)
        severity_level = 1
        if(match($0, /ERROR/)) severity_level = 2
        if(match($0, /CRITICAL/)) severity_level = 3
        if(match($0, /FATAL/)) severity_level = 4
        
        # Output InfluxDB line protocol format
        printf "errors,service=%s,hostname=%s error_count=%d,response_time=%f,severity=%d %s\n", 
               service, $4, error_count, response_time, severity_level, timestamp
    }' "$logfile" > influx_data.txt
    
    # Import data
    curl -i -XPOST "http://localhost:8086/write?db=$database" --data-binary @influx_data.txt
    
    echo "Data imported to InfluxDB database: $database"
}

# Query InfluxDB for analysis
query_influxdb_analysis() {
    local database="logs"
    
    # Error rate over time
    echo "=== TIME SERIES ANALYSIS ==="
    echo "1. Error rate over time (last 24 hours):"
    curl -G "http://localhost:8086/query" \
        --data-urlencode "db=$database" \
        --data-urlencode "q=SELECT SUM(error_count) FROM errors WHERE time > now() - 24h GROUP BY time(1h)"
    
    # Service error trends
    echo -e "\n2. Service error trends:"
    curl -G "http://localhost:8086/query" \
        --data-urlencode "db=$database" \
        --data-urlencode "q=SELECT service, SUM(error_count) FROM errors WHERE time > now() - 24h GROUP BY service ORDER BY SUM(error_count) DESC LIMIT 10"
    
    # Average severity over time
    echo -e "\n3. Average severity trends:"
    curl -G "http://localhost:8086/query" \
        --data-urlencode "db=$database" \
        --data-urlencode "q=SELECT MEAN(severity) FROM errors WHERE time > now() - 24h GROUP BY time(1h)"
}
```

## Specialized Log Analysis Tools

### 1. **ELK Stack Integration (Elasticsearch, Logstash, Kibana)**

```bash
# Send filtered grep results to Elasticsearch
send_to_elasticsearch() {
    local logfile="$1"
    local index="filtered-logs-$(date +%Y.%m.%d)"
    local elasticsearch_url="http://localhost:9200"
    
    # Process each log line and send to Elasticsearch
    while IFS= read -r line; do
        # Parse log line
        timestamp=$(echo "$line" | awk '{print $1, $2, $3}')
        hostname=$(echo "$line" | awk '{print $4}')
        service=$(echo "$line" | awk '{print $5}' | tr -d ':')
        message=$(echo "$line" | cut -d' ' -f6-)
        
        # Convert to ISO timestamp
        iso_timestamp=$(date -d "$timestamp" -u +"%Y-%m-%dT%H:%M:%S.000Z")
        
        # Create JSON document
        json_doc=$(cat <<EOF
{
  "@timestamp": "$iso_timestamp",
  "hostname": "$hostname",
  "service": "$service",
  "message": "$message",
  "level": "$(echo "$message" | grep -o -i 'error\|warn\|info\|critical' | head -1 | tr '[:lower:]' '[:upper:]')",
  "source": "filtered-logs"
}
EOF
)
        
        # Send to Elasticsearch
        curl -X POST "$elasticsearch_url/$index/_doc" \
             -H "Content-Type: application/json" \
             -d "$json_doc" >/dev/null 2>&1
        
    done < "$logfile"
    
    echo "Logs sent to Elasticsearch index: $index"
}

# Create Kibana visualizations programmatically
create_kibana_dashboards() {
    local kibana_url="http://localhost:5601"
    
    # Create index pattern
    curl -X POST "$kibana_url/api/saved_objects/index-pattern/filtered-logs-*" \
         -H "Content-Type: application/json" \
         -H "kbn-xsrf: true" \
         -d '{
           "attributes": {
             "title": "filtered-logs-*",
             "timeFieldName": "@timestamp"
           }
         }'
    
    # Create visualization for service errors
    curl -X POST "$kibana_url/api/saved_objects/visualization" \
         -H "Content-Type: application/json" \
         -H "kbn-xsrf: true" \
         -d '{
           "attributes": {
             "title": "Service Error Distribution",
             "visState": "{\"type\":\"histogram\",\"params\":{\"grid\":{\"categoryLines\":false,\"style\":{\"color\":\"#eee\"}},\"categoryAxes\":[{\"id\":\"CategoryAxis-1\",\"type\":\"category\",\"position\":\"bottom\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\"},\"labels\":{\"show\":true,\"truncate\":100},\"title\":{}}],\"valueAxes\":[{\"id\":\"ValueAxis-1\",\"name\":\"LeftAxis-1\",\"type\":\"value\",\"position\":\"left\",\"show\":true,\"style\":{},\"scale\":{\"type\":\"linear\",\"mode\":\"normal\"},\"labels\":{\"show\":true,\"rotate\":0,\"filter\":false,\"truncate\":100},\"title\":{\"text\":\"Count\"}}],\"seriesParams\":[{\"show\":true,\"type\":\"histogram\",\"mode\":\"stacked\",\"data\":{\"label\":\"Count\",\"id\":\"1\"},\"valueAxis\":\"ValueAxis-1\",\"drawLinesBetweenPoints\":true,\"showCircles\":true}],\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"times\":[],\"addTimeMarker\":false}}",
             "uiStateJSON": "{}",
             "kibanaSavedObjectMeta": {
               "searchSourceJSON": "{\"index\":\"filtered-logs-*\",\"query\":{\"match_all\":{}},\"filter\":[]}"
             }
           }
         }'
}
```

### 2. **Splunk Integration**

```bash
# Send data to Splunk via HTTP Event Collector
send_to_splunk() {
    local logfile="$1"
    local splunk_url="https://localhost:8088/services/collector"
    local hec_token="your-hec-token-here"
    
    # Process log file and send to Splunk
    while IFS= read -r line; do
        # Parse log components
        timestamp=$(echo "$line" | awk '{print $1, $2, $3}')
        hostname=$(echo "$line" | awk '{print $4}')
        service=$(echo "$line" | awk '{print $5}' | tr -d ':')
        message=$(echo "$line" | cut -d' ' -f6-)
        
        # Convert to epoch time
        epoch_time=$(date -d "$timestamp" +%s)
        
        # Create Splunk event JSON
        event_json=$(cat <<EOF
{
  "time": $epoch_time,
  "host": "$hostname",
  "source": "filtered-logs",
  "sourcetype": "syslog",
  "event": {
    "service": "$service",
    "message": "$message",
    "original": "$line"
  }
}
EOF
)
        
        # Send to Splunk
        curl -k "$splunk_url" \
             -H "Authorization: Splunk $hec_token" \
             -H "Content-Type: application/json" \
             -d "$event_json" >/dev/null 2>&1
        
    done < "$logfile"
    
    echo "Data sent to Splunk"
}
```

### 3. **GoAccess - Web Log Analyzer**

```bash
# Analyze web server logs from grep results
analyze_web_logs() {
    local filtered_access_log="$1"
    
    # Generate real-time HTML report
    goaccess "$filtered_access_log" \
        --log-format=COMBINED \
        --output=web_analysis_report.html \
        --real-time-html \
        --ws-url=ws://localhost:7890 \
        --port=7890 \
        --daemonize
    
    # Generate JSON output for further processing
    goaccess "$filtered_access_log" \
        --log-format=COMBINED \
        --output=web_analysis.json \
        --output-format=json
    
    echo "Web analysis report generated:"
    echo "  HTML Report: web_analysis_report.html"
    echo "  JSON Data: web_analysis.json"
    echo "  Real-time dashboard: http://localhost:7890"
}

# Custom GoAccess configuration for specific analysis
create_goaccess_config() {
    cat > goaccess.conf << 'EOF'
# Custom GoAccess configuration for filtered logs

# Time format
time-format %H:%M:%S

# Date format  
date-format %d/%b/%Y

# Log format for custom filtered logs
log-format %h %^[%d:%t %^] "%r" %s %b "%R" "%u"

# Enable specific panels
enable-panel VISITORS
enable-panel REQUESTS  
enable-panel STATIC_REQUESTS
enable-panel NOT_FOUND
enable-panel HOSTS
enable-panel OS
enable-panel BROWSERS
enable-panel STATUS_CODES

# Custom colors and styling
color-scheme 2
html-custom-css /path/to/custom.css
html-custom-js /path/to/custom.js

# Real-time settings
real-time-html
ws-url ws://localhost:7890
port 7890

# Output settings
output web_filtered_analysis.html
output-format html
EOF
    
    echo "GoAccess configuration created: goaccess.conf"
}
```

## Real-Time Analysis Tools

### 1. **Grafana Integration**

```bash
# Set up Grafana dashboard for real-time log analysis
setup_grafana_dashboard() {
    local grafana_url="http://localhost:3000"
    local grafana_user="admin"
    local grafana_pass="admin"
    
    # Create datasource (assuming InfluxDB backend)
    curl -X POST "$grafana_url/api/datasources" \
         -u "$grafana_user:$grafana_pass" \
         -H "Content-Type: application/json" \
         -d '{
           "name": "LogAnalysis",
           "type": "influxdb",
           "url": "http://localhost:8086",
           "database": "logs",
           "access": "proxy"
         }'
    
    # Create dashboard JSON
    cat > log_dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Log Analysis Dashboard",
    "tags": ["logs", "analysis"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Error Rate Over Time",
        "type": "graph",
        "targets": [
          {
            "query": "SELECT sum(error_count) FROM errors WHERE $timeFilter GROUP BY time(5m)",
            "refId": "A"
          }
        ],
        "xAxis": {"show": true},
        "yAxes": [{"label": "Errors per 5min", "show": true}],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Top Services by Errors", 
        "type": "table",
        "targets": [
          {
            "query": "SELECT service, sum(error_count) FROM errors WHERE $timeFilter GROUP BY service ORDER BY sum(error_count) DESC LIMIT 10",
            "refId": "B"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "id": 3,
        "title": "Severity Distribution",
        "type": "piechart", 
        "targets": [
          {
            "query": "SELECT mean(severity) FROM errors WHERE $timeFilter GROUP BY severity",
            "refId": "C"
          }
        ],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 8}
      }
    ],
    "time": {"from": "now-1h", "to": "now"},
    "refresh": "5s"
  }
}
EOF
    
    # Import dashboard
    curl -X POST "$grafana_url/api/dashboards/db" \
         -u "$grafana_user:$grafana_pass" \
         -H "Content-Type: application/json" \
         -d @log_dashboard.json
    
    echo "Grafana dashboard created for log analysis"
}
```

### 2. **Stream Processing with Apache Kafka**

```bash
# Send filtered logs to Kafka for stream processing
send_to_kafka() {
    local logfile="$1"
    local kafka_topic="filtered-logs"
    local kafka_broker="localhost:9092"
    
    # Create topic if it doesn't exist
    kafka-topics.sh --create \
        --bootstrap-server "$kafka_broker" \
        --topic "$kafka_topic" \
        --partitions 3 \
        --replication-factor 1 \
        --if-not-exists
    
    # Stream log data to Kafka
    while IFS= read -r line; do
        # Create JSON message
        json_message=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "raw_log": "$line",
  "parsed": {
    "hostname": "$(echo "$line" | awk '{print $4}')",
    "service": "$(echo "$line" | awk '{print $5}' | tr -d ':')",
    "message": "$(echo "$line" | cut -d' ' -f6-)"
  }
}
EOF
)
        
        # Send to Kafka
        echo "$json_message" | kafka-console-producer.sh \
            --bootstrap-server "$kafka_broker" \
            --topic "$kafka_topic"
        
    done < "$logfile"
    
    echo "Logs streamed to Kafka topic: $kafka_topic"
}
```

## Advanced Analytics and Machine Learning

### 1. **Anomaly Detection with Python/scikit-learn**

```python
#!/usr/bin/env python3
import numpy as np
import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
from sklearn.feature_extraction.text import TfidfVectorizer
import matplotlib.pyplot as plt

class LogAnomalyDetector:
    def __init__(self, log_file):
        self.log_file = log_file
        self.data = self.load_and_preprocess()
        
    def load_and_preprocess(self):
        """Load and preprocess log data for ML analysis"""
        data = []
        with open(self.log_file, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 5:
                    # Extract features
                    hour = int(parts[2].split(':')[0])
                    service = parts[4].rstrip(':')
                    message = ' '.join(parts[5:])
                    message_length = len(message)
                    
                    data.append({
                        'hour': hour,
                        'service': service,
                        'message': message,
                        'message_length': message_length,
                        'original_line': line.strip()
                    })
        
        return pd.DataFrame(data)
    
    def detect_temporal_anomalies(self):
        """Detect anomalies in temporal patterns"""
        # Create hourly error counts
        hourly_counts = self.data.groupby('hour').size()
        
        # Reshape for sklearn
        X = hourly_counts.values.reshape(-1, 1)
        
        # Fit Isolation Forest
        iso_forest = IsolationForest(contamination=0.1, random_state=42)
        anomalies = iso_forest.fit_predict(X)
        
        # Identify anomalous hours
        anomalous_hours = hourly_counts.index[anomalies == -1]
        
        print("Temporal Anomalies Detected:")
        for hour in anomalous_hours:
            print(f"  Hour {hour:02d}:00 - {hourly_counts[hour]} errors (unusual)")
        
        # Plot results
        plt.figure(figsize=(12, 6))
        plt.bar(hourly_counts.index, hourly_counts.values, alpha=0.7)
        plt.bar(anomalous_hours, hourly_counts[anomalous_hours], 
                color='red', alpha=0.8, label='Anomalous Hours')
        plt.xlabel('Hour of Day')
        plt.ylabel('Error Count')
        plt.title('Temporal Anomaly Detection')
        plt.legend()
        plt.savefig('temporal_anomalies.png')
        plt.close()
        
        return anomalous_hours
    
    def detect_message_anomalies(self):
        """Detect anomalous error messages using text analysis"""
        # Vectorize messages
        vectorizer = TfidfVectorizer(max_features=200, stop_words='english')
        message_vectors = vectorizer.fit_transform(self.data['message'])
        
        # Add numerical features
        numerical_features = self.data[['hour', 'message_length']].values
        scaler = StandardScaler()
        numerical_features = scaler.fit_transform(numerical_features)
        
        # Combine features
        from scipy.sparse import hstack
        combined_features = hstack([message_vectors, numerical_features])
        
        # Detect anomalies
        iso_forest = IsolationForest(contamination=0.05, random_state=42)
        anomalies = iso_forest.fit_predict(combined_features)
        
        # Get anomalous messages
        anomalous_messages = self.data[anomalies == -1]
        
        print(f"\nMessage Anomalies Detected ({len(anomalous_messages)} messages):")
        for idx, row in anomalous_messages.head(10).iterrows():
            print(f"  [{row['service']}] {row['message'][:80]}...")
        
        return anomalous_messages
    
    def cluster_error_patterns(self):
        """Cluster similar error patterns"""
        from sklearn.cluster import KMeans
        
        # Vectorize messages
        vectorizer = TfidfVectorizer(max_features=100, stop_words='english')
        message_vectors = vectorizer.fit_transform(self.data['message'])
        
        # Perform clustering
        n_clusters = min(8, len(self.data) // 20)
        kmeans = KMeans(n_clusters=n_clusters, random_state=42)
        clusters = kmeans.fit_predict(message_vectors)
        
        # Analyze clusters
        self.data['cluster'] = clusters
        
        print(f"\nError Pattern Clustering ({n_clusters} clusters):")
        for i in range(n_clusters):
            cluster_data = self.data[self.data['cluster'] == i]
            cluster_size = len(cluster_data)
            top_services = cluster_data['service'].value_counts().head(3)
            sample_message = cluster_data['message'].iloc[0][:60]
            
            print(f"  Cluster {i}: {cluster_size} messages")
            print(f"    Top services: {', '.join([f'{s}({c})' for s, c in top_services.items()])}")
            print(f"    Sample: {sample_message}...")
            print()
        
        return clusters

# Usage example
if __name__ == "__main__":
    detector = LogAnomalyDetector('filtered_errors.log')
    
    # Run different types of anomaly detection
    temporal_anomalies = detector.detect_temporal_anomalies()
    message_anomalies = detector.detect_message_anomalies()
    clusters = detector.cluster_error_patterns()
```

### 2. **Predictive Analysis with Time Series**

```python
#!/usr/bin/env python3
import pandas as pd
import numpy as np
from statsmodels.tsa.arima.model import ARIMA
from statsmodels.tsa.seasonal import seasonal_decompose
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings('ignore')

class ErrorPredictor:
    def __init__(self, log_file):
        self.log_file = log_file
        self.time_series = self.create_time_series()
    
    def create_time_series(self):
        """Create hourly time series from log data"""
        data = []
        with open(self.log_file, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 3:
                    # Extract timestamp and create datetime
                    timestamp = f"2024 {parts[0]} {parts[1]} {parts[2]}"
                    try:
                        dt = pd.to_datetime(timestamp, format='%Y %b %d %H:%M:%S')
                        data.append(dt)
                    except:
                        continue
        
        # Create hourly counts
        df = pd.DataFrame({'timestamp': data})
        df.set_index('timestamp', inplace=True)
        hourly_counts = df.resample('1H').size()
        
        return hourly_counts
    
    def analyze_trends(self):
        """Perform trend analysis and seasonal decomposition"""
        # Perform seasonal decomposition
        decomposition = seasonal_decompose(self.time_series, 
                                         model='additive', 
                                         period=24)  # Daily seasonality
        
        # Plot decomposition
        fig, axes = plt.subplots(4, 1, figsize=(15, 12))
        
        decomposition.observed.plot(ax=axes[0], title='Original')
        decomposition.trend.plot(ax=axes[1], title='Trend')
        decomposition.seasonal.plot(ax=axes[2], title='Seasonal')
        decomposition.resid.plot(ax=axes[3], title='Residual')
        
        plt.tight_layout()
        plt.savefig('time_series_decomposition.png')
        plt.close()
        
        # Calculate trend statistics
        trend_slope = np.polyfit(range(len(decomposition.trend.dropna())), 
                                decomposition.trend.dropna(), 1)[0]
        
        print("=== TIME SERIES ANALYSIS ===")
        print(f"Trend slope: {trend_slope:.4f} errors/hour")
        print(f"Average hourly errors: {self.time_series.mean():.2f}")
        print(f"Peak seasonal effect: {decomposition.seasonal.max():.2f}")
        print(f"Minimum seasonal effect: {decomposition.seasonal.min():.2f}")
        
        return decomposition
    
    def predict_future_errors(self, periods=24):
        """Predict future error rates using ARIMA model"""
        # Fit ARIMA model
        model = ARIMA(self.time_series, order=(2, 1, 2))
        fitted_model = model.fit()
        
        # Make predictions
        forecast = fitted_model.forecast(steps=periods)
        conf_int = fitted_model.get_forecast(steps=periods).conf_int()
        
        # Create future timestamps
        last_timestamp = self.time_series.index[-1]
        future_timestamps = pd.date_range(start=last_timestamp + pd.Timedelta(hours=1),
                                        periods=periods, freq='1H')
        
        # Plot predictions
        plt.figure(figsize=(15, 8))
        
        # Plot historical data
        self.time_series[-48:].plot(label='Historical', alpha=0.7)
        
        # Plot predictions
        plt.plot(future_timestamps, forecast, 'r-', label='Forecast')
        plt.fill_between(future_timestamps, 
                        conf_int.iloc[:, 0], 
                        conf_int.iloc[:, 1], 
                        color='red', alpha=0.2, label='Confidence Interval')
        
        plt.xlabel('Time')
        plt.ylabel('Error Count')
        plt.title('Error Rate Prediction (Next 24 Hours)')
        plt.legend()
        plt.grid(True, alpha=0.3)
        plt.savefig('error_prediction.png')
        plt.close()
        
        print(f"\n=== PREDICTIONS (Next {periods} Hours) ===")
        for i, (timestamp, predicted) in enumerate(zip(future_timestamps, forecast)):
            if predicted > self.time_series.mean() * 1.5:
                status = "⚠️  HIGH"
            elif predicted < self.time_series.mean() * 0.5:
                status = "✅ LOW"
            else:
                status = "📊 NORMAL"
            
            print(f"{timestamp.strftime('%Y-%m-%d %H:%M')}: {predicted:.1f} errors {status}")
        
        return forecast, conf_int
    
    def detect_anomalies_statistical(self):
        """Detect statistical anomalies in time series"""
        # Calculate rolling statistics
        rolling_mean = self.time_series.rolling(window=24).mean()
        rolling_std = self.time_series.rolling(window=24).std()
        
        # Define anomaly thresholds (3 sigma rule)
        upper_threshold = rolling_mean + 3 * rolling_std
        lower_threshold = rolling_mean - 3 * rolling_std
        
        # Find anomalies
        anomalies = self.time_series[(self.time_series > upper_threshold) | 
                                   (self.time_series < lower_threshold)]
        
        print(f"\n=== STATISTICAL ANOMALIES ===")
        print(f"Found {len(anomalies)} anomalous time periods:")
        
        for timestamp, value in anomalies.items():
            expected = rolling_mean[timestamp]
            deviation = abs(value - expected) / rolling_std[timestamp]
            print(f"  {timestamp}: {value} errors (expected: {expected:.1f}, {deviation:.1f}σ deviation)")
        
        return anomalies

# Usage example
if __name__ == "__main__":
    predictor = ErrorPredictor('filtered_errors.log')
    
    # Run analysis
    decomposition = predictor.analyze_trends()
    forecast, conf_int = predictor.predict_future_errors()
    anomalies = predictor.detect_anomalies_statistical()
```

## Summary: Complete Analysis Toolkit

### Analysis Pipeline Overview

```
Filtered grep Data
        ↓
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Text Processing │    │ Statistical      │    │ Visualization   │
│ • awk/sed/cut   │ → │ Analysis         │ → │ • Charts/Graphs │
│ • sort/uniq     │    │ • R/Python       │    │ • Dashboards    │
│ • Custom scripts│    │ • SQL queries    │    │ • Reports       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
        ↓                       ↓                       ↓
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Database Storage│    │ Machine Learning │    │ Real-time       │
│ • SQLite        │    │ • Anomaly detect │    │ Monitoring      │
│ • InfluxDB      │    │ • Pattern recog  │    │ • Grafana       │
│ • Elasticsearch │    │ • Predictions    │    │ • Alerting      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Tool Categories and Use Cases

| Category | Tools | Best For | Output |
|----------|-------|----------|--------|
| **Text Processing** | awk, sed, cut, sort, uniq | Data cleaning, field extraction | Structured data |
| **Statistical Analysis** | R, Python, SQL | Pattern discovery, trends | Insights, correlations |
| **Visualization** | gnuplot, matplotlib, Grafana | Charts, dashboards | Visual reports |
| **Database Analysis** | SQLite, InfluxDB, Elasticsearch | Complex queries, historical analysis | Query results |
| **Machine Learning** | Python scikit-learn, TensorFlow | Anomaly detection, predictions | ML models |
| **Real-time Processing** | Kafka, Grafana, ELK Stack | Live monitoring, alerting | Dashboards, alerts |

### Choosing the Right Tool

1. **For Quick Analysis**: awk, sed, cut, sort, uniq
2. **For Statistical Analysis**: R or Python with pandas/numpy
3. **For Visualization**: matplotlib/seaborn (Python) or ggplot2 (R)
4. **For Large Datasets**: Database tools (SQLite, InfluxDB)
5. **For Real-time Analysis**: Grafana, ELK Stack, Kafka
6. **For Advanced Analytics**: Python/R with ML libraries
7. **For Reporting**: Jupyter notebooks, R Markdown, LaTeX

The key is to match the tool to your analysis needs, data volume, and desired output format. Start simple with text processing tools, then escalate to more sophisticated tools as your analysis requirements grow.
