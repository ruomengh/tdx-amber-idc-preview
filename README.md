# Intel® Developer Cloud (IDC) TDX & Amber Preview

## 1. Customer On-Board Intel® Developer Cloud (Beta)

### 1.1 Registration

1. [Sign up](https://www.intel.com/content/www/us/en/forms/developer/standard-registration.html?tgt=https://www.intel.com/content/www/us/en/secure/developer/devcloud/cloud-launchpad.html) for an Intel® Unified Login account with your corporate email address (if not already signed up).
2. [Signin](https://scheduler.cloud.intel.com/) at the Intel® Developer Cloud Beta.


### 1.2 Setup - SSH Keys

Setting up SSH Keys is an one time task.

**WARNING**: Never share your private keys with anyone. Never create a SSH Private key without a passphrase.

1. Launch a Terminal/Command Prompt on your local system.
2. Copy & Paste the following to your terminal/command prompt to generate SSH Keys.

   - Linux*/macOS*:
   ```
   ssh-keygen -t ed25519 -f ~/.ssh/id_rsa
   ```
   - Windows*:
   ```
   mkdir %USERPROFILE%\.ssh
   ssh-keygen -t ed25519 -f %USERPROFILE%\.ssh\id_rsa
   ```

3. If you are prompted to overwrite, select no to use the existing keys
4. Copy & Paste the following to your terminal/command prompt to open your public key.

   - Linux*/macOS*:
   ```
   vi ~/.ssh/id_rsa.pub
   ```
   - Windows*:
   ```
   notepad %USERPROFILE%\.ssh\id_rsa.pub
   ```

    _Note: The public key must be in your Intel® Developer Cloud profile before starting an instance. The instance will need to be relaunched if the public key was updated after a virtual machine is launched._

5. Copy the entire content of the file id_rsa.pub
6. Click Profile Icon from the top blue navigation bar and click Profile. You must login to [Intel® Developer Cloud Management Console](https://scheduler.cloud.intel.com/) to see Profile Icon.
![](./doc/bar.png)

7. Paste the copied content in the text box **SSH RSA 4096 Public Key** and Click **Save Key**

    **Note**: If your key is not in default path/name, you must add IdentityFile parameter in SSH config file.

### 1.3 Request Access to TDX Bare Metal Instance  
Once the SSH keys are created and the public key uploaded, proceed to request access to the TDX System. 
TDX Systems are available upon request only so follow the instructions below to request one.
1. Go to [https://cloud.intel.com](https://cloud.intel.com) and Sign In (if not already)
2. Click Instances from top blue navigation bar
3. Click on check box for "Beta - Intel® Trust Domain Extensions (Intel® TDX) with 4th Generation Intel® Xeon® Scalable processors"
4. Click on the "Launch Instance" blue button at the bottom of the list
5. Review the details and Click 'Request Instance'
6. Complete the "Request Instance" form and click the "Request Instance" button at the bottom right to submit.
7. If your request is approved, Intel® Developer Cloud Customer Response Team will respond within 2-3 business days.

    <img src="https://github.com/IntelConfidentialComputing/tdx-amber-idc-preview/assets/38536938/e102acf3-bb25-42a1-a178-23d5658008e9"  width="900" height="700">

### 1.4 Reserve & Launch the TDX system
After receiving the approval email follow these below steps to launch the TDX System.
1. Go to [https://cloud.intel.com](https://cloud.intel.com) and Sign In (if not already)
2. Click Instances from top blue navigation bar
3. Click on check box for "Beta - Intel® Trust Domain Extensions (Intel® TDX) with 4th Generation Intel® Xeon® Scalable processors"
4. Click on the "Launch Instance" blue button at the bottom of the list
5. Review the agreement, and if you agree, select the "I agree" checkbox, then click "Launch Instance"
   <img src="https://github.com/IntelConfidentialComputing/tdx-amber-idc-preview/assets/38536938/5da82675-f7d9-4b8c-aa56-1ba3f62baf81"  width="900" height="400">

7. Please wait (2 minutes) for the instance to be provisioned and launched. 
8. On successful launch, you will be redirected to "View Instances" tab as shown below.
   <img src="https://github.com/IntelConfidentialComputing/tdx-amber-idc-preview/assets/38536938/d5e7f3ec-dd73-4565-bb13-bde470dcffa6"  width="1000" height="400">

   **Note**: Only your current public key will be authorized to access this instance.
   **Note**: If you have multiple keys to be authorized to access your reserved instances, or you have changed your public key in profile, you need add those keys in each reserved instance separately.

### 1.5 Access a Bare Metal Instance

**WARNING:** All reserved TDX Systems will be terminated after 7 days.
1. To access a launched TDX System Instance, from 'View Instances', Click on 'Click here to copy the SSH command' and paste in your terminal or command prompt.

   ![image](https://github.com/IntelConfidentialComputing/tdx-amber-idc-preview/assets/38536938/443a8771-6ca5-442f-9e81-a8eb75ec99f3)


   **Note**: If you are connecting to TDX System from your company Corporate Network (behind a proxy), you will need to follow the section [Access from Corporate Network (optional)](#17-access-from-corporate-network-optional) below.

2. User will be shown a password and prompted to enter the password. Enter the shown password.
   <img src="https://github.com/IntelConfidentialComputing/tdx-amber-idc-preview/assets/38536938/a3856f46-f77f-43ed-b652-b5c6c0e8b997"  width="900" height="400">
4. After entering the password, you will be logged into the launched TDX System.
5. If you have multiple keys to be authorized to access your reserved instances, you can add those additional keys by following the next step without relaunching instance.
6. In View Instances, on a launched instance, Click on Click here to add additional SSH Keys, to add your additional SSH keys.

![](./doc/devcloud_additional_ssh_key.png)

12. If you have changed your public key in profile after you launched an instance, you can add your new key by following the next step without relaunching instance.
13. In View Instances, on a launched instance, Click on Click here to add additional SSH Keys, to add your additional SSH keys.

![](./doc/devcloud_additional_ssh_key.png)

   **Note** To upload a file to launched instance, open a new terminal on your local system and use the following cmd.
   ```
   scp -P 10022 [LOCAL_FILE_NAME] devcloud@localhost:[PATH_TO_DESTINATION]
   ```
   **Note** To download a file from launched instance, open a new terminal on your local system and use the follwoing cmd.
   ```
   scp -P 10022 devcloud@localhost:[PATH_TO_DESTINATION] .
   ```

### 1.6 Help/Support Resources

![](./doc/devcloud_support.png)

### 1.7 Access from Corporate Network (optional)
   **WARNING**: If you are connecting (SSH) to TDX system from your company's Corporate Network (dehid a proxy), you will need to update SSH config file.

   **Note**: If you connect using Command Prompt on Microsoft* Windows* Operating System, you must install [gitforwindows](https://gitforwindows.org/).

1. Setting up SSH Configuration is an one time task.
2. Your SSH configuration file is located in a folder named .ssh under your user's home folder. If the file is not present, create one.
3. Copy & Paste the following to SSH config file (~/.ssh/config).

   - Linux*/macOS*:
   ```
   Host 146.152.*.* idcbetabatch.eglb.intel.com
   ProxyCommand /usr/bin/nc -x PROXYSERVER:PROXYSPORT %h %p
   ```
   - Windows*:
   ```
   Host 146.152.*.* idcbetabatch.eglb.intel.com
   ProxyCommand "C:\Program Files\Git\mingw64\bin\connect.exe" -S PROXYSERVER:PROXYSPORT %h %p 
   ```

4. From your Lab Administrator, get PROXYSERVER and PROXYPORT in your Corporate Network for SSH, NOT for HTTP/HTTPS Proxy.
5. Replace PROXYSERVER and PROXYPORT with the information you received from your lab administrator and save the SSH Config file.  
6. Go back to section [Access a Bare Metal Instance](#15-access-a-bare-metal-instance)


## 2 Intel® Project Amber info
You will also receive another email with subject "Intel® Trust Domain Extensions and Project Amber in Intel® DevCloud". The email will contain the Amber API key and Amber URL that you will need for attestation.

## 3 Use TDX VM
### 3.1 Initial setup

Once logged into the TDX-enabled system, clone the GitHub project and execute the initialization scripts.

```
git clone https://github.com/IntelConfidentialComputing/tdx-amber-idc-preview
cd tdx-amber-idc-preview/scripts
./init.sh
```


### 3.2 Create TDVM
![](/doc/customer_create_guest_image.png)

- Create a TD guest image from official Ubuntu 22.04 image as follows:
```
./create-guest-image.sh -o <image file name> -u <username> -p <password> -n <guest vm name>
```
Example
```
./create-guest-image.sh -o tdx-guest.qcow2 -u tdx -p 123TdVMTest -n my-guest
```

- Start TDVM via libvirt
After creating the guest image, use the following command to create a TDVM
```
/start-virt.sh -i <image file name> -n <guest vm name>
```
Example
```
./start-virt.sh -i tdx-guest.qcow2 -n my-guest
```

- You can manage the TDVM using vrish toll with the commands below (optional)
```
# Examples of commands to manage VMs (should be run on the host)
#To escape out of TVDM use ^] (i.e. hit Ctrl+] keys)

# list all VMs created by current Linux account
virsh list --all

# Suspend a VM
virsh suspend my-guest

# Resume a VM
virsh resume my-guest

# Shutdown a VM
virsh shutdown my-guest

# To start a VM
virsh start my-guest

# To connect to the VM Console
virsh console my-guest
```
_NOTE: To exit a running VM please use ^] (Ctrl + ])
_NOTE: please change `my-guest` to your guest's name._

_NOTE: Please check chapter 3.2 at the [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0 v0.10](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html)_

### 3.3 Check Trusted Execution Environment (TEE) environment

1. Check TD Report

`TDREPORT` is a fixed-size data structure generated by the TDX module which contains guest-specific information (such as build and boot measurements), platform security version, and the MAC to protect the integrity of the `TDREPORT`. For more details on `TDREPORT` please refer to section 4.2 in the [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0 v0.10](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html)_

```
to generate the td report run the following command
tdx@tdx-guest:~$ tdx_tdreport
```

### 3.4 Use Amber client to generate quote

```
tdx@tdx-guest:~$ sudo amber-cli quote

```

### 3.5 Attestation
Execute the following commands to perform the attestation.
```
tdx@tdx-guest:~$ export AMBER_URL=<AMBER URL String>
tdx@tdx-guest:~$ export AMBER_API_KEY=<AMBER API Key>
tdx@tdx-guest:~$ amber-cli create-key-pair -k key.pem
tdx@tdx-guest:~$ sudo -E amber-cli token
```
_Note: Make cure there are no white space before or after the API key_

## 4. Run workload without attestation in TDVM
Running workloads in a TDVM is exactly the same as you would run the workload in a non-confidential VM.
For example, run the nginx web server in a container
```
tdx@tdx-guest:~$sudo docker run -it --rm -d -p 8080:80 --name web nginx
tdx@tdx-guest:~$curl http://localhost:8080
```

## 5. Further Reading

- [Intel® TDX Whitepaper](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-trust-domain-extensions.html)
- [Amber Introduction](https://projectamber.intel.com/)
- [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html) or [here](/doc/White%20Paper%20-%20Linux%20Stack%20for%20Intel®%20TDX-v0.10.pdf)
- [Confidential Cloud Native Primitives (CCNP)](https://github.com/intel/confidential-cloud-native-primitives)
