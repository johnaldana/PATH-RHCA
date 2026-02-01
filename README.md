# PATH RHCA

**Hands-on roadmap for Red Hat certificacions**
Focused on building real system administration skills through practical projects and detailed technical documentation.

This repositorio is organized as a set of certification paths, each one aligned with a specific Red Hat Certification and is built around **real-world operational scenarios** rather than purely theoretical content.

The objective goes beyond certification preparation. 
This path is designed to build **real operational competence** to support **mission-critical workloads** such as SAP, Temenos, EPIC, and SCADA systems, as well as other high-availability enterprise environments running on Red Hat Enterprise Linux

These systems operate in environments where downtime, misconfiguration, or weak security controls introduce **significant business risk — often in the millions**.

**A company cannot afford to fly an airplane with a single engine**.  

## Certification Routes

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

path-rhcsa/
├── README.md
├── 01-users-and-access/
│   ├── guide.md
│   ├── tasks.md
│   ├── project.md
│   └── evidences.md  
│  
├── 02-storage-and-filesystems/
│   ├── guide.md
│   ├── tasks.md
│   ├── project.md
│   └── evidences.md  
│   
├── ...
├── 10-automation-and-maintenance/
└── 99-macro-project/
    ├── description.md
    ├── architecture.md
    └── troubleshooting.md

## Section File Breakdown

Each section contains the following files:

**guide.md**
- Short operational overview of the topic
- Key commands and workflows
- Common mistakes and failure scenarios

**tasks.md**
- RHCSA-style practical questions
- Real-world inspired scenarios

**project.md**
Includes:
- Project objective
- Technical requirements
- Constraints
- Expected result
  
## Macro Project

Each certification path ends with a **final macro project** that integrates multiple topics into a single enterprise-like Linux environment.

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

## Current Progress (Febrery 2026)

| Path              | Status       |
|-------------------|--------------|
| RHCSA             | In progress  |
| RHCE              | Planned      |
| HA                | Planned      | 
| Security          | Planned      |
| Others            | Planned      |

  

## Tooling Note

AI tools were used as a support resource for documentation structure and learning guidance. All technical work was performed and verified manually.