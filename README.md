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
See below an example command below.
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
tdx@tdx-guest:~$cd tdx-amber-idc-preview/scripts
tdx@tdx-guest:~$./init.sh
```


### 1.6 Create TDVM
![](/doc/customer_create_guest_image.png)

- Create a TD guest image from official Ubuntu 22.04 image as follows:
```
tdx@tdx-guest:~$./create-guest-image.sh -o <image file name> -u <username> -p <password> -n <guest vm name>
```
Example
```
tdx@tdx-guest:~$./create-guest-image.sh -o tdx-guest.qcow2 -u tdx -p 123TdVMTest -n my-guest
```

- Start TDVM via libvirt
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

# To start a VM
tdx@tdx-guest:~$ virsh start my-guest

# To connect to the VM Console
tdx@tdx-guest:~$ virsh console my-guest
```
_NOTE: To exit a running VM pls use ^] (Ctrl + ]) 
_NOTE: please change `my-guest` to your guest's name._

_NOTE: Please check chapter 3.2 at the [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0 v0.10](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html)_

### 1.7 Check Trusted Execution Environment (TEE) environment

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
