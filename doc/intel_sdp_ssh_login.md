Simplified Steps:
Post your SSH Public Key at SSH Public Key (link available only in the email to the customer) and wait for the authorization email.

If you are NOT behind corporate Proxy, copy/paste the command below in a command/terminal prompt.(Password is $harktank2Go)
ssh -J guest@146.152.206.250 -L 10022:192.168.12.2:22 sdp@192.168.12.2

If you are behind corporate Proxy, add the following lines below into .ssh/config with your PROXYSERVER and PROXYPORT
#For Linux Operating System:
Host 146.152.*.*
ProxyCommand /usr/bin/nc -x PROXYSERVER:PROXYPORT %h %p

#For Non-Linux Operating System: (Install gitforwindows.org)
Host 146.152.*.*
ProxyCommand "C:\Program Files\Git\mingw64\bin\connect.exe" -S PROXYSERVER:PROXYPORT %h %p

Then copy/paste the following command on your command/terminal prompt
ssh -J guest@146.152.206.250 -L 10022:192.168.12.2:22 sdp@192.168.12.2

To do file transfer, use SCP to localhost:10022.
It is recommended to add your SSH Public Key to .ssh/authorized_keys on target system(s) for passwordless authentication.


Detailed Steps:

On Microsoft* Windows* Operating System:

 1. Download and install 'git for windows' from https://gitforwindows.org with default options.
 2. Launch cmd.exe
 3. Generate SSH Keys by running ssh-keygen.exe with default options.
 4. Run notepad.exe %USERPROFILE%\.ssh\id_rsa.pub and copy the file content to the link SSH Public Key (link is
      available only in customer email) and wait for authorization email.
 5. Run notepad.exe %USERPROFILE%\.ssh\config.txt (when prompted, select yes and close notepad)
 6. Run ren %USERPROFILE%\.ssh\config.txt config
 7. Run notepad.exe %USERPROFILE%\.ssh\config and copy/paste the following lines into the notepad
      (replace PROXYSERVER:PROXYPORT with your corporate proxy information, for no proxy remove that line)
      (for additional tunnels for KVM/BMC, copy the LocalForward line with your required target IP address and port)

Host sshserver
HostName 146.152.206.250
User guest
ProxyCommand "C:\Program Files\Git\mingw64\bin\connect.exe" -S PROXYSERVER:PROXYPORT %h %p
Host sdp
HostName 192.168.12.2
User sdp
ProxyCommand ssh.exe -W %h:%p sshserver
LocalForward 10443 192.168.12.3:443
LocalForward 10022 192.168.12.2:22

 8. Run ssh.exe sdp and follow the instructions
 9. When prompted for password enter $harktank2Go
 10. If BMC is applicable to this system, browse to https://localhost:10443 for BMC access
 11. To do file transfer, use SCP to localhost:10022


On Linux* Operating System:

 1. Generate SSH Keys by running ssh-keygen with default options.(hit enter for default)
 2. Copy the content of ~/.ssh/id_rsa.pub to the link SSH Public Key (link is available only in customer email) and
      wait for authorization email.
 3. Copy/Paste the following lines into the file ~/.ssh/config
      (Create the file config if it does not exists already)
      (replace PROXYSERVER:PROXYPORT with your corporate proxy information, for no proxy remove that line)
      (for additional tunnels for KVM/BMC, copy the LocalForward line with you required target IP address and port)

Host sshserver
HostName 146.152.206.250
User guest
ProxyCommand /usr/bin/nc -x PROXYSERVER:PROXYPORT %h %p
Host sdp
HostName 192.168.12.2
User sdp
ProxyCommand ssh -W %h:%p sshserver
LocalForward 10443 192.168.12.3:443
LocalForward 10022 192.168.12.2:22

 4. Run ssh sdp and follow the instructions
 5. When prompted for password enter $harktank2Go
 6. If BMC is applicable to this system, browse to https://localhost:10443 for BMC access
 7. To do file transfer, use SCP to localhost:10022