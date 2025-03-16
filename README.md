REFERENCE: https://confluence-dc.paloaltonetworks.com/pages/viewpage.action?pageId=295188409
# Strata Playbook: AIRS (AI Runtime Security) - Playbook Hub - Confluence Datacenter

## Troubleshooting

For troubleshooting AI Runtime Security, check the following scenarios:
### Deployment & Terraform Playbook: 
For issues with Terraform deployments, check the AIRS (AI Runtime Security) Terraform Support playbook. 
### Licenses: 
Supported license types: BYOL, PayGo, NEW AI-BYOL, NEW AI-PayGo. Verify License type with the CLI command: 
``` 
	admin@PA-VM> request license info
``` 
Look for "Feature: AI-Runtime-Security"
### Status and Policy configuration in SCM: 
Confirm the device is shown in SCM as type "AI Firewalls" and device status is connected and config is "in sync". Verify Security Profile is created. Confirm Profile is used in Profile Group. Verify Security Policy has Profile Group Selected. Successful push notification.
### Cloud Connectivity: 
Is filemanager connected? Confirm cloud is connected, confirm if certificate is valid and State is ready. For these, check CLI command: 
``` 
	admin@PA-VM> show ctd-agent status security-client
```
### Logging: 
Logs should appear in the "AI runtime security" tab. AI Security log type is only visible under the correct selection "Firewall/AI Security". These logs will not be present on the local webui (GUI Dashboard). If no logs are seen, check below counters with this CLI command: 
``` 
	admin@PA-VM> show counter global | match log
```
(To check if dp sent the ai sec logs.). counter are log_ai_sec_cnt and log_ai_sec_log. 
Also the CLI command: 
``` 
	admin@PA-VM> debug log-receiver statistics
```
(To check if mp received the ai sec logs correctly or not.)
### Forwarding Errors: 
Confirm platform type & License(Only licensed AI-NGFW support AI SEC); Verify Policy(Has Ai Security Profile been configured?; Is it attached to security policy matching traffic?); Check filemgr connection and counters(fctrl not ready counter); Is Wifclient connected?; Is content up to date? Is the session for the AI traffic traversing the device in question? We can check the status of the wif counters with the CLI command: 
``` 
	admin@PA-VM> show counter global filter delta yes
```
and check for the following counters: ctd_ai_wif_forward_count(total ai requests forwarded for WIF), *ctd_ai_wif_forward_count_http*(total ai requests forwarded for WIF for http), *ctd_ai_wif_forward_count_http2*(total ai requests forwarded for WIF for http2), *ctd_wif_ai_verdict_block*(wif ai block verdict verdict counter), *ctd_wif_ai_verdict_alert*(wif ai alert verdict counter), *ctd_wif_ai_verdict_allow*(wif ai allow verdict counter), *ctd_wif_ai_verdict*(wif ai verdict counter).
### Sessions and verdicts: 
Confirming status of a session and individual payloads with the following CLI command: 
``` admin@PA-VM> debug dataplane show ctd feature-forward forward-info session-id``` 
Note: Each session forward to AIRS may contain up to 4 payload types. Each will contain a specific verdict most significant verdict will apply to the full session. Verify status of log as benign or malicious. Check the following counters referent to the Payload type decoder: *ctd_ai_wif_forward_count*: Total AI SEC forwarding (Note: each payload-type has one forward), *ctd_ai_wif_forward_count_http*: Valid AI SEC forward Count for http, *ctd_ai_wif_forward_count_http2*: Valid AI SEC forward Count for http2, *ctd_wif_ai_verdict_allow*: allow verdict received, *ctd_wif_ai_verdict_alert*: alert verdict received, *ctd_wif_ai_verdict_block*: block verdict received, *ctd_wif_ai_log_error*: Fail to generate ai log, *ctd_wif_ai_max_latency_timeout*: reach ai max latency timeout, *ctd_wif_ai_verdict_err_cfg_mismatch*: ai profile configuration mismach, *ctd_wif_ai_verdict_err_others*: ai verdict errors 
### Replaying PCAPs and Verdict validation: 
This is for lab replications with the PCAPs and Verdict validation. Note: please turn on "force-mirror" for the ai-security profile to play the pcap files. Set the CLI commands: 
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
