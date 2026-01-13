# rEFInd_MacPro
A copy of rEFInd with a config file that sets VMX to true, enabling virtualization features on 6,1 Mac Pro (2013) "Trash Can" models.

I use Windows 11 LTSC IoT Enterprise and Fedora Linux on my Trash Can these days. macOS isn't very good on these machines anymore. The CPU is still excellent and the GPUs are... okay. Only one problem: virtualization doesn't work! No advanced security features in Windows, no making VMs, and no Windows Sandbox. That won't do, especially for the models with 24 cores and tons of memory.

The solution is using a boot manager called rEFInd. I've found that forum posts and documentation are (respectfully) not the easiest to follow. This is literally just rEFInd downloaded straight from https://sourceforge.net/projects/refind/files/

Instead of the sample config it comes with normally, I renamed the config file and changed one line: uncommenting `enable_and_lock_vmx` and setting it to true. That's all it takes!

Sometimes Windows just decides it doesn't like you and skips rEFInd. I made a script that sets it as the primary bootmanager again. Clear your PRAM (CMD + OPT + P + R on startup) before you run the fixer script, that seems to help.

 1. Download the release.
 2. Extract to somewhere like Desktop.
 3. In an admin Command Prompt, run the following:
	`mountvol S: /S`
	`S:`
 4. Validate you're on the EFI partition:
	`cd EFI`
5. Copy the rEFInd files to your EFI partition:
	`xcopy /E /I "C:\Users\YourUsername\Desktop\refind\refind" S:\EFI\refind`
6. Set rEFInd as the Bootloader:
	`bcdedit /set "{bootmgr}" path \EFI\refind\refind_x64.efi`
7. Restart.

I had Gemini 3 Pro make an [installer script](https://github.com/ldinino/rEFInd_MacPro/blob/main/refind_install.ps1) for Windows that automates the whole process. I haven't tested it yet, but the code looks fine to me. Not my problem if it breaks something.

Maybe in the future I'll have it spit out a bash script for Linux.
