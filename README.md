# Strata Playbook: AIRS (AI Runtime Security) - Playbook Hub

📌 **Reference:** [AIRS Playbook - Confluence Datacenter](https://confluence-dc.paloaltonetworks.com/pages/viewpage.action?pageId=295188409)

---

## 🔍 Troubleshooting AI Runtime Security (AIRS)

Follow these troubleshooting steps to diagnose and resolve issues with AI Runtime Security (AIRS).

---

## 🚀 Deployment & Terraform Playbook

If you encounter issues with **Terraform deployments**, refer to the **AIRS Terraform Support Playbook** for guidance.

---

## 🔑 License Verification

AIRS supports the following license types:

- **BYOL**
- **PayGo**
- **NEW AI-BYOL**
- **NEW AI-PayGo**

To verify the license type, use the following CLI command:

```
admin@PA-VM> request license info
```
Look for "Feature: AI-Runtime-Security"

## 🔄 Status & Policy Configuration in SCM

Ensure the following:

- ✅ The device appears in **SCM** as **AI Firewalls**  
- ✅ Device **status** is **Connected**  
- ✅ Configuration is **in sync**  
- ✅ **Security Profile** is created  
- ✅ **Profile Group** contains the Security Profile  
- ✅ **Security Policy** has the Profile Group selected  
- ✅ **Push notification** is successful  

---

## ☁️ Cloud Connectivity

Check cloud connectivity by verifying:

- **FileManager** is connected  
- **Cloud Connection** is established  
- **Certificate** is valid  
- **State** is set to **Ready**  

Run the following CLI command:

```
admin@PA-VM> show ctd-agent status security-client
```

## 📜 Logging

Logs should appear under:

- **AI Runtime Security** tab  
- **Firewall/AI Security** selection  

📌 **Note:** These logs **will not** appear in the **local WebUI (GUI Dashboard)**.

If logs are missing, check global counters:
```
admin@PA-VM> show counter global | match log
```
Check for these counters:

- `log_ai_sec_cnt` – AI security log count  
- `log_ai_sec_log` – AI security logs sent  

Also, verify log reception with the CLI command: 
``` 
admin@PA-VM> debug log-receiver statistics
```
(To check if mp received the ai sec logs correctly or not.)

## 📤 Forwarding Errors

If AI security logs are not forwarding correctly, verify:

- **Platform Type & License** – Only AI-NGFW supports AI SEC  
- **Security Policy** – Ensure AI Security Profile is configured and attached to a policy  
- **FileManager Connection & Counters** – Look for `fctrl not ready counter`  
- **WiFClient Connection**  
- **Content Updates** – Ensure they are current  
- **Session Traversal** – Confirm the AI security session is passing through the device  

Run the following command to check forwarding counters:
```
admin@PA-VM> show counter global filter delta yes
```
And check for the following counters:  

- **ctd_ai_wif_forward_count** → Total AI requests forwarded for WIF  
- **ctd_ai_wif_forward_count_http** → Total AI requests forwarded for WIF for HTTP  
- **ctd_ai_wif_forward_count_http2** → Total AI requests forwarded for WIF for HTTP2  
- **ctd_wif_ai_verdict_block** → WIF AI block verdict counter  
- **ctd_wif_ai_verdict_alert** → WIF AI alert verdict counter  
- **ctd_wif_ai_verdict_allow** → WIF AI allow verdict counter  
- **ctd_wif_ai_verdict** → WIF AI verdict counter  

---

## 🔍 Sessions and Verdicts

To confirm the status of a session and individual payloads, use the following CLI command:
```
admin@PA-VM> debug dataplane show ctd feature-forward forward-info session-id
```

📌 **Note:** Each session forwarded to **AIRS** may contain up to **four payload types**.  
- Each payload type will have a specific verdict.  
- The **most significant verdict** will apply to the **full session**.  
- Verify the log status as **benign** or **malicious**.  

### Key Counters:

- **ctd_ai_wif_forward_count** → Total AI SEC forwarding (one per payload type)  
- **ctd_ai_wif_forward_count_http** → Valid AI SEC forward count for HTTP  
- **ctd_ai_wif_forward_count_http2** → Valid AI SEC forward count for HTTP2  
- **ctd_wif_ai_verdict_allow** → Allow verdict received  
- **ctd_wif_ai_verdict_alert** → Alert verdict received  
- **ctd_wif_ai_verdict_block** → Block verdict received  
- **ctd_wif_ai_log_error** → Failed to generate AI log  
- **ctd_wif_ai_max_latency_timeout** → AI max latency timeout reached  
- **ctd_wif_ai_verdict_err_cfg_mismatch** → AI profile configuration mismatch  
- **ctd_wif_ai_verdict_err_others** → Other AI verdict errors  

---

## 🔄 Replaying PCAPs & Verdict Validation

This section is for **lab replications** using PCAPs for **verdict validation**.  
📌 **Note:** Ensure "force-mirror" mode is enabled in the AI Security Profile before replaying PCAP files.

To enable **force-mirror** mode, use:
```
admin@PA-VM> set profiles ai-security <ai-sec-profile-name> request-forwarding-mode force-mirror
admin@PA-VM> set profiles ai-security <ai-sec-profile-name> response-forwarding-mode force-mirror
```

After this, check the following counter, as below CLI command:
After tcpreplay, check the wif counters with the following CLI command:
```
	admin@PA-VM> show counter global | match wif
	ctd_ai_wif_forward_count                   2        0 info      ctd       pktproc   total ai requests forwarded for WIF
	ctd_ai_wif_forward_count_http              2        0 info      ctd       pktproc   total ai requests forwarded for WIF for http
	ctd_ai_wif_forward_count_http2              2        0 info      ctd       pktproc   total ai requests forwarded for WIF for http2
	ctd_wif_send                              39        2 info      ctd       pktproc   original packets sent to WIF
	ctd_wif_send_ctrl                          1        0 info      ctd       pktproc   ctrl packets sent to WIF
	ctd_wif_send_field                         1        0 info      ctd       pktproc   field packets sent to WIF
	ctd_wif_send_byte                      55324     2890 info      ctd       pktproc   original byte sent to WIF
	ctd_wif_recv                               2        0 info      ctd       pktproc   packet received from WIF
	ctd_wif_recv_byte                        602       31 info      ctd       pktproc   byte received from WIF
	ctd_wif_ai_verdict_block              1        0 info      ctd       pktproc   wif ai block verdict verdict counter
	ctd_wif_ai_verdict_alert              1        0 info      ctd       pktproc   wif ai alert verdict counter
	ctd_wif_ai_verdict_allow              1        0 info      ctd       pktproc   wif ai allow verdict counter
	ctd_wif_ai_verdit                          1.      0 info      ctd       pktproc wif ai verdict counter
```
Check the wif cache entry(debug). check the following CLI command and its output:
```
admin@PA-VM> "debug dataplane show ctd feature-forward forward-info session-id 15"
Forward entries:
	Forward ended  : YES
	Payload type   : 2
	Forward id     : 5
Flags:
wif_boundary   : False
c2s            : 1
synced         : 0
mirror         : 1
fctrl          : 0
hold           : 0
Packets info:
	Forwarded packets       : 2
	Received packets       : 1
Data info:
	Forwarded bytes       : 704
Service type   : ai_sec
	Verdict: benign
	Action: allow
	Threat number: 0
	number of verdict: 1, status: complete
Default enabled service type   : cs_ml_ss_c2
	Received CS_ML_SS C2 verdict: benign
Default enabled service type   : cs_hd_cs_c2
	Received CS_HD_CS C2 verdict: benign
Default enabled service type   : EMPIRE_PS
	Received Empire PS C2 verdict: benign

Forward ended  : YES
Payload type   : 8
Forward id     : 6
Flags:
	wif_boundary   : False
	c2s            : 1
	synced         : 0
	mirror         : 0
	fctrl          : 0
	hold           : 0
Packets info:
		Forwarded packets       : 1
		Received packets       : 2
Data info:
	Forwarded bytes       : 108
Service type   : ai_sec
		Verdict: benign
		Action: allow
		Threat number: 0
		number of verdict: 1, status: complete

Forward ended  : YES
Payload type   : 6
Forward id     : 7
Flags:
		wif_boundary   : False
		c2s            : 0
		synced         : 0
		mirror         : 1
		fctrl          : 0
		hold           : 0
Packets info:
		Forwarded packets       : 1
		Received packets       : 1
Data info:
		Forwarded bytes       : 647
Service type   : ai_sec
		Verdict: benign
		Action: allow
		Threat number: 0
		number of verdict: 1, status: complete

Forward ended  : YES
Payload type   : 7
Forward id     : 8
Flags:
		wif_boundary   : False
		c2s            : 0
		synced         : 0
		mirror         : 0
		fctrl          : 0
		hold           : 0
Packets info:
		Forwarded packets       : 1
		Received packets       : 3
Data info:
		Forwarded bytes       : 1294
Service type   : ai_sec
		Verdict: benign
		Action: allow
		Threat number: 0
		number of verdict: 1, status: complete
```
