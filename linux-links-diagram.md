# Linux Hard Links vs Symbolic Links

This diagram illustrates the fundamental differences between hard links and symbolic links in Linux filesystems.

```mermaid
graph TD
    subgraph "File System Structure"
        subgraph "Inode Table"
            I1[Inode 12345<br/>Data blocks: 1,2,3<br/>Link count: 3<br/>Permissions: 644<br/>Size: 1024 bytes]
            I2[Inode 67890<br/>Data blocks: 4,5<br/>Link count: 1<br/>Permissions: 755<br/>Size: 512 bytes]
        end
        
        subgraph "Data Blocks"
            D1[Block 1: "Hello"]
            D2[Block 2: "World"]
            D3[Block 3: "!"]
            D4[Block 4: "/home/user/"]
            D5[Block 5: "original.txt"]
        end
        
        subgraph "Directory Entries"
            DE1["/home/user/original.txt → Inode 12345"]
            DE2["/home/user/hardlink.txt → Inode 12345"]
            DE3["/backup/copy.txt → Inode 12345"]
            DE4["/home/user/symlink.txt → Inode 67890"]
        end
    end
    
    subgraph "User View"
        subgraph "Original File"
            OF[original.txt<br/>"Hello World!"]
        end
        
        subgraph "Hard Links"
            HL1[hardlink.txt<br/>"Hello World!"]
            HL2[copy.txt<br/>"Hello World!"]
        end
        
        subgraph "Symbolic Link"
            SL[symlink.txt<br/>→ original.txt]
        end
    end
    
    %% Connections for hard links
    DE1 --> I1
    DE2 --> I1
    DE3 --> I1
    I1 --> D1
    I1 --> D2
    I1 --> D3
    
    %% Connections for symbolic link
    DE4 --> I2
    I2 --> D4
    I2 --> D5
    
    %% Visual representation
    OF -.-> I1
    HL1 -.-> I1
    HL2 -.-> I1
    SL -.-> I2
    SL --> OF
    
    classDef inodeStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef dataStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef hardlinkStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef symlinkStyle fill:#fff3e0,stroke:#e65100,stroke-width:2px
    
    class I1,I2 inodeStyle
    class D1,D2,D3,D4,D5 dataStyle
    class OF,HL1,HL2 hardlinkStyle
    class SL symlinkStyle
```

## Key Differences

### Hard Links
- **Point directly to the inode** (same inode number)
- **Share the same data blocks** - all hard links access identical content
- **Link counter increases** with each hard link created
- **Cannot cross filesystem boundaries**
- **Cannot link to directories** (to prevent loops)
- **File persists until all hard links are deleted** (link count = 0)
- **Indistinguishable from original** - all are equal references

### Symbolic Links (Symlinks)
- **Have their own inode** with different inode number
- **Store the path to target file** as their data
- **Can cross filesystem boundaries**
- **Can link to directories and files**
- **Broken if target is deleted** (dangling symlink)
- **Can create chains** (symlink → symlink → file)
- **Easily identifiable** with `ls -l` (shows → target)

## Commands Demonstration

```bash
# Create original file
echo "Hello World!" > original.txt

# Create hard link
ln original.txt hardlink.txt

# Create symbolic link
ln -s original.txt symlink.txt

# Check inode numbers
ls -li original.txt hardlink.txt symlink.txt

# Results:
# 12345 -rw-r--r--  2 user group 13 date original.txt
# 12345 -rw-r--r--  2 user group 13 date hardlink.txt  (same inode!)
# 67890 lrwxrwxrwx  1 user group 12 date symlink.txt -> original.txt
```

## Practical Use Cases

### Hard Links
- **Backup systems** - efficient storage without duplication
- **Package management** - multiple package versions sharing files
- **Deduplication** - save space when identical files exist

### Symbolic Links
- **Configuration management** - point to different config versions
- **Cross-filesystem references** - link files across partitions
- **Directory shortcuts** - create convenient access paths
- **Version management** - current → version-specific directories
