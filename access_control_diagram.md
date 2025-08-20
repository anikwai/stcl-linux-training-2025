# Access Control Mechanisms - Mermaid Diagrams

## 1. Complete Access Control Comparison Overview

```mermaid
graph TB
    subgraph "Access Control Mechanisms"
        DAC["DAC<br/>Discretionary Access Control"]
        MAC["MAC<br/>Mandatory Access Control"]
        SELINUX["SELinux<br/>Security-Enhanced Linux"]
    end
    
    subgraph "DAC Characteristics"
        DAC --> DAC_OWNER["Owner Controlled"]
        DAC --> DAC_FLEX["High Flexibility"]
        DAC --> DAC_SIMPLE["Simple Implementation"]
        DAC --> DAC_VULN["Vulnerable to Trojans"]
        
        DAC_OWNER --> DAC_UNIX["Unix Permissions<br/>chmod, chown"]
        DAC_OWNER --> DAC_ACL["Access Control Lists<br/>setfacl"]
        DAC_OWNER --> DAC_NTFS["Windows NTFS<br/>Properties"]
    end
    
    subgraph "MAC Characteristics"
        MAC --> MAC_SYSTEM["System Controlled"]
        MAC --> MAC_POLICY["Policy Based"]
        MAC --> MAC_LABEL["Label Based"]
        MAC --> MAC_SECURE["High Security"]
        
        MAC_POLICY --> MAC_BELL["Bell-LaPadula<br/>No Read Up/Write Down"]
        MAC_POLICY --> MAC_BIBA["Biba Model<br/>Integrity Focus"]
        MAC_POLICY --> MAC_MLS["Multi-Level Security<br/>Classifications"]
    end
    
    subgraph "SELinux Characteristics"
        SELINUX --> SEL_TE["Type Enforcement"]
        SELINUX --> SEL_RBAC["Role-Based Access"]
        SELINUX --> SEL_MLS_OPT["Optional MLS"]
        SELINUX --> SEL_FINE["Fine-Grained Control"]
        
        SEL_TE --> SEL_DOMAIN["Process Domains"]
        SEL_TE --> SEL_TYPE["Object Types"]
        SEL_RBAC --> SEL_USER["SELinux Users"]
        SEL_RBAC --> SEL_ROLE["SELinux Roles"]
    end
    
    subgraph "Security Levels"
        BASIC["Basic Security<br/>DAC"]
        HIGH["High Security<br/>MAC"]
        VERYHIGH["Very High Security<br/>SELinux"]
        
        BASIC --> |Escalates to| HIGH
        HIGH --> |Enhanced by| VERYHIGH
    end
    
    subgraph "Use Cases"
        GENERAL["General Computing<br/>Desktop/Server"]
        CLASSIFIED["Classified Systems<br/>Government/Military"]
        HARDENED["Hardened Linux<br/>Web Servers/Containers"]
        
        DAC -.-> GENERAL
        MAC -.-> CLASSIFIED
        SELINUX -.-> HARDENED
    end
    
    classDef dacStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef macStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef selinuxStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    
    class DAC,DAC_OWNER,DAC_FLEX,DAC_SIMPLE,DAC_VULN,DAC_UNIX,DAC_ACL,DAC_NTFS,BASIC,GENERAL dacStyle
    class MAC,MAC_SYSTEM,MAC_POLICY,MAC_LABEL,MAC_SECURE,MAC_BELL,MAC_BIBA,MAC_MLS,HIGH,CLASSIFIED macStyle
    class SELINUX,SEL_TE,SEL_RBAC,SEL_MLS_OPT,SEL_FINE,SEL_DOMAIN,SEL_TYPE,SEL_USER,SEL_ROLE,VERYHIGH,HARDENED selinuxStyle
```

## 2. DAC (Discretionary Access Control) Detailed Flow

```mermaid
flowchart TD
    START([User Requests Access]) --> DAC_CHECK{DAC Permission Check}
    
    DAC_CHECK --> |Check Owner| OWNER{Is User Owner?}
    DAC_CHECK --> |Check Group| GROUP{Is User in Group?}
    DAC_CHECK --> |Check Others| OTHERS{Check Other Permissions}
    
    OWNER --> |Yes| OWNER_PERM{Owner Permissions<br/>rwx}
    OWNER --> |No| GROUP
    
    GROUP --> |Yes| GROUP_PERM{Group Permissions<br/>rwx}
    GROUP --> |No| OTHERS
    
    OTHERS --> OTHER_PERM{Other Permissions<br/>rwx}
    
    OWNER_PERM --> |Read Allowed| READ_ACCESS[Grant Read Access]
    OWNER_PERM --> |Write Allowed| WRITE_ACCESS[Grant Write Access]
    OWNER_PERM --> |Execute Allowed| EXEC_ACCESS[Grant Execute Access]
    OWNER_PERM --> |Denied| ACCESS_DENIED[Access Denied]
    
    GROUP_PERM --> |Read Allowed| READ_ACCESS
    GROUP_PERM --> |Write Allowed| WRITE_ACCESS
    GROUP_PERM --> |Execute Allowed| EXEC_ACCESS
    GROUP_PERM --> |Denied| ACCESS_DENIED
    
    OTHER_PERM --> |Read Allowed| READ_ACCESS
    OTHER_PERM --> |Write Allowed| WRITE_ACCESS
    OTHER_PERM --> |Execute Allowed| EXEC_ACCESS
    OTHER_PERM --> |Denied| ACCESS_DENIED
    
    subgraph "DAC Tools"
        CHMOD[chmod 755 file]
        CHOWN[chown user:group file]
        SETFACL[setfacl -m u:alice:rw file]
    end
    
    subgraph "DAC Vulnerabilities"
        TROJAN[Trojan Horse Attacks]
        MALWARE[Malicious Programs]
        USER_ERROR[User Permission Errors]
    end
    
    READ_ACCESS -.-> TROJAN
    WRITE_ACCESS -.-> MALWARE
    EXEC_ACCESS -.-> USER_ERROR
    
    classDef processStyle fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef grantStyle fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef denyStyle fill:#ffebee,stroke:#c62828,stroke-width:2px
    classDef vulnerStyle fill:#fce4ec,stroke:#ad1457,stroke-width:2px
    
    class START,DAC_CHECK,OWNER,GROUP,OTHERS,OWNER_PERM,GROUP_PERM,OTHER_PERM processStyle
    class READ_ACCESS,WRITE_ACCESS,EXEC_ACCESS grantStyle
    class ACCESS_DENIED denyStyle
    class TROJAN,MALWARE,USER_ERROR vulnerStyle
```

## 3. MAC (Mandatory Access Control) Security Model

```mermaid
graph TB
    subgraph "MAC Security Labels"
        TS[Top Secret]
        S[Secret]
        C[Confidential]
        U[Unclassified]
        
        TS --> S --> C --> U
    end
    
    subgraph "Bell-LaPadula Model"
        subgraph "Simple Security Property"
            NO_READ_UP["No Read Up<br/>Subject cannot read<br/>objects at higher level"]
        end
        
        subgraph "★-Property (Star Property)"
            NO_WRITE_DOWN["No Write Down<br/>Subject cannot write<br/>to objects at lower level"]
        end
    end
    
    subgraph "Biba Integrity Model"
        subgraph "Simple Integrity Property"
            NO_READ_DOWN["No Read Down<br/>Subject cannot read<br/>objects at lower integrity"]
        end
        
        subgraph "★-Integrity Property"
            NO_WRITE_UP["No Write Up<br/>Subject cannot write<br/>to objects at higher integrity"]
        end
    end
    
    subgraph "MAC Access Decision Flow"
        USER_REQUEST[User Access Request] --> SYSTEM_CHECK{System Policy Check}
        
        SYSTEM_CHECK --> LABEL_CHECK{Check Security Labels}
        LABEL_CHECK --> CLEARANCE{User Clearance Level}
        LABEL_CHECK --> OBJECT_CLASS{Object Classification}
        
        CLEARANCE --> POLICY_EVAL{Policy Evaluation}
        OBJECT_CLASS --> POLICY_EVAL
        
        POLICY_EVAL --> |Bell-LaPadula| CONF_CHECK{Confidentiality Rules}
        POLICY_EVAL --> |Biba| INT_CHECK{Integrity Rules}
        
        CONF_CHECK --> |Allowed| GRANT_ACCESS[Grant Access]
        CONF_CHECK --> |Denied| DENY_ACCESS[Deny Access]
        INT_CHECK --> |Allowed| GRANT_ACCESS
        INT_CHECK --> |Denied| DENY_ACCESS
    end
    
    subgraph "MAC Implementation Examples"
        GOV[Government Systems]
        MIL[Military Networks]
        SELINUX_MLS[SELinux MLS Policy]
        WIN_MIC[Windows Mandatory<br/>Integrity Control]
    end
    
    TS -.-> GOV
    S -.-> MIL
    C -.-> SELINUX_MLS
    U -.-> WIN_MIC
    
    classDef labelStyle fill:#e3f2fd,stroke:#0277bd,stroke-width:2px
    classDef ruleStyle fill:#f1f8e9,stroke:#388e3c,stroke-width:2px
    classDef processStyle fill:#fff8e1,stroke:#f57c00,stroke-width:2px
    classDef grantStyle fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef denyStyle fill:#ffebee,stroke:#c62828,stroke-width:2px
    
    class TS,S,C,U labelStyle
    class NO_READ_UP,NO_WRITE_DOWN,NO_READ_DOWN,NO_WRITE_UP ruleStyle
    class USER_REQUEST,SYSTEM_CHECK,LABEL_CHECK,CLEARANCE,OBJECT_CLASS,POLICY_EVAL,CONF_CHECK,INT_CHECK processStyle
    class GRANT_ACCESS grantStyle
    class DENY_ACCESS denyStyle
```

## 4. SELinux Architecture and Components

```mermaid
graph TB
    subgraph "SELinux Architecture"
        subgraph "User Space"
            APP[Applications]
            SELINUX_UTILS[SELinux Utilities<br/>sestatus, setsebool, etc.]
            POLICY_TOOLS[Policy Tools<br/>audit2allow, checkpolicy]
        end
        
        subgraph "Kernel Space"
            LSM[Linux Security Module<br/>Framework]
            SELINUX_MODULE[SELinux Module]
            AVC[Access Vector Cache]
            SECURITY_SERVER[Security Server]
        end
        
        subgraph "Policy Store"
            POLICY_DB[(Policy Database)]
            CONTEXTS[Security Contexts]
            RULES[Access Rules]
        end
    end
    
    APP --> LSM
    LSM --> SELINUX_MODULE
    SELINUX_MODULE --> AVC
    AVC --> SECURITY_SERVER
    SECURITY_SERVER --> POLICY_DB
    POLICY_DB --> CONTEXTS
    POLICY_DB --> RULES
    
    subgraph "SELinux Security Context"
        CONTEXT["user:role:type:level<br/>system_u:object_r:httpd_exec_t:s0"]
        
        CONTEXT --> USER_COMP[User Component<br/>system_u, user_u, root]
        CONTEXT --> ROLE_COMP[Role Component<br/>object_r, system_r, user_r]
        CONTEXT --> TYPE_COMP[Type Component<br/>httpd_exec_t, etc_t]
        CONTEXT --> LEVEL_COMP[Level Component<br/>s0, s0:c0.c1023]
    end
    
    subgraph "SELinux Modes"
        ENFORCING[Enforcing Mode<br/>Policies enforced<br/>Violations blocked]
        PERMISSIVE[Permissive Mode<br/>Policies not enforced<br/>Violations logged]
        DISABLED[Disabled Mode<br/>SELinux turned off]
        
        ENFORCING --> |setenforce 0| PERMISSIVE
        PERMISSIVE --> |setenforce 1| ENFORCING
        ENFORCING --> |Edit /etc/selinux/config| DISABLED
        DISABLED --> |Edit /etc/selinux/config<br/>Reboot required| ENFORCING
    end
    
    subgraph "Type Enforcement Model"
        SUBJECT[Subject<br/>Process/Domain]
        OBJECT[Object<br/>File/Socket/etc.]
        ACTION[Action<br/>read, write, execute]
        
        SUBJECT --> |wants to perform| ACTION
        ACTION --> |on| OBJECT
        
        TE_RULE[Type Enforcement Rule<br/>allow httpd_t httpd_config_t:file read;]
        
        ACTION -.-> TE_RULE
    end
    
    subgraph "SELinux Tools and Commands"
        SESTATUS[sestatus<br/>Check SELinux status]
        LS_Z[ls -Z<br/>View file contexts]
        PS_Z[ps -eZ<br/>View process contexts]
        CHCON[chcon<br/>Change context]
        RESTORECON[restorecon<br/>Restore default context]
        SETSEBOOL[setsebool<br/>Set boolean values]
        AUDIT2ALLOW[audit2allow<br/>Generate policy from logs]
        SEMODULE[semodule<br/>Manage policy modules]
    end
    
    classDef userSpaceStyle fill:#e1f5fe,stroke:#0277bd,stroke-width:2px
    classDef kernelStyle fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef policyStyle fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef contextStyle fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef modeStyle fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef toolStyle fill:#f1f8e9,stroke:#558b2f,stroke-width:2px
    
    class APP,SELINUX_UTILS,POLICY_TOOLS userSpaceStyle
    class LSM,SELINUX_MODULE,AVC,SECURITY_SERVER kernelStyle
    class POLICY_DB,CONTEXTS,RULES policyStyle
    class CONTEXT,USER_COMP,ROLE_COMP,TYPE_COMP,LEVEL_COMP contextStyle
    class ENFORCING,PERMISSIVE,DISABLED modeStyle
    class SESTATUS,LS_Z,PS_Z,CHCON,RESTORECON,SETSEBOOL,AUDIT2ALLOW,SEMODULE toolStyle
```

## 5. Access Control Decision Flow Comparison

```mermaid
flowchart TD
    REQUEST[Access Request] --> DAC_CHECK{DAC Check}
    REQUEST --> MAC_CHECK{MAC Check}
    REQUEST --> SEL_CHECK{SELinux Check}
    
    %% DAC Decision Path
    subgraph "DAC_FLOW [DAC Decision Flow]"
        DAC_CHECK --> DAC_OWNER{Is User Owner?}
        DAC_OWNER -->|Yes| DAC_OWNER_PERM[Check Owner Permissions]
        DAC_OWNER -->|No| DAC_GROUP{In Group?}
        DAC_GROUP -->|Yes| DAC_GROUP_PERM[Check Group Permissions]
        DAC_GROUP -->|No| DAC_OTHER_PERM[Check Other Permissions]
        
        DAC_OWNER_PERM --> DAC_RESULT{Permission Granted?}
        DAC_GROUP_PERM --> DAC_RESULT
        DAC_OTHER_PERM --> DAC_RESULT
        
        DAC_RESULT -->|Yes| DAC_ALLOW[DAC: ALLOW]
        DAC_RESULT -->|No| DAC_DENY[DAC: DENY]
    end
    
    %% MAC Decision Path  
    subgraph "MAC_FLOW [MAC Decision Flow]"
        MAC_CHECK --> MAC_LABELS[Check Security Labels]
        MAC_LABELS --> MAC_CLEARANCE[User Clearance Level]
        MAC_LABELS --> MAC_CLASSIFICATION[Object Classification]
        
        MAC_CLEARANCE --> MAC_RULES{Policy Rules}
        MAC_CLASSIFICATION --> MAC_RULES
        
        MAC_RULES --> MAC_BELL[Bell-LaPadula Check]
        MAC_RULES --> MAC_BIBA[Biba Integrity Check]
        
        MAC_BELL --> MAC_RESULT{System Policy Allow?}
        MAC_BIBA --> MAC_RESULT
        
        MAC_RESULT -->|Yes| MAC_ALLOW[MAC: ALLOW]
        MAC_RESULT -->|No| MAC_DENY[MAC: DENY]
    end
    
    %% SELinux Decision Path
    subgraph "SEL_FLOW [SELinux Decision Flow]"
        SEL_CHECK --> SEL_AVC{AVC Cache Hit?}
        
        SEL_AVC -->|Yes| SEL_CACHED[Use Cached Result]
        SEL_AVC -->|No| SEL_SERVER[Query Security Server]
        
        SEL_SERVER --> SEL_CONTEXT[Check Security Contexts]
        SEL_CONTEXT --> SEL_RULES[Evaluate Policy Rules]
        
        SEL_RULES --> SEL_TE[Type Enforcement]
        SEL_RULES --> SEL_RBAC[RBAC Check]
        SEL_RULES --> SEL_MLS[MLS Check]
        
        SEL_TE --> SEL_DECISION{All Rules Allow?}
        SEL_RBAC --> SEL_DECISION
        SEL_MLS --> SEL_DECISION
        
        SEL_DECISION -->|Yes| SEL_CACHE_ALLOW[Cache Allow & Grant]
        SEL_DECISION -->|No| SEL_CACHE_DENY[Cache Deny & Block]
        
        SEL_CACHED --> SEL_FINAL_RESULT{Cached Decision}
        SEL_CACHE_ALLOW --> SEL_ALLOW[SELinux: ALLOW]
        SEL_CACHE_DENY --> SEL_DENY[SELinux: DENY]
        SEL_FINAL_RESULT -->|Allow| SEL_ALLOW
        SEL_FINAL_RESULT -->|Deny| SEL_DENY
    end
    
    %% Combined Final Decision
    subgraph "FINAL_LOGIC [Final Access Decision]"
        GATE_LOGIC{All Systems Must Allow}
        
        FINAL_GRANT[🟢 ACCESS GRANTED]
        FINAL_BLOCK[🔴 ACCESS DENIED]
    end
    
    %% Connect outputs to final decision
    DAC_ALLOW --> GATE_LOGIC
    MAC_ALLOW --> GATE_LOGIC
    SEL_ALLOW --> GATE_LOGIC
    
    DAC_DENY --> FINAL_BLOCK
    MAC_DENY --> FINAL_BLOCK
    SEL_DENY --> FINAL_BLOCK
    
    GATE_LOGIC -->|All Allow| FINAL_GRANT
    GATE_LOGIC -->|Any Deny| FINAL_BLOCK
    
    %% Styling
    classDef dacStyle fill:#e1f5fe,stroke:#0277bd,stroke-width:2px,color:#000
    classDef macStyle fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px,color:#000
    classDef selinuxStyle fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px,color:#000
    classDef allowStyle fill:#c8e6c9,stroke:#1b5e20,stroke-width:3px,color:#000
    classDef denyStyle fill:#ffcdd2,stroke:#c62828,stroke-width:3px,color:#000
    classDef decisionStyle fill:#fff3e0,stroke:#f57c00,stroke-width:2px,color:#000
    classDef processStyle fill:#f5f5f5,stroke:#616161,stroke-width:1px,color:#000
    
    %% Apply styles
    class DAC_CHECK,DAC_OWNER,DAC_GROUP,DAC_OWNER_PERM,DAC_GROUP_PERM,DAC_OTHER_PERM,DAC_RESULT dacStyle
    class MAC_CHECK,MAC_LABELS,MAC_CLEARANCE,MAC_CLASSIFICATION,MAC_RULES,MAC_BELL,MAC_BIBA,MAC_RESULT macStyle
    class SEL_CHECK,SEL_AVC,SEL_CACHED,SEL_SERVER,SEL_CONTEXT,SEL_RULES,SEL_TE,SEL_RBAC,SEL_MLS,SEL_DECISION,SEL_CACHE_ALLOW,SEL_CACHE_DENY,SEL_FINAL_RESULT selinuxStyle
    class DAC_ALLOW,MAC_ALLOW,SEL_ALLOW,FINAL_GRANT allowStyle
    class DAC_DENY,MAC_DENY,SEL_DENY,FINAL_BLOCK denyStyle
    class GATE_LOGIC decisionStyle
    class REQUEST processStyle
```

## 6. Security Comparison Matrix

```mermaid
graph LR
    subgraph "Security Aspects Comparison"
        subgraph "Flexibility"
            DAC_FLEX[DAC: High<br/>Users control permissions]
            MAC_FLEX[MAC: Low<br/>System controlled]
            SEL_FLEX[SELinux: Medium-High<br/>Policy configurable]
        end
        
        subgraph "Security Level"
            DAC_SEC[DAC: Basic<br/>Vulnerable to trojans]
            MAC_SEC[MAC: High<br/>Strong policy enforcement]
            SEL_SEC[SELinux: Very High<br/>Multi-layered protection]
        end
        
        subgraph "Complexity"
            DAC_COMP[DAC: Low<br/>Simple to understand]
            MAC_COMP[MAC: Medium-High<br/>Policy design complex]
            SEL_COMP[SELinux: High<br/>Steep learning curve]
        end
        
        subgraph "Performance Impact"
            DAC_PERF[DAC: Minimal<br/>Native OS feature]
            MAC_PERF[MAC: Low-Medium<br/>Label checking overhead]
            SEL_PERF[SELinux: Medium<br/>Context switching cost]
        end
        
        subgraph "Use Case Suitability"
            DAC_USE[DAC: General Computing<br/>Desktop, basic servers]
            MAC_USE[MAC: High Security<br/>Government, military]
            SEL_USE[SELinux: Hardened Systems<br/>Web servers, containers]
        end
        
        subgraph "Administration"
            DAC_ADMIN[DAC: User-managed<br/>Distributed control]
            MAC_ADMIN[MAC: Centralized<br/>Policy administrators]
            SEL_ADMIN[SELinux: Policy-based<br/>Specialized knowledge]
        end
    end
    
    classDef dacStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000
    classDef macStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000
    classDef selinuxStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px,color:#000
    
    class DAC_FLEX,DAC_SEC,DAC_COMP,DAC_PERF,DAC_USE,DAC_ADMIN dacStyle
    class MAC_FLEX,MAC_SEC,MAC_COMP,MAC_PERF,MAC_USE,MAC_ADMIN macStyle
    class SEL_FLEX,SEL_SEC,SEL_COMP,SEL_PERF,SEL_USE,SEL_ADMIN selinuxStyle
```

## Usage Instructions

To view these diagrams:

1. **Copy the Mermaid code** from any section above
2. **Paste into a Mermaid renderer** such as:
   - [Mermaid Live Editor](https://mermaid.live)
   - GitHub (supports Mermaid in markdown)
   - VS Code with Mermaid extensions
   - Documentation platforms like GitLab, Notion, etc.

3. **Diagram Descriptions:**
   - **Diagram 1**: Complete overview of all three access control mechanisms
   - **Diagram 2**: Detailed DAC decision flow and vulnerabilities
   - **Diagram 3**: MAC security models with Bell-LaPadula and Biba
   - **Diagram 4**: SELinux architecture and components
   - **Diagram 5**: Comparative access decision flows
   - **Diagram 6**: Security aspects comparison matrix

Each diagram uses color coding:
- **Blue**: DAC-related components
- **Purple**: MAC-related components  
- **Green**: SELinux-related components
- **Orange/Yellow**: Process flows and decisions
- **Red**: Denials and vulnerabilities
- **Light Green**: Access grants
