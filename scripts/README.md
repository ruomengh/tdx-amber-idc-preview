# Customer' Workflow


## 1. Getting Started Steps

### 1.1 Step 1: Initiate environment and download dependencies

```
cd customer
./init.sh
```

### 1.2 Step 2: Create guest image

```
cd customer
./create-guest-image.sh
```
By default, the guest machine name is "tdx-guest", the user is "tdx", the password
is "123456"

If you want to customize default settings, please use following examples:
```
cd customer
./create-guest-image.sh -n "my-td-guest-name" -u "my_username" -p "my_password"
```

When successful, the guest image will put at `customer/tdx-guest-ubuntu-22.04.qcow2`

### 1.3 Step 3: Start TDVM via libvirt

```
./start-virt.sh -i tdx-guest-ubuntu-22.04.qcow2 -n ken-guest -f
```

The whole flow is as follows, please change your guest name via `-n`
```
=====================================================================
 Use template   : /home/ken/idc-tdx-amber-preview/customer/tdx_libvirt_ubuntu_host.template
 Guest XML      : /tmp/libvirt-vms/ken-guest.xml
 Guest Image    : /tmp/libvirt-vms/ken-guest.qcow2
 Force Recreate : true
=====================================================================
> Clean up the old guest...
> Create /tmp/libvirt-vms/ken-guest.qcow2...
> Create /tmp/libvirt-vms/ken-guest.xml...
> Modify configurations...
> Create VM domain...
> Start VM...
> Connect console...
Connected to domain 'ken-guest'
Escape character is ^] (Ctrl + ])

Ubuntu 22.04.2 LTS tdx-guest hvc0

tdx-guest login:  <== input the password specified in step 2, default is `tdx`
Password:         <== input the password specified in step 2, default is `123456`
```

### 1.4 Step 4: Check TDReport and eventlog within TD guest

```
# after login TD guest
sudo tdx_eventlogs
sudo tdx_tdreport
```

### 1.5 Step 5: Use Amber
```
# after login TD guest
sudo amber-cli quote
```

## 2 Others

### 2.1 Start TDVM via qemu instead of libvirt

```
cd customer
./start-qemu.sh -i tdx-guest-ubuntu-22.04.qcow2
```

### 2.2 Check IMA measurement within TD guest

```
sudo cat ascii_runtime_measurements
 2 d72b68256bd2d085188cf87969254666325e1b621d128b3d81c4f52a3a6264e8e88d4507d62061f5d8af9f9d04cb7471 ima-n14bcb6e8789fd727f044919438b65404effddf9c6d6241192e38b19277c7910dbcafdd02aaef5e8464031428 boot_aggregate
 2 decfea08f19fd1583c5004d9fb86f2665dc2ae41b9ba8c12a9d01bb62dd087255788b4df35d01651e537a1ed87e81b51 ima-be93113de42e3afdc15aef9c4a4afc44134ff422e52d0f87246c10be63fe07074fbc9d80e0ec3845e37c0e6e0a kernel_version d7670323476332b372d67656e65726963

```

### 2.3 Quit to TD host from TDX guest

Press "ctrl + ]"

### 2.4 Destory TD guest

```
virsh destroy td-guest
virsh undefine td-guest
```

### 2.5 Create a VM with bigger memory and more vCPU core

Please modify the template file [tdx_libvirt_ubuntu_host.template](./tdx_libvirt_ubuntu_host.template).
