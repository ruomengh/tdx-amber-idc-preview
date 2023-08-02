# Intel Developer Cloud (IDC) TDX Amber Preview

## 1. Customer On-Board Workflow
![](/doc/overall_customer_on_board.png)


### 1.1 Fill out Request Form
<https://www.intel.com/content/www/us/en/forms/developer/tdx/request-instance-one-cloud.html>

### 1.2 Receive Email for Intel Login

You will receive an email, with the information of `Intel SDP Login`, 

In the first email,
- You will get the link of "SSH Public Key". Please click it to upload your local SSH public key for next step SSH login.
You can find your local key at

    - Windows: `c:\users\<your windows user name>\.ssh\id_rsa.pub`
    - Linux: `~/.ssh/id_rsa.pub`

    ![](/doc/customer-on-board-email.png)

- You will also get the login command as below:

    ```
    ssh -J guest@146.152.205.59 -L 10022:192.168.13.2:22 sdp@192.168.13.2
    ```

### 1.3 Receive Email for Intel Amber info
Email is for Amber's URL, API Key, and the URL of this github repository.


### 1.4 Login to TDX enabled dedicated instance

To access the target server in Intel Dev Cloud, you need use SSH to pass-through a jump server like below picture:

![](/doc/devcloud-ssh-login.png)

If prefer to use simple command line, please get from on-board email in section 1.2.
If prefer to use SSH config for a proxy configurations, example is shown in below:

![](/doc/devcloud-ssh-login-proxy.png)

```
Host jumperserver
    HostName <jumper server address>
    User guest
    ProxyCommand ncat --proxy <your proxy host>:<your proxy port> %h %p

Host sdp
    HostName <target server address>
    User sdp
    ProxyJump jumperserver
    LocalForward 10022 <target server address>:22
    LocalForward 10443 <target server address>:443
```
_NOTE:_ Please provides:
- `<your proxy host>:<your proxy port>` according to your network
- `<jumper server address>` from the on-board email
- `<target server address>` from the on-board email
- Please config `ProxyCommand` if you are using windows OS

_NOTE: Please get more details from [Intel SDP SSH Config](/doc/intel_sdp_ssh_login.md)._


For the first time, please clone the github project and run initialization scripts:

```
git clone https://github.com/IntelConfidentialComputing/tdx-amber-idc-preview
cd ./scripts
./init.sh
```


### 1.5 Create TDVM

- Create a TD guest image from official Ubuntu 22.04 image as follows:

![](/doc/customer_create_guest_image.png)

```
./create-guest-image.sh -o [image name] -p [password]

Example:
./create-guest-image.sh -o _tdx-guest.qcow2_ -p 123TdVMTest
```

If want to customize the guest vm name, user name: (optional)
```
./create-guest-image.sh -o tdx-guest.qcow2 -u tdx -p 123TdVMTest -n my-guest
```


- Create TDVM via libvirt

```
./start-virt.sh -i tdx-guest.qcow2 -n my-guest
```

- After creation, please use virsh to manage the TDVM

```
# Examples of commands to manage VMs (optional)
# list all VMs created by current Linux account 
virsh list --all

# Suspend a VM
virsh suspend my-guest

# Resume a VM
virsh resume my-guest

# Shutdown a VM
tdx@tdx-guest:~$ virsh shutdown my-guest

```

_NOTE: please change `my-guest` to your guest's name._

_NOTE: Please check chapter 3.2 at the [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0 v0.10](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html)_


### 1.6 Login TD guest

1. Login in via SSH command line

```
tdx@tdx-guest:~$ virsh console my-guest
```
 
2. Use virt-manager GUI application running on your laptop to manage all VMs from remote server.

![](/doc/customer_manage_tdvm.png)

_NOTE: You can only manage the VMs created by your Linux account._

### 1.7 Check TEE environment

1. Check TD Report
TODO: explain what is tdx report is (one line)

To read about td report please refer to section 4.2 in the following [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0 v0.10](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html)_
```
to generate the td report run the following command
tdx@tdx-guest:~$ tdx_tdreport
```


### 1.8 Use Amber client to generate Quote


```
tdx@tdx-guest:~$ sudo amber-cli quote
[4 0 2 0 129 0 0 0 0 0 0 0 147 154 114 51 247 156 76 169 148 10 13 179 149 127 6 7 27 121 246 32 9 47 180 161 197 185 188 207 5 61 32 16 0 0 0 0 4 0 5 0 0 0 0 0 0 0 0 0 0 0 0 0 72 250 105 148 157 176 128 2 238 132 37 40 71 245 114 152 139 29 110 86 142 193 53 63 100 203 108 15 217 5 55 95 105 173 149 156 14 175 119 71 172 112 163 146 120 147 2 161 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 80 0 0 0 128 231 2 6 0 0 0 0 0 112 235 16 109 171 65 204 108 192 166 184 207 237 25 183 40 28 116 92 90 162 208 111 139 251 85 92 217 212 184 149 166 102 161 163 199 47 236 158 154 185 146 113 117 2 251 90 140 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 53 29 158 211 102 1 128 102 103 216 146 7 171 158 184 27 240 178 90 207 32 97 181 69 241 98 19 76 55 217 196 107 212 85 81 177 18 223 92 185 4 81 116 19 159 135 114 106 59 9 237 238 149 240 61 77 185 202 112 246 204 18 221 56 178 201 133 153 120 143 245 101 193 182 161 146 15 155 251 121 113 175 103 209 193 122 75 186 213 39 188 241 131 249 228 101 80 46 128 225 196 63 224 230 13 65 45 167 154 160 207 233 171 127 63 250 184 134 148 68 37 218 246 176 148 57 197 108 173 229 186 151 46 199 57 108 113 230 201 175 77 130 161 105 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 207 131 225 53 126 239 184 189 241 84 40 80 214 109 128 7 214 32 228 5 11 87 21 220 131 244 169 33 211 108 233 206 71 208 209 60 93 133 242 176 255 131 24 210 135 126 236 47 99 185 49 189 71 65 122 129 165 56 50 122 249 39 218 62 204 16 0 0 187 28 133 119 143 215 173 44 211 62 19 53 238 75 35 219 201 157 239 64 219 187 154 55 7 200 250 124 110 144 82 108 185 124 210 236 178 241 35 109 81 73 166 37 130 117 201 254 112 227 60 147 253 35 245 66 205 187 14 240 118 12 38 83 153 122 146 188 247 179 234 115 247 86 36 213 136 55 168 154 204 182 95 141 63 253 204 80 160
...
```


### 1.9 User Amber client + API key for Attestation

```
tdx@tdx-guest:~$ export AMBER_URL=<AMBER URL String>
tdx@tdx-guest:~$ export AMBER_API_KEY=<AMBER API Key>
tdx@tdx-guest:~$ amber-cli create-key-pair -k key.pem
tdx@tdx-guest:~$ amber-cli token
```

## 2. Run workload without attestation in TDVM

There is no any different to run workload in TDVM with the non-confidential VM, like:

```
tdx@tdx-guest:~$ docker run nginx
```
TODO: how to verify nginx is working
## 3. Further Reading

- [Intel TDX Whitepaper](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-trust-domain-extensions.html)
- [Amber Introduction](https://projectamber.intel.com/)
- [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html) or [here](/doc/White%20Paper%20-%20Linux%20Stack%20for%20Intel®%20TDX-v0.10.pdf)
