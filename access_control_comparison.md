# Access Control Mechanisms: DAC vs MAC vs SELinux

## Overview
This document compares three fundamental access control mechanisms used in computer security: Discretionary Access Control (DAC), Mandatory Access Control (MAC), and Security-Enhanced Linux (SELinux).

## 1. Discretionary Access Control (DAC)

### Definition
DAC is a type of access control where the owner of a resource has discretionary control over who can access that resource and what permissions they have.

### Key Characteristics
- **Owner-controlled**: Resource owners decide access permissions
- **User-centric**: Based on user identity and group membership
- **Flexible**: Easy to modify permissions
- **Default in most systems**: Standard Unix/Linux file permissions

### Implementation
- Traditional Unix file permissions (rwx for owner, group, others)
- Access Control Lists (ACLs) for more granular control
- Windows NTFS permissions

### Advantages
- Simple to understand and implement
- User-friendly and intuitive
- Flexible permission management
- Low administrative overhead

### Disadvantages
- Vulnerable to Trojan horse attacks
- No protection against malicious programs run by authorized users
- Difficult to enforce organization-wide security policies
- Users may accidentally grant excessive permissions

### Examples
```bash
# Traditional Unix permissions
chmod 755 myfile.txt
chown user:group myfile.txt

# ACL example
setfacl -m u:alice:rw myfile.txt
```

## 2. Mandatory Access Control (MAC)

### Definition
MAC is a type of access control where access decisions are made by the system based on security policies, not by individual users or resource owners.

### Key Characteristics
- **System-controlled**: Central authority controls all access decisions
- **Policy-based**: Governed by system-wide security policies
- **Non-discretionary**: Users cannot override security policies
- **Label-based**: Uses security labels/classifications

### Implementation Models
1. **Bell-LaPadula Model**: Focuses on confidentiality
   - "No read up" (simple security property)
   - "No write down" (*-property)

2. **Biba Model**: Focuses on integrity
   - "No read down"
   - "No write up"

3. **Multi-Level Security (MLS)**: Combines confidentiality and integrity

### Advantages
- Strong security enforcement
- Prevents unauthorized information flow
- Suitable for high-security environments
- Protects against insider threats
- Consistent policy enforcement

### Disadvantages
- Complex to configure and maintain
- Less flexible than DAC
- Higher administrative overhead
- Can impact system usability
- Requires careful policy design

### Examples
- Government/military classification systems (Top Secret, Secret, Confidential, Unclassified)
- SELinux MLS policies
- Windows Mandatory Integrity Control

## 3. Security-Enhanced Linux (SELinux)

### Definition
SELinux is a Linux kernel security module that provides a mechanism for supporting access control security policies, including mandatory access controls.

### Key Characteristics
- **Type Enforcement (TE)**: Primary security model
- **Role-Based Access Control (RBAC)**: User roles determine permissions
- **Multi-Level Security (MLS)**: Optional confidentiality levels
- **Fine-grained control**: Process-level and object-level policies

### Architecture Components
1. **Security Context**: Labels consisting of user:role:type:level
2. **Security Policy**: Rules defining allowed operations
3. **Access Vector Cache (AVC)**: Caches access decisions
4. **Security Server**: Makes access control decisions

### SELinux Modes
1. **Enforcing**: Policies are enforced, violations are blocked
2. **Permissive**: Policies are not enforced, but violations are logged
3. **Disabled**: SELinux is turned off

### Type Enforcement Model
- **Subjects**: Processes (domains)
- **Objects**: Files, sockets, etc. (types)
- **Actions**: Operations subjects can perform on objects

### Advantages
- Extremely fine-grained access control
- Principle of least privilege enforcement
- Comprehensive logging and auditing
- Flexible policy framework
- Active development and community support
- Default deny approach

### Disadvantages
- Steep learning curve
- Complex policy development
- Can break applications if not properly configured
- Performance overhead
- Debugging can be challenging

### Examples
```bash
# Check SELinux status
sestatus

# View security contexts
ls -Z /etc/passwd
ps -eZ

# Set file context
chcon -t httpd_exec_t /usr/local/bin/myapp

# Create custom policy module
audit2allow -a -M mypolicy
semodule -i mypolicy.pp
```

## Comparison Summary

| Aspect | DAC | MAC | SELinux |
|--------|-----|-----|---------|
| **Control** | User/Owner | System/Admin | System/Policy |
| **Flexibility** | High | Low | Medium-High |
| **Security Level** | Basic | High | Very High |
| **Complexity** | Low | Medium-High | High |
| **Performance Impact** | Minimal | Low-Medium | Medium |
| **Use Cases** | General computing | Classified systems | Hardened Linux |
| **Policy Override** | Yes (by owner) | No | No |
| **Granularity** | Coarse | Medium | Very Fine |

## When to Use Each

### Use DAC When:
- Standard desktop/server environments
- User convenience is priority
- Low-to-medium security requirements
- Simple administration needed

### Use MAC When:
- High-security environments
- Government/military applications
- Need to prevent information leakage
- Regulatory compliance required

### Use SELinux When:
- Linux server hardening needed
- Web servers and databases
- Container security
- Fine-grained access control required
- Defense in depth strategy

## Integration and Coexistence

### DAC + SELinux
- SELinux operates alongside traditional Unix permissions
- Both must allow access for operation to succeed
- SELinux provides additional layer of security

### MAC + SELinux
- SELinux can implement MAC policies
- MLS policies provide mandatory access control
- Type enforcement adds another dimension

## Best Practices

### For DAC:
- Follow principle of least privilege
- Regularly audit permissions
- Use groups effectively
- Implement ACLs for fine-grained control

### For MAC:
- Carefully design classification levels
- Train users on security labels
- Regular policy review and updates
- Monitor for policy violations

### For SELinux:
- Start with permissive mode
- Use targeted policy for most systems
- Leverage tools like audit2allow
- Keep policies updated
- Monitor AVC denials

## Conclusion

Each access control mechanism serves different security needs:

- **DAC** provides basic, user-friendly access control suitable for most general computing needs
- **MAC** offers strong, policy-driven security for high-security environments where information protection is paramount
- **SELinux** delivers comprehensive, fine-grained security controls that can implement both DAC and MAC concepts while providing additional protections

The choice depends on your security requirements, administrative capabilities, and the balance between security and usability in your environment. Many modern systems combine multiple approaches for defense in depth.
