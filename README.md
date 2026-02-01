# PATH RHCA

**_Hands-on roadmap for Red Hat certifications_**
Focused on building real system administration skills through practical projects and detailed technical documentation.

This repository is organized as a set of certification paths, each one aligned with a specific Red Hat certification and is built around **_real-world operational scenarios_** rather than purely theoretical content.

This path is designed to build **_real operational competence_** to support
**_mission-critical Linux platforms_** used by enterprise workloads such as
SAP environments running on Red Hat Enterprise Linux.

These systems operate in environments where downtime, misconfiguration, or weak security controls introduce **_significant business risk with potentially severe financial impact_**.

### **_A company cannot afford to fly an airplane with a single engine_**.  

## Certification Paths

This repository includes the following Red Hat–aligned learning routes:

- **RHCSA** – Red Hat Certified System Administrator
- **RHCE** – Red Hat Certified Engineer
- **HA** – High Availability
- **TUNING** – Performance Tuning
- **SATELLITE** – Red Hat Satellite
- **TROUBLESHOOTING** – Advanced Linux Troubleshooting
- **SECURITY** – Red Hat Security specialization
  
## Repository Structure

Each certification path is organized as a sequence of hands-on sections.
Every section covers a core system administration topic and follows the same consistent internal structure.

## Example structure (RHCSA):

```
path-rhcsa/
├── README.md
├── 01-essential-tools/
│   ├── guide.md
│   ├── tasks.md
│   ├── project.md
│   └── evidence.md  
│  
├── 02-users-and-access/
│   ├── guide.md
│   ├── tasks.md
│   ├── project.md
│   └── evidence.md  
│   
├── ...
├── 10-security-and-selinux/
└── 99-macro-project/
    ├── description.md
    ├── architecture.md
    └── troubleshooting.md
```

## Section File Breakdown

Each section contains the following files:

**guide.md**
- Short operational overview of the topic
- Key commands and workflows
- Common mistakes and failure scenarios

**tasks.md**
- RHCSA-style practical questions
- Real-world scenarios

**project.md**
Includes:
- Project objective
- Technical requirements
- Constraints
- Expected result
  
## Macro Project

Each certification path ends with a **_final macro project_** that integrates multiple topics into a single enterprise-like Linux environment.

The macro project focuses on:
- System integration
- Operational consistency
- Incident simulation and recovery
- Real-world troubleshooting

## How to Use This Repository

- Follow each path sequentially
- Complete the mini-project for every section
- Document actions and results
- Use the macro project as a capstone

## Current Progress (February 2026)

| Path              | Status       |
|-------------------|--------------|
| RHCSA             | In progress  |
| RHCE              | Planned      |
| HA                | Planned      | 
| Security          | Planned      |
| Others            | Planned      |

  

## Tooling Note

AI tools were used as a support resource for documentation structure and learning guidance. All technical work was performed and verified manually.