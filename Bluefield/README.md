# BlueField DPU for Prisma AIRS

A BlueField card typically has:

  • A high-speed NIC (Ethernet or InfiniBand)  
  • ARM cores (to run Linux and services)  
  • Hardware accelerators (crypto/IPsec/TLS, regex, flow processing, virt switching, etc.)    


***Prisma AIRS and NVIDIA BlueField Integration: Practical Implications***

The integration of Palo Alto Networks' Prisma AIRS (AI Runtime Security) with NVIDIA BlueField Data Processing Units (DPUs) offers significant practical benefits, particularly in enhancing security performance and efficiency for AI workloads and general network traffic in data centers and at the industrial edge. This synergy primarily leverages the Intelligent Traffic Offload (ITO) service to offload and accelerate security processing.

***

***Key Practical Implications and Benefits***

• **Enhanced Performance and Efficiency** 

    • The integration combines Palo Alto Networks VM-Series Virtual Next-Generation Firewalls (NGFWs) with NVIDIA BlueField-2 DPUs.
    
    • A core component is the Intelligent Traffic Offload (ITO) service, which inspects new traffic flows to determine if deep security inspection is required. If not, the traffic is offloaded to the DPU, freeing up the firewall's CPU.
    
    • This offloading can lead to a significant performance boost, with BlueField-2 providing up to a 5x performance improvement compared to running the VM-Series firewall solely on a CPU, resulting in improved efficiency and cost savings.

• **Optimized Security for AI Workloads** 

    • Prisma AIRS is a comprehensive AI security platform designed to secure the entire AI ecosystem, including applications, agents, models, and data. 
    Reference: https://prod.prmcdn.io/attachments/87565a98ac5a440991bfaf94fb63be7a/1/JSB-Nvidia-Strata-VM-Series-010422.pdf

    
    • It defends against both AI-specific threats (such as prompt injection and model manipulation) and traditional network attacks. 
    Reference: https://docs.paloaltonetworks.com/ai-runtime-security

    
    • By integrating with BlueField DPUs, the system can efficiently offload high-volume network traffic, allowing the VM-Series NGFW (which can incorporate Prisma AIRS capabilities) to focus its CPU resources on deep, AI-specific security inspections without compromising performance. This is crucial for securing AI applications, models, and data without decryption overhead. [2]  


• **Diverse Use Cases** 

    • Edge Processing: The integration enables secure processing of large data volumes with near real-time throughput in distributed edge networks, such as retail and manufacturing environments, without introducing latency. [1]  
    
    • Data Center Infrastructure Virtualization: It provides advanced threat inspection for high-throughput virtualized infrastructure, capable of achieving up to 100 Gbps throughput.


*** Practical example of how the integration works. Focus on traffic flows and inspection ***

While the provided information details the integration of Palo Alto Networks VM-Series Next-Generation Firewalls (NGFWs) with NVIDIA BlueField Data Processing Units (DPUs) through Intelligent Traffic Offload (ITO), a direct integration example focusing on traffic flows and inspection specifically for Prisma AIRS and NVIDIA BlueField was not found in the search results.

However, a practical example of how Palo Alto Networks leverages NVIDIA BlueField DPUs for enhanced traffic inspection and performance can be illustrated through the VM-Series NGFW and Intelligent Traffic Offload (ITO) solution.


*_*VM-Series NGFW and NVIDIA BlueField DPU Integration with Intelligent Traffic Offload (ITO)*_ *

This integration aims to improve the performance and throughput of the VM-Series firewall by offloading certain data-centric computing tasks to the NVIDIA BlueField-2 DPU.

• Components Involved:
    • Palo Alto Networks VM-Series Virtual NGFW: This is the virtual firewall responsible for deep packet inspection and applying security policies.
    
    • NVIDIA BlueField-2 DPU: A programmable processor designed to move data throughout the data center, offering hardware acceleration for data-centric computing. It offloads, accelerates, and isolates data to secure it, freeing up CPU cores for business applications.
    
    • Intelligent Traffic Offload (ITO) Service: A security subscription for the VM-Series firewall that, when configured with the NVIDIA BlueField-2 DPU, increases the firewall's capacity throughput.
    Reference: https://www.paloaltonetworks.com/resources/techbriefs/palo-alto-networks-ngfw-and-nvidia-solution-brief

• Traffic Flow and Inspection: [2]  Reference: https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-kvm/intelligent-traffic-offload

    1. Initial Packet Inspection: The ITO service routes the first few packets of a new traffic flow to the VM-Series firewall for inspection.
    
    2. Decision for Offload or Inspection: Based on this initial inspection and configured policies, the VM-Series firewall determines whether the remaining packets in the flow require further deep security inspection or if they can be offloaded.
    
        • This decision considers factors like whether the traffic can benefit from security inspection (e.g., encrypted traffic cannot be inspected by the firewall for content) or if it's explicitly allowed by policy to bypass deep inspection.
        
    3. Traffic Offload to DPU: If the traffic is deemed suitable for offload, the NVIDIA BlueField-2 DPU handles the subsequent packets of that flow. This offloading accelerates packet filtering and forwarding, significantly reducing the load on the VM-Series firewall's CPU. [2]






## Study links

https://doc.dpdk.org/guides-23.11/platform/mlx5.html
https://www.paloaltonetworks.com/blog/2026/01/support-nvidia-enterprise-ai-factory/?utm_source=linkedin&utm_medium=social&utm_campaign=na&utm_content=pa000730
https://www.paloaltonetworks.com/blog/2025/10/secure-ai-factory-palo-alto-networks-nvidia/
https://www.paloaltonetworks.com/blog/network-security/prisma-airs-on-nvidia-bluefield-secures-the-industrial-edge/
https://www.paloaltonetworks.com/blog/2025/10/secure-ai-factory-palo-alto-networks-nvidia/
https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-kvm/intelligent-traffic-offload

## internal
https://confluence-dc.paloaltonetworks.com/spaces/cloudengineering/pages/94899837/Bringup+SW+Firewall+on+DPU+Nvidia+BlueField
https://confluence-dc.paloaltonetworks.com/spaces/PAVMQA/pages/79334156/ITO+Host+Setup+with+Nvidia+BF+card
https://confluence-dc.paloaltonetworks.com/spaces/cloudengineering/pages/77479914/Intelligent+Traffic+Offload+-+Layer+3+-+Functional+Spec
https://confluence-dc.paloaltonetworks.com/spaces/1120/pages/87774930/FS+NAT+Offload+support+for+Intelligent+Traffic+Offload
https://confluence-dc.paloaltonetworks.com/spaces/cloudengineering/pages/77479914/Intelligent+Traffic+Offload+-+Layer+3+-+Functional+Spec
https://confluence-dc.paloaltonetworks.com/spaces/cloudengineering/pages/493555403/Containerized+HSF
https://confluence-dc.paloaltonetworks.com/spaces/cloudengineering/pages/186320064/IPSec+Offload+using+DPU+-+Functional+Specification








    

