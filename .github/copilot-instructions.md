## Copilot instructions for ONTAP Systems Switches documentation

### Repository overview
Product: ONTAP Systems Switches

Documentation for installing, configuring, and maintaining network switches used with NetApp ONTAP storage systems. Covers four switch categories: AFX systems switches, cluster switches, storage switches, and shared switches.

### Repository structure
- `get-started/` – Getting started overview with quick-start workflows for all switch types
- `afx/` – Landing page index for AFX systems switches
- `cluster/` – Landing page index for cluster switches
- `storage/` – Landing page index for storage switches
- `switch-bes-53248/` – Broadcom BES-53248 cluster switch: install, configure, upgrade, migrate, and replace procedures
- `switch-cisco-9336c-fx2/` – Cisco Nexus 9336C-FX2 and 9336C-FX2-T cluster switch procedures
- `switch-cisco-9336c-fx2-shared/` – Cisco Nexus 9336C-FX2 shared switch (combined cluster and storage) procedures
- `switch-cisco-9336c-fx2-storage/` – Cisco Nexus 9336C-FX2 storage switch procedures
- `switch-cisco-9332d-gx2b/` – Cisco Nexus 9332D-GX2B AFX systems switch: install in AFX system, configure, and maintain procedures
- `switch-cisco-9364d-gx2a/` – Cisco Nexus 9364D-GX2A AFX systems switch: install in AFX system, configure, and maintain procedures
- `switch-cisco-9808/` – Cisco Nexus 9808 AFX systems switch: install in AFX system, configure, and maintain procedures
- `switch-nvidia-sn2100/` – NVIDIA SN2100 cluster switch procedures
- `switch-nvidia-sn2100-storage/` – NVIDIA SN2100 storage switch procedures
- `switch-cshm/` – Ethernet Switch Health Monitor (CSHM) configuration and monitoring: log collection, SNMPv3, health monitoring
- `shared/` – Shared procedures reused across multiple switch models (migration, monitoring, software install)
- `_include/` – Reusable AsciiDoc content snippets included by multiple pages
- `redirect/` – Redirect pages for content that has moved to new URLs
- `other/` – Miscellaneous pages and linkout content
- `media/` – Images and diagrams used across the documentation

### Product-specific context

**Architecture and components:**
- *Cluster switches* (back-end): Connect ONTAP controller nodes to each other to form a multi-node cluster; supported models are Broadcom BES-53248, Cisco Nexus 9336C-FX2, and NVIDIA SN2100
- *Storage switches* (front-end): Route data between servers and storage arrays; supported models are Cisco Nexus 9336C-FX2 and NVIDIA SN2100
- *Shared switches*: Combine cluster and storage functionality in a single switch using shared RCFs; the Cisco Nexus 9336C-FX2 is the supported model
- *AFX systems switches*: High-port-density, energy-efficient Cisco Nexus switches (9808, 9332D-GX2B, 9364D-GX2A) used specifically in AFX 1K and AFX 2K system configurations
- Switches always deploy in pairs (cs1 and cs2) for redundancy; documentation examples consistently use these names

**Key concepts:**
- *RCF (Reference Configuration File)*: A NetApp-provided configuration file applied to a switch to define port assignments, VLANs, and network settings for a specific use case (cluster, storage, or shared); switches require a compatible RCF for their role
- *CSHM (Ethernet Switch Health Monitor)*: An ONTAP feature that monitors cluster and storage network switches, automatically collects switch logs via AutoSupport, raises alerts on detected faults, and supports SNMPv3 for secure communication
- *Log collection*: A CSHM capability that gathers periodic switch logs automatically (via AutoSupport) or on demand for troubleshooting
- *NX-OS*: The Cisco operating system running on all Cisco Nexus switches in this documentation; must be installed before the RCF
- *EFOS (Ethernet Fabric OS)*: The Broadcom operating system running on BES-53248 switches
- *Cumulus Linux*: The NVIDIA operating system running on SN2100 switches; can run in Cumulus mode or ONIE mode
- *FRU (Field Replaceable Unit)*: Hardware components on a switch (power supplies, fans, supervisor modules) that can be replaced in the field without returning the entire switch
- *Smart Call Home*: An optional Cisco feature that configures a switch to send automated email alerts to the Smart Call Home system for proactive support
- *DAT (Direct-Attach Storage)* and *SAT (Switch-Attach Storage)*: Storage attachment configurations relevant to shared switch migration procedures

**Naming conventions and terminology:**
- Switch model directory names follow the pattern `switch-[vendor]-[model]/` (for example, `switch-cisco-9336c-fx2/`)
- File names follow the pattern `[action]-[description]-[switch-model].adoc` (for example, `install-rcf-software-9336c-cluster.adoc`)
- The term *AFX systems switches* (not "AFX switches") refers to the high-density Cisco Nexus switches for AFX systems
- *Shared switch* refers specifically to a switch configured with shared cluster and storage RCFs—not a general term for any shared infrastructure
- CSHM is always spelled out as "Ethernet switch health monitor" on first use; the abbreviation CSHM is used thereafter
- Switch pairs are referred to as *cs1* and *cs2* in configuration examples

### Typical user workflows

**Install and configure a new cluster or storage switch:** Review configuration requirements → Install switch hardware → Complete initial switch setup → Install switch OS (NX-OS, EFOS, or Cumulus Linux) → Install RCF → Configure SSH → Configure CSHM log collection → Configure SNMPv3 (optional) → Configure Smart Call Home (optional)

**Install and configure an AFX systems switch:** Prepare for installation → Install switches with AFX system hardware → Complete initial switch setup → Review cabling and configuration requirements → Install NX-OS → Install RCF → Verify SSH → Configure CSHM → Configure Smart Call Home (optional)

**Migrate to a new switch model:** Review migration requirements → Prepare new switch with OS and RCF → Migrate cluster or storage traffic → Verify cluster health → Remove old switch

**Replace a faulty switch:** Obtain replacement switch → Install NX-OS/EFOS/Cumulus Linux on replacement → Install RCF → Restore configuration → Verify cluster health

**Maintain CSHM:** Configure log collection → Configure SNMPv3 → Monitor health alerts → Troubleshoot detected issues → Collect on-demand logs if needed
