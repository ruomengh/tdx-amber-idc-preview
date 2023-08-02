# Intel Developer Cloud (IDC) TDX Amber Preview

## 1. Customer On-Board Workflow
![](/doc/overall_customer_on_board.png)


### 1.1 Fill out Request Form
Click on the link below and submit a request to reserve an Intel® TDX-enabled system.
<https://www.intel.com/content/www/us/en/forms/developer/tdx/request-instance-one-cloud.html>

### 1.2 Remote access 

If the request is approved you will receive an email with subject "DevCloud - Instructions for remote access".
This email will have all the details on how to access the TDX-enabled system remotely.

- Click on the "SSH Public Key" link and copy the content of your SSH public key into the box and submit.
Typically the SSH keys are located the following location

    - Windows: `c:\users\<your windows user name>\.ssh\id_rsa.pub`
    - Linux: `~/.ssh/id_rsa.pub`

    ![](/doc/customer-on-board-email.png)

### 1.3 Login to TDX-enabled dedicated instance

The following diagram shows how Intel DevCloud is set up to enable you to establish an SSH connection to your TDX-enabled system through a jump server.

![](/doc/devcloud-ssh-login.png)

#### No Proxy:
If you are NOT behind corporate proxy, copy and paste the command provided in the email to connect to your assigned TDX-enabled system.
Pls use the command provided in the email to connect to your assigned TDX-enabled system. Example command is shown below.
```
ssh -J guest@146.152.205.59 -L 10022:192.168.14.2:22 sdp@192.168.14.2
```
_NOTE_: the default password is $harktank2Go
![](/doc/devcloud-ssh-login-proxy.png)

#### Behind Proxy:
If you are behind corporate Proxy, add the following lines into .ssh/config with your corporate PROXYSERVER and PROXYPORT, then run the above command.
#For Linux Operating System:
```
Host 146.152.*.*
ProxyCommand /usr/bin/nc -x PROXYSERVER:PROXYPORT %h %p
```
#For Non-Linux Operating System: (Install gitforwindows.org)
```
Host 146.152.*.*
ProxyCommand "C:\Program Files\Git\mingw64\bin\connect.exe" -S PROXYSERVER:PROXYPORT %h %p
```
_NOTE: For more details on how to configure ssh please refer the email or [Intel SDP SSH Config](/doc/intel_sdp_ssh_login.md)._

### 1.4 Intel Project Amber info
You will also receive another email with subject "Intel® Trust Domain Extensions and Project Amber in Intel® DevCloud". The email will contain the Amber API key and Amber URL that you will need for attestation. 

### 1.5 Initial setup

Once logged into the TDX-enabled system, clone the GitHub project and execute the initialization scripts.

```
tdx@tdx-guest:~$git clone https://github.com/IntelConfidentialComputing/tdx-amber-idc-preview
tdx@tdx-guest:~$cd ./scripts
tdx@tdx-guest:~$./init.sh
```


### 1.6 Create TDVM
![](/doc/customer_create_guest_image.png)

- Create a TD guest image from official Ubuntu 22.04 image as follows:
```
tdx@tdx-guest:~$./create-guest-image.sh -o <image name> -p <password>
``` 
Example:
```
tdx@tdx-guest:~$./create-guest-image.sh -o _tdx-guest.qcow2_ -p 123TdVMTest
```

If want to customize the guest vm name, user name: (optional)
```
tdx@tdx-guest:~$./create-guest-image.sh -o <image file name> -u <username> -p <password> -n <guest vm name>
```
Example
```
tdx@tdx-guest:~$./create-guest-image.sh -o tdx-guest.qcow2 -u tdx -p 123TdVMTest -n my-guest
```

- Create TDVM via libvirt
After creating the guest image, use the following command to create a TDVM
```
tdx@tdx-guest:~$./start-virt.sh -i <image file name> -n <guest vm name>
```
Example
```
tdx@tdx-guest:~$./start-virt.sh -i tdx-guest.qcow2 -n my-guest
```

- You can manage the TDVM using vrish toll with the commands below (optional)
```
# Examples of commands to manage VMs

# list all VMs created by current Linux account 
tdx@tdx-guest:~$virsh list --all

# Suspend a VM
tdx@tdx-guest:~$virsh suspend my-guest

# Resume a VM
tdx@tdx-guest:~$virsh resume my-guest

# Shutdown a VM
tdx@tdx-guest:~$ virsh shutdown my-guest

```

_NOTE: please change `my-guest` to your guest's name._

_NOTE: Please check chapter 3.2 at the [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0 v0.10](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html)_


### 1.7 Login TD guest
1. Login in via SSH command line

```
tdx@tdx-guest:~$ virsh console <guest vm name>
```
Example
```
tdx@tdx-guest:~$ virsh console my-guest
```
 
2. Use virt-manager GUI application running on your laptop to manage all VMs from remote server.

![](/doc/customer_manage_tdvm.png)

_NOTE: You can only manage the VMs created by your Linux account._

### 1.8 Check TEE environment

1. Check TD Report  
TODO: explain what is tdx report is (one line)

```
to generate the td report run the following command
tdx@tdx-guest:~$ tdx_tdreport
```
For more details on TD report please refer to section 4.2 in the [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0 v0.10](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html)_


### 1.9 Use Amber client to generate quote


```
tdx@tdx-guest:~$ sudo amber-cli quote
[4 0 2 0 129 0 0 0 0 0 0 0 147 154 114 51 247 156 76 169 148 10 13 179 149 127 6 7 27 121 246 32 9 47 180 161 197 185 188 207 5 61 32 16 0 0 0 0 4 0 5 0 0 0 0 0 0 0 0 0 0 0 0 0 72 250 105 148 157 176 128 2 238 132 37 40 71 245 114 152 139 29 110 86 142 193 53 63 100 203 108 15 217 5 55 95 105 173 149 156 14 175 119 71 172 112 163 146 120 147 2 161 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 80 0 0 0 128 231 2 6 0 0 0 0 0 112 235 16 109 171 65 204 108 192 166 184 207 237 25 183 40 28 116 92 90 162 208 111 139 251 85 92 217 212 184 149 166 102 161 163 199 47 236 158 154 185 146 113 117 2 251 90 140 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 53 29 158 211 102 1 128 102 103 216 146 7 171 158 184 27 240 178 90 207 32 97 181 69 241 98 19 76 55 217 196 107 212 85 81 177 18 223 92 185 4 81 116 19 159 135 114 106 59 9 237 238 149 240 61 77 185 202 112 246 204 18 221 56 178 201 133 153 120 143 245 101 193 182 161 146 15 155 251 121 113 175 103 209 193 122 75 186 213 39 188 241 131 249 228 101 80 46 128 225 196 63 224 230 13 65 45 167 154 160 207 233 171 127 63 250 184 134 148 68 37 218 246 176 148 57 197 108 173 229 186 151 46 199 57 108 113 230 201 175 77 130 161 105 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 207 131 225 53 126 239 184 189 241 84 40 80 214 109 128 7 214 32 228 5 11 87 21 220 131 244 169 33 211 108 233 206 71 208 209 60 93 133 242 176 255 131 24 210 135 126 236 47 99 185 49 189 71 65 122 129 165 56 50 122 249 39 218 62 204 16 0 0 187 28 133 119 143 215 173 44 211 62 19 53 238 75 35 219 201 157 239 64 219 187 154 55 7 200 250 124 110 144 82 108 185 124 210 236 178 241 35 109 81 73 166 37 130 117 201 254 112 227 60 147 253 35 245 66 205 187 14 240 118 12 38 83 153 122 146 188 247 179 234 115 247 86 36 213 136 55 168 154 204 182 95 141 63 253 204 80 160
...
```


### 1.10 Attestation
Execute the follwing commands to perform the attestation.
```
tdx@tdx-guest:~$ export AMBER_URL=<AMBER URL String>
tdx@tdx-guest:~$ export AMBER_API_KEY=<AMBER API Key>
tdx@tdx-guest:~$ amber-cli create-key-pair -k key.pem
tdx@tdx-guest:~$ sudo -E amber-cli token
```
_Note: Make cure there are no white space before or after the API key_

## 2. Run workload without attestation in TDVM
Running workloads in a TDVM is exactly the same as your would run the workload in a non-confidential VM. For example
```
tdx@tdx-guest:~$ docker run nginx
```
TODO: use a curl command to demonstrate that the nignx server is up and running?

## 3. Further Reading

- [Intel TDX Whitepaper](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-trust-domain-extensions.html)
- [Amber Introduction](https://projectamber.intel.com/)
- [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html) or [here](/doc/White%20Paper%20-%20Linux%20Stack%20for%20Intel®%20TDX-v0.10.pdf)
