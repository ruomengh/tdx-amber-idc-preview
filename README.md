# Intel Developer Cloud (IDC) TDX Amber Preview

## 1. Customer On-Board Workflow
![](/doc/overall_customer_on_board.png)


### 1.1 Fill out Request Form


### 1.2 Receive Emails for Intel SDP Login and Intel Amber info

You will received two emails, one is for the information of `Intel SDP Login`, and another is for
Amber's URL, API Key and the URL of this github repository.

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

In the second email,

TBD

### 1.3 Login Bare Metal

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
git clone <Github URL for On-Board Repo>
cd ./scripts
./init.sh
```

_NOTE: Please get `<Github URL for On-Board Repo>` from the email after submitting request form in above 1.2._


### 1.4 Create TDVM

- Create a TD guest image from official Ubuntu 22.04 image as follows:

![](/doc/customer_create_guest_image.png)

```
./create-guest-image.sh -o tdx-guest.qcow2 -p 123TdVMTest
```

If want to customize the guest vm name, user name:
```
./create-guest-image.sh -o tdx-guest.qcow2 -u tdx -p 123TdVMTest -n my-guest
```


- Create TDVM via libvirt

```
./start-virt.sh -i tdx-guest-ubuntu-22.04.qcow2 -n my-guest
```

- After creation, please use virsh to manage the TDVM

```
# list all VMs created by current Linux account
virsh list --all

# Suspend a VM
virsh suspend my-guest

# Resume a VM
virsh resume my-guest

# Shutdown a VM
virsh shutdown my-guest

```

_NOTE: please change `my-guest` to your guest's name._

_NOTE: Please check chapter 3.2 at the [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0 v0.10](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html)_


### 1.5 Login TD guest

1. Login in via SSH command line

```
virsh console my-guest
```

2. Use virt-manager GUI application running on your laptop to manage all VMs from remote server.

![](/doc/customer_manage_tdvm.png)

_NOTE: You can only manage the VMs created by your Linux account._

### 1.6 Check TEE environment

1. Check TD Report

```
tdx@tdx-guest:~$ tdx_tdreport
=> Dump TD Report
00000000  81 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000010  05 05 11 13 03 FF 00 03 00 00 00 00 00 00 00 00  ................
00000020  3E 00 FD EF 85 08 B2 31 F9 3D 72 2B 97 1A 9F B1  >......1.=r+....
00000030  51 26 4E 7F E4 1F B8 A4 DD 7B FD FC 06 92 D5 AD  Q&N......{......
00000040  08 FA 9A DD F3 ED 77 1E B1 5B 1B 56 C7 F7 21 97  ......w..[.V..!.
00000050  61 C9 4B 22 EE C7 C9 C4 06 DD 44 13 75 E1 F1 E4  a.K"......D.u...
00000060  36 4E 80 10 6D C7 09 FA 28 B6 A6 0B A1 2C 4F DA  6N..m...(....,O.
00000070  63 09 4C 33 3D 19 D9 92 39 43 62 AE 61 7B 80 15  c.L3=...9Cb.a{..
00000080  70 B2 76 CF 82 7F 00 00 00 00 00 00 00 00 00 00  p.v.............
00000090  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000000A0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000000B0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000000C0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000000D0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000000E0  C9 02 CA CC E3 CB B3 AC A0 65 87 D2 2A BB B5 F7  .........e..*...
000000F0  74 5F 8F 7B 69 9B CB EB 69 5A A1 74 D3 53 C3 FC  t_.{i...iZ.t.S..
00000100  FF 01 00 00 00 00 00 00 04 00 05 00 00 00 00 00  ................
00000110  00 00 00 00 00 00 00 00 48 FA 69 94 9D B0 80 02  ........H.i.....
00000120  EE 84 25 28 47 F5 72 98 8B 1D 6E 56 8E C1 35 3F  ..%(G.r...nV..5?
00000130  64 CB 6C 0F D9 05 37 5F 69 AD 95 9C 0E AF 77 47  d.l...7_i.....wG
00000140  AC 70 A3 92 78 93 02 A1 00 00 00 00 00 00 00 00  .p..x...........
00000150  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000160  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000170  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000180  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000190  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000001A0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000001B0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000001C0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000001D0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000001E0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000001F0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000200  01 00 00 50 00 00 00 80 E7 02 06 00 00 00 00 00  ...P............
00000210  70 EB 10 6D AB 41 CC 6C C0 A6 B8 CF ED 19 B7 28  p..m.A.l.......(
00000220  1C 74 5C 5A A2 D0 6F 8B FB 55 5C D9 D4 B8 95 A6  .t\Z..o..U\.....
00000230  66 A1 A3 C7 2F EC 9E 9A B9 92 71 75 02 FB 5A 8C  f.../.....qu..Z.
00000240  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000250  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000260  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000270  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000280  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000290  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000002A0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000002B0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000002C0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000002D0  35 1D 9E D3 66 01 80 66 67 D8 92 07 AB 9E B8 1B  5...f..fg.......
000002E0  F0 B2 5A CF 20 61 B5 45 F1 62 13 4C 37 D9 C4 6B  ..Z. a.E.b.L7..k
000002F0  D4 55 51 B1 12 DF 5C B9 04 51 74 13 9F 87 72 6A  .UQ...\..Qt...rj
00000300  3B 09 ED EE 95 F0 3D 4D B9 CA 70 F6 CC 12 DD 38  ;.....=M..p....8
00000310  B2 C9 85 99 78 8F F5 65 C1 B6 A1 92 0F 9B FB 79  ....x..e.......y
00000320  71 AF 67 D1 C1 7A 4B BA D5 27 BC F1 83 F9 E4 65  q.g..zK..'.....e
00000330  50 2E 80 E1 C4 3F E0 E6 0D 41 2D A7 9A A0 CF E9  P....?...A-.....
00000340  AB 7F 3F FA B8 86 94 44 25 DA F6 B0 94 39 C5 6C  ..?....D%....9.l
00000350  AD E5 BA 97 2E C7 39 6C 71 E6 C9 AF 4D 82 A1 69  ......9lq...M..i
00000360  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000370  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000380  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000390  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003A0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003B0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003C0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003D0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003E0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003F0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
```

_NOTE: Please check chapter 4.2 at the [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0 v0.10](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html)_


2. Check TDX event logs and RTMR

```
sudo tdx_eventlogs
=> Read CCEL ACPI Table
00000000  43 43 45 4C 38 00 00 00 01 A5 49 4E 54 45 4C 20  CCEL8.....INTEL
00000010  45 44 4B 32 20 20 20 20 02 00 00 00 20 20 20 20  EDK2    ....
00000020  13 00 00 01 02 00 00 00 00 00 01 00 00 00 00 00  ................
00000030  00 70 63 7D 00 00 00 00                          .pc}....
Revision:     1
Length:       56
Checksum:     A5
OEM ID:       b'INTEL '
CC Type:      2
CC Sub-type:  0
Log Lenght:   0x00010000
Log Address:  0x7D637000

=> Read Event Log Data - Address: 0x7D637000(0x10000)
==== TDX Event Log Entry - 0 [0x7D637000] ====
RTMR              : 0
Type              : 3 (EV_NO_ACTION)
Length            : 65
Algorithms Number : 1
  Algorithms[0xC] Size: 384
RAW DATA: ----------------------------------------------
7D637000  01 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00  ................
7D637010  00 00 00 00 00 00 00 00 00 00 00 00 21 00 00 00  ............!...
7D637020  53 70 65 63 20 49 44 20 45 76 65 6E 74 30 33 00  Spec ID Event03.
7D637030  00 00 00 00 00 02 00 02 01 00 00 00 0C 00 30 00  ..............0.
7D637040  00                                               .
RAW DATA: ----------------------------------------------
==== TDX Event Log Entry - 1 [0x7D637041] ====
RTMR              : 0
Type              : 0x8000000B (UNKNOWN)
Length            : 108
Algorithms ID     : 12 (TPM_ALG_SHA384)
Digest[0] :
00000000  BA 1A 3A DD FA B1 C9 57 26 77 2D B8 FD D9 92 AC  ..:....W&w-.....
00000010  CE 37 68 6D C2 B6 64 04 FC 0C 3C 76 9E 54 B3 C5  .7hm..d...<v.T..
00000020  6D 5E 15 0C D8 38 9D F5 7E CC 77 AA 63 4C 7C 6B  m^...8..~.w.cL|k
RAW DATA: ----------------------------------------------
7D637041  01 00 00 00 0B 00 00 80 01 00 00 00 0C 00 BA 1A  ................
7D637051  3A DD FA B1 C9 57 26 77 2D B8 FD D9 92 AC CE 37  :....W&w-......7
7D637061  68 6D C2 B6 64 04 FC 0C 3C 76 9E 54 B3 C5 6D 5E  hm..d...<v.T..m^
7D637071  15 0C D8 38 9D F5 7E CC 77 AA 63 4C 7C 6B 2A 00  ...8..~.w.cL|k*.
7D637081  00 00 09 54 64 78 54 61 62 6C 65 00 01 00 00 00  ...TdxTable.....
7D637091  00 00 00 00 AF 96 BB 93 F2 B9 B8 4E 94 62 E0 BA  ...........N.b..
7D6370A1  74 56 42 36 00 90 80 00 00 00 00 00              tVB6........
RAW DATA: ----------------------------------------------

==== TDX Event Log Entry - 2 [0x7D6370AD] ====
RTMR              : 0
Type              : 0x8000000A (UNKNOWN)
Length            : 124
Algorithms ID     : 12 (TPM_ALG_SHA384)
Digest[0] :
00000000  34 4B C5 1C 98 0B A6 21 AA A0 0D A3 ED 74 36 F7  4K.....!.....t6.
00000010  D6 E5 49 19 7D FE 69 95 15 DF A2 C6 58 3D 95 E6  ..I.}.i.....X=..
00000020  41 2A F2 1C 09 7D 47 31 55 87 5F FD 56 1D 67 90  A*...}G1U._.V.g.
RAW DATA: ----------------------------------------------
7D6370AD  01 00 00 00 0A 00 00 80 01 00 00 00 0C 00 34 4B  ..............4K
7D6370BD  C5 1C 98 0B A6 21 AA A0 0D A3 ED 74 36 F7 D6 E5  .....!.....t6...
7D6370CD  49 19 7D FE 69 95 15 DF A2 C6 58 3D 95 E6 41 2A  I.}.i.....X=..A*
7D6370DD  F2 1C 09 7D 47 31 55 87 5F FD 56 1D 67 90 3A 00  ...}G1U._.V.g.:.
7D6370ED  00 00 29 46 76 28 58 58 58 58 58 58 58 58 2D 58  ..)Fv(XXXXXXXX-X
7D6370FD  58 58 58 2D 58 58 58 58 2D 58 58 58 58 2D 58 58  XXX-XXXX-XXXX-XX
7D63710D  58 58 58 58 58 58 58 58 58 58 29 00 00 00 C0 FF  XXXXXXXXXX).....
7D63711D  00 00 00 00 00 40 08 00 00 00 00 00              .....@......
RAW DATA: ----------------------------------------------

==== TDX Event Log Entry - 3 [0x7D637129] ====
RTMR              : 0
Type              : 0x80000001 (EV_EFI_VARIABLE_DRIVER_CONFIG)
Length            : 119
Algorithms ID     : 12 (TPM_ALG_SHA384)
Digest[0] :
00000000  CF A4 E2 C6 06 F5 72 62 7B F0 6D 56 69 CC 2A B1  ......rb{.mVi.*.
00000010  12 83 58 D2 7B 45 BC 63 EE 9E A5 6E C1 09 CF AF  ..X.{E.c...n....
00000020  B7 19 40 06 F8 47 A6 A7 4B 5E AE D6 B7 33 32 EC  ..@..G..K^...32.
RAW DATA: ----------------------------------------------
7D637129  01 00 00 00 01 00 00 80 01 00 00 00 0C 00 CF A4  ................
7D637139  E2 C6 06 F5 72 62 7B F0 6D 56 69 CC 2A B1 12 83  ....rb{.mVi.*...
7D637149  58 D2 7B 45 BC 63 EE 9E A5 6E C1 09 CF AF B7 19  X.{E.c...n......
7D637159  40 06 F8 47 A6 A7 4B 5E AE D6 B7 33 32 EC 35 00  @..G..K^...32.5.
7D637169  00 00 61 DF E4 8B CA 93 D2 11 AA 0D 00 E0 98 03  ..a.............
7D637179  2B 8C 0A 00 00 00 00 00 00 00 01 00 00 00 00 00  +...............
7D637189  00 00 53 00 65 00 63 00 75 00 72 00 65 00 42 00  ..S.e.c.u.r.e.B.
7D637199  6F 00 6F 00 74 00 00                             o.o.t..
RAW DATA: ----------------------------------------------

...


=> Replay Rolling Hash - RTMR
==== RTMR[0] ====
00000000  35 1D 9E D3 66 01 80 66 67 D8 92 07 AB 9E B8 1B  5...f..fg.......
00000010  F0 B2 5A CF 20 61 B5 45 F1 62 13 4C 37 D9 C4 6B  ..Z. a.E.b.L7..k
00000020  D4 55 51 B1 12 DF 5C B9 04 51 74 13 9F 87 72 6A  .UQ...\..Qt...rj

==== RTMR[1] ====
00000000  3B 09 ED EE 95 F0 3D 4D B9 CA 70 F6 CC 12 DD 38  ;.....=M..p....8
00000010  B2 C9 85 99 78 8F F5 65 C1 B6 A1 92 0F 9B FB 79  ....x..e.......y
00000020  71 AF 67 D1 C1 7A 4B BA D5 27 BC F1 83 F9 E4 65  q.g..zK..'.....e

==== RTMR[2] ====
00000000  05 14 6E F3 7B E8 1C 21 DC 7F CA 2D 3B DA 1E 0F  ..n.{..!...-;...
00000010  EE 63 70 1E B5 F0 25 38 4D 0B FC 38 D4 41 5F 7E  .cp...%8M..8.A_~
00000020  48 D8 26 C5 9E 86 91 9A 91 40 35 2B 97 B5 3F 2F  H.&......@5+..?/

==== RTMR[3] ====
00000000  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000010  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000020  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
```


3. Check TD Quote

```
tdx@tdx-guest:~$ tdx_quote
=> Dump TD Quote
No report data, generating default quote
00000000  04 00 02 00 81 00 00 00 00 00 00 00 93 9A 72 33  ..............r3
00000010  F7 9C 4C A9 94 0A 0D B3 95 7F 06 07 A3 FC A7 3D  ..L............=
00000020  5E 2E 43 4B B9 8C E5 16 AE E0 99 0E 00 00 00 00  ^.CK............
00000030  04 00 06 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000040  48 FA 69 94 9D B0 80 02 EE 84 25 28 47 F5 72 98  H.i.......%(G.r.
00000050  8B 1D 6E 56 8E C1 35 3F 64 CB 6C 0F D9 05 37 5F  ..nV..5?d.l...7_
00000060  69 AD 95 9C 0E AF 77 47 AC 70 A3 92 78 93 02 A1  i.....wG.p..x...
00000070  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000080  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000090  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000000A0  00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 80  ................
000000B0  E7 02 06 00 00 00 00 00 A4 A0 03 34 6C 5A 19 A6  ...........4lZ..
000000C0  FD 25 04 71 E8 72 BD 07 1D 8C 92 D7 43 1A BD A4  .%.q.r......C...
000000D0  63 41 78 08 A1 73 83 AA 0D 42 98 78 14 BC 92 F5  cAx..s...B.x....
000000E0  F5 9C 60 44 B6 77 F5 14 00 00 00 00 00 00 00 00  ..`D.w..........
000000F0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000100  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000110  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000120  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000130  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000140  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000150  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000160  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000170  00 00 00 00 00 00 00 00 4D BA 88 4F DA 84 88 90  ........M..O....
00000180  18 2A 93 52 DB E1 D7 52 55 74 33 F3 97 D8 79 43  .*.R...RUt3...yC
00000190  0E 16 F5 C4 68 F0 4C 5D DB A1 27 6E D1 5C 8E 2D  ....h.L]..'n.\.-
000001A0  3A 2C 06 B6 25 EE 91 3E 7D 12 F4 CE F1 EB CA 55  :,..%..>}......U
000001B0  ED 3B 54 6F 6A BE D5 1F D0 A7 A5 C8 4F E1 E3 64  .;Toj.......O..d
000001C0  F2 AC 83 D6 04 68 A5 8B C5 EB B1 CC 0C 87 CC C0  .....h..........
000001D0  F4 83 A9 FA 83 17 C7 33 4C D2 94 D5 25 BA AC D4  .......3L...%...
000001E0  1D 52 56 C8 C4 ED 9B AE A0 0C 09 FE C9 6E 62 F4  .RV..........nb.
000001F0  68 D0 B6 63 43 6E B9 D5 6D A7 0E 94 53 3E 17 20  h..cCn..m...S>.
00000200  FC BF 4E B2 0A 32 18 C8 00 00 00 00 00 00 00 00  ..N..2..........
00000210  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000220  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000230  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000240  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000250  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000260  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000270  00 00 00 00 00 00 00 00 CC 10 00 00 04 AB 0A 03  ................
00000280  E5 C1 92 50 8B 60 C6 35 7E BD 03 1C 85 63 E4 66  ...P.`.5~....c.f
00000290  E1 09 2F D2 DB 7D C8 A6 5C BD AD 57 D9 7A 49 53  ../..}..\..W.zIS
000002A0  71 0C 82 E2 14 31 4F 89 4B 65 52 3E 65 FF E4 63  q....1O.KeR>e..c
000002B0  77 41 8C 05 89 7A 73 51 D8 D8 C4 CC 26 35 A1 12  wA...zsQ....&5..
000002C0  31 6F B7 55 9A B3 15 AD 67 66 99 F9 5D 26 80 7C  1o.U....gf..]&.|
000002D0  46 FA 4D EC 73 AC FE 0E FC F0 D3 A0 16 87 A6 77  F.M.s..........w
000002E0  91 7D E6 61 9D 35 52 77 BF 4A 69 3E F8 09 43 9A  .}.a.5Rw.Ji>..C.
000002F0  F2 6F 2E 92 39 81 C0 B0 BD B9 75 B9 06 00 46 10  .o..9.....u...F.
00000300  00 00 06 06 13 15 03 FF 00 04 00 00 00 00 00 00  ................
00000310  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000320  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000330  00 00 15 00 00 00 00 00 00 00 E7 00 00 00 00 00  ................
00000340  00 00 39 6B 1E 35 80 24 27 94 87 C4 7A F9 C5 61  ..9k.5.$'...z..a
00000350  BD DC 15 25 86 39 AA D2 DD AF 76 00 90 EF 46 3F  ...%.9....v...F?
00000360  0B 84 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000370  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000380  00 00 DC 9E 2A 7C 6F 94 8F 17 47 4E 34 A7 FC 43  ....*|o...GN4..C
00000390  ED 03 0F 7C 15 63 F1 BA BD DF 63 40 C8 2E 0E 54  ...|.c....c@...T
000003A0  A8 C5 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003B0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003C0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003D0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003E0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
000003F0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000400  00 00 02 00 04 00 00 00 00 00 00 00 00 00 00 00  ................
00000410  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000420  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000430  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000440  00 00 E6 33 21 19 61 4B 04 90 79 56 08 95 50 82  ...3!.aK..yV..P.
00000450  02 07 03 6F E2 B9 A5 8D 21 3B 1A 80 12 6D 6F 37  ...o....!;...mo7
00000460  9A 7F 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000470  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000480  00 00 9D B3 22 07 C2 55 59 ED 1B F6 28 D9 D1 88  ...."..UY...(...
00000490  46 C2 25 42 45 50 23 BB BB 6A 96 2D 5C F3 2E 6D  F.%BEP#..j.-\..m
000004A0  F8 1B F5 E7 3E 1A 4C A3 66 5D F3 04 96 96 F3 50  ....>.L.f].....P
000004B0  DD AA 31 88 BF 7B 76 8E 51 B1 31 DF D7 45 E2 A7  ..1..{v.Q.1..E..
000004C0  C6 53 20 00 00 01 02 03 04 05 06 07 08 09 0A 0B  .S .............
000004D0  0C 0D 0E 0F 10 11 12 13 14 15 16 17 18 19 1A 1B  ................
000004E0  1C 1D 1E 1F 05 00 5E 0E 00 00 2D 2D 2D 2D 2D 42  ......^...-----B
...
```


### 1.7 Use Amber client to generate Quote


```
sudo amber-cli quote
[4 0 2 0 129 0 0 0 0 0 0 0 147 154 114 51 247 156 76 169 148 10 13 179 149 127 6 7 27 121 246 32 9 47 180 161 197 185 188 207 5 61 32 16 0 0 0 0 4 0 5 0 0 0 0 0 0 0 0 0 0 0 0 0 72 250 105 148 157 176 128 2 238 132 37 40 71 245 114 152 139 29 110 86 142 193 53 63 100 203 108 15 217 5 55 95 105 173 149 156 14 175 119 71 172 112 163 146 120 147 2 161 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 80 0 0 0 128 231 2 6 0 0 0 0 0 112 235 16 109 171 65 204 108 192 166 184 207 237 25 183 40 28 116 92 90 162 208 111 139 251 85 92 217 212 184 149 166 102 161 163 199 47 236 158 154 185 146 113 117 2 251 90 140 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 53 29 158 211 102 1 128 102 103 216 146 7 171 158 184 27 240 178 90 207 32 97 181 69 241 98 19 76 55 217 196 107 212 85 81 177 18 223 92 185 4 81 116 19 159 135 114 106 59 9 237 238 149 240 61 77 185 202 112 246 204 18 221 56 178 201 133 153 120 143 245 101 193 182 161 146 15 155 251 121 113 175 103 209 193 122 75 186 213 39 188 241 131 249 228 101 80 46 128 225 196 63 224 230 13 65 45 167 154 160 207 233 171 127 63 250 184 134 148 68 37 218 246 176 148 57 197 108 173 229 186 151 46 199 57 108 113 230 201 175 77 130 161 105 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 207 131 225 53 126 239 184 189 241 84 40 80 214 109 128 7 214 32 228 5 11 87 21 220 131 244 169 33 211 108 233 206 71 208 209 60 93 133 242 176 255 131 24 210 135 126 236 47 99 185 49 189 71 65 122 129 165 56 50 122 249 39 218 62 204 16 0 0 187 28 133 119 143 215 173 44 211 62 19 53 238 75 35 219 201 157 239 64 219 187 154 55 7 200 250 124 110 144 82 108 185 124 210 236 178 241 35 109 81 73 166 37 130 117 201 254 112 227 60 147 253 35 245 66 205 187 14 240 118 12 38 83 153 122 146 188 247 179 234 115 247 86 36 213 136 55 168 154 204 182 95 141 63 253 204 80 160
...
```


### 1.8 User Amber client + API key for Attestation

```
export AMBER_URL=<AMBER URL String>
export AMBER_API_KEY=<AMBER API Key>
amber-cli quote
amber-cli quote
amber-cli create-key-pair -k key.pem
amber-cli token
```

## 2. Run workload without attestation in TDVM

There is no any different to run workload in TDVM with the non-confidential VM, like:

```
docker run nginx
```

## 3. Enable Attestation in Customer Workload

### 3.1 Get TD Quote

To get TD quote, there are 2 optional parameter, `nonce` and `user_data`, `nonce` could be a random
bytes to prevent replay attack, and `user_data` could be a public key, the 2 paramters will be
measured on attestation.

```
from pytdxattest.tdquote import TdQuote

tdquote = TdQuote.get_quote(user_data=public_key)
```

### 3.2 Request Key from KBS

A public key could be used as user data to encrypt the key for transmission.

```
user_data = base64.b64encode(public_key).decode('utf-8')
quote = base64.b64encode(tdquote.data).decode('utf-8')

req = {
    "quote": quote,
    "user_data": user_data
}
headers = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Attestation-Type": "TDX"
}

# An example KBS API, key ID should be configured
KBS_API = KBS_URL + f"/v1/keys/{KEYID}/transfer"
resp = requests.post(KBS_API, json=req, headers=headers)

```

### 3.3 Decrypt data in TEE

Typically, the AES 256 GCM encrypted data format should be:

12 bytes header | [12] bytes IV | encrypted data | [16] bytes tag
---|---|---|---

and the 12 bytes header:

uint32 IV length | uint32 tag length | uint32 data length
---|---|---

```
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

def decrypt_data(encrypted_data, key) -> bytes:

    if encrypted_data is None or key is None:
        raise ValueError("Encrypted data or key is empty")

    header_len = 12
    iv_len, tag_len, data_len = struct.unpack('<3I', encrypted_data[:header_len])
    iv = encrypted_data[header_len : (iv_len + header_len)]
    data = encrypted_data[(iv_len + header_len) : -tag_len]
    tag = encrypted_data[-tag_len:]

    decryptor = Cipher(algorithms.AES(key), modes.GCM(iv, tag)).decryptor()
    decrypted_data = decryptor.update(data) + decryptor.finalize()
    return decrypted_data
```

## 4. Further Reading

- [Intel TDX Whitepaper](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-trust-domain-extensions.html)
- [Amber Introduction](https://projectamber.intel.com/)
- [Whitepaper: Linux* Stacks for Intel® Trust Domain Extension 1.0](https://www.intel.com/content/www/us/en/content-details/783067/whitepaper-linux-stacks-for-intel-trust-domain-extension-1-0.html) or [here](/doc/White%20Paper%20-%20Linux%20Stack%20for%20Intel®%20TDX-v0.10.pdf)
