# SSH Key Authentication Setup Guide

This document explains the process of setting up SSH key-based authentication between two Linux systems, as demonstrated in the terminal session.

## Overview

SSH key authentication provides a more secure and convenient way to connect to remote systems without entering passwords each time. This process involves generating a key pair, copying the public key to the target system, and managing the keys with an SSH agent.

## Step-by-Step Process

### 1. Generate SSH Key Pair

```bash
ssh-keygen -b 4096 -t rsa
```

or if you already have existing key just skip to Step 2


**Command Breakdown:**
- `ssh-keygen`: Tool for generating SSH key pairs
- `-b 4096`: Specifies the key length (4096 bits for enhanced security)
- `-t rsa`: Specifies the key type (RSA algorithm)

**What Happens:**
- Generates a public/private RSA key pair
- Private key saved to `/root/.ssh/id_rsa` (kept secret)
- Public key saved to `/root/.ssh/id_rsa.pub` (shared with remote systems)
- Prompts for passphrase (optional but recommended for additional security)
- Creates a unique key fingerprint: `SHA256:cdo97UKWO5wCGIumPhUL4RO71BdRRI0X9zb1f8+QTRo`
- Displays randomart image for visual key identification

### 2. Copy Public Key to Remote System

```bash
ssh-copy-id watsondebuser@192.168.16.194
```

**Command Breakdown:**
- `ssh-copy-id`: Utility to copy SSH public keys to remote systems
- `watsondebuser@192.168.16.194`: Target user and IP address

**What Happens:**
- Copies the public key from `/root/.ssh/id_rsa.pub` to the remote system
- Adds the key to `/home/watsondebuser/.ssh/authorized_keys` on the target system
- Requires the target user's password for initial setup
- Confirms that 1 key was successfully added

### 3. Start SSH Agent

```bash
eval $(ssh-agent)
```

**Command Breakdown:**
- `ssh-agent`: Background program that manages SSH keys
- `eval $()`: Executes the output of ssh-agent to set environment variables
- Agent PID: 32926

**Purpose:**
- Manages private keys in memory
- Eliminates need to enter passphrase for each SSH connection
- Provides secure key management during the session

### 4. Add Private Key to SSH Agent

```bash
ssh-add
```

**What Happens:**
- Adds the private key (`/root/.ssh/id_rsa`) to the SSH agent
- Prompts for the passphrase (entered during key generation)
- Key is now loaded in memory for automatic use
- Identity confirmed: `root@wanikwairhel10vm1`

### 5. Test SSH Connection

```bash
# Typo in original command
shh watsondebuser@192.168.16.194
# Error: -bash: shh: command not found

# Correct command
ssh watsondebuser@192.168.16.194
```

**Successful Connection:**
- No password prompt (key authentication worked)
- Connected to Debian system: `wanikwaideb13c2vm1`
- Kernel version: `6.12.41+deb13-amd64`
- Last login timestamp shown

## Security Benefits

1. **No Password Transmission**: Private key never leaves the source system
2. **Strong Encryption**: 4096-bit RSA provides robust security
3. **Passphrase Protection**: Additional layer of security for private key
4. **Agent Management**: Keys stored securely in memory during session

## File Locations

- **Private Key**: `/root/.ssh/id_rsa` (source system)
- **Public Key**: `/root/.ssh/id_rsa.pub` (source system)
- **Authorized Keys**: `/home/watsondebuser/.ssh/authorized_keys` (target system)

## Best Practices

1. **Use Strong Passphrases**: Protect private keys with complex passphrases
2. **Appropriate Key Length**: 4096-bit RSA or ED25519 keys recommended
3. **Regular Key Rotation**: Replace keys periodically for enhanced security
4. **Secure Private Keys**: Never share private keys; keep them on secure systems only
5. **SSH Agent Usage**: Use SSH agent to avoid repeated passphrase entry

## Troubleshooting

- **Permission Issues**: Ensure `.ssh` directory has 700 permissions and key files have 600 permissions
- **Connection Failures**: Verify SSH service is running on target system
- **Key Not Working**: Check if public key was correctly added to `authorized_keys`
- **Agent Issues**: Restart SSH agent if keys aren't being recognized

## System Information

- **Source System**: `wanikwairhel10vm1` (RHEL 10)
- **Target System**: `wanikwaideb13c2vm1` (Debian)
- **User Account**: `watsondebuser`
- **IP Address**: `192.168.16.194`

This setup enables secure, password-less SSH connections between the systems while maintaining strong authentication through public key cryptography.
