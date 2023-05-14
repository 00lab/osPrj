## OS01-OS版hello world

其实就是让BIOS拉起一个裸机汇编（实模式），对应是保护模式。

ds段寄存器。

写一个汇编程序helloOs.S

```assembly
# 以下是AT&T的语法, $开头表示立即数（如自定义符号代表的偏移量）%开头表示寄存器
BOOTSEG = 0x7c0 # 0x7c00
.code16 #告诉汇编编译器as把当前汇编翻译成16位的指令，若不指定会生成x86的32位/64位的指令，因为编译器是64位的
.text
.global _start

_start:
    jmpl $BOOTSEG, $start2 #长跳转到start2，会使得段寄存器cs=0x7c0，pc寄存器=start2地址，跳转的目的地是0x7c0+start2地址（偏移量）
# 最终跳转到标签start2偏移量的汇编代码中
start2:
    movw $BOOTSEG, %ax # 让ax寄存器=0x7c0
    movw %ax, %ds # 进一步初始化其他寄存器
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    movw $msg, %ax #%msg表示msg符号的地址，即把地址放到%ax寄存器里边
    movw %ax, %bp
    movw $0x01301, %ax #用来指定打印
    movw $0x0c, %bx # 设置屏幕显示helloworld的颜色，bh=0（背景色）,bl=0c(前景色（即字体）红色)
    # movw $0xcf, %bx # 也可换成这行，c会设置成闪烁红色背景色，f会让字体为白色
    movw $12, %cx # cx=字符串长度为立即数12
    movb $0, %dl
    int $0x010 # int中断指令，10h号中断是bios中断，作用就是发起10h号中断，让里边固有函数去cx里读入字符串，让显卡刷新内容

loop:
    jmp loop # 本主程序自己进入死循环

msg:
    .ascii "hello world"

.org 510 # .org作用是让代码之后一直到第510个字节填入0，也就是让汇编编出来的二进制在汇编代码结束后的所有字节填0，目的是为了让编出来的目标文件刚好512字节，刚好一个扇区，因为bios一次会读入一个扇区共512字节到0x7c00的位置。
boot_flag: #在编译出来的二进制文件的最后一个字节设为0xaa55，是bios规定的结束符号。
    .word 0xaa55

```

编译的过程

```shell
as helloOs.S -o helloOs.o #as是gcc的汇编编译器，这样会产生一个目标文件helloOs.o
ld -m elf_x86_64 -Ttext 0x0 -s --oformat binary -o helloOs.img helloOs.o  #ld是链接器
$ ls -l
-rwxrwxr-x 1  512 5月  13 18:19 helloOs.img
```

默认情况下，使用as helloOs.S -o helloOs.o编译出来的 helloOs.o是64位的ELF文件，使用readelf能输出如下内容，所有的段都有。

```shell
$ readelf -a helloOs.o
ELF 头：
  Magic：   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  类别:                              ELF64
  数据:                              2 补码，小端序 (little endian)
  版本:                              1 (current)
  OS/ABI:                            UNIX - System V
  ABI 版本:                          0
  类型:                              REL (可重定位文件)
  系统架构:                          Advanced Micro Devices X86-64
  版本:                              0x1
  入口点地址：               0x0
  程序头起点：          0 (bytes into file)
  Start of section headers:          968 (bytes into file)
  标志：             0x0
  本头的大小：       64 (字节)
  程序头大小：       0 (字节)
  Number of program headers:         0
  节头大小：         64 (字节)
  节头数量：         8
  字符串表索引节头： 7

节头：
  [号] 名称              类型             地址              偏移量
       大小              全体大小          旗标   链接   信息   对齐
  [ 0]                   NULL             0000000000000000  00000000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         0000000000000000  00000040
       0000000000000200  0000000000000000  AX       0     0     1
  [ 2] .rela.text        RELA             0000000000000000  00000360 #重定位段
       0000000000000030  0000000000000018   I       5     1     8
  [ 3] .data             PROGBITS         0000000000000000  00000240
       0000000000000000  0000000000000000  WA       0     0     1
  [ 4] .bss              NOBITS           0000000000000000  00000240
       0000000000000000  0000000000000000  WA       0     0     1
  [ 5] .symtab           SYMTAB           0000000000000000  00000240
       00000000000000f0  0000000000000018           6     9     8
  [ 6] .strtab           STRTAB           0000000000000000  00000330
       000000000000002a  0000000000000000           0     0     1
  [ 7] .shstrtab         STRTAB           0000000000000000  00000390
       0000000000000031  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)

There are no section groups in this file.

本文件中没有程序头。

There is no dynamic section in this file.

重定位节 '.rela.text' at offset 0x360 contains 2 entries:
  偏移量          信息           类型           符号值        符号名称 + 加数
000000000002  00010000000a R_X86_64_32       0000000000000000 .text + 8
000000000014  00010000000c R_X86_64_16       0000000000000000 .text + 27

The decoding of unwind sections for machine type Advanced Micro Devices X86-64 is not currently supported.

Symbol table '.symtab' contains 10 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 0000000000000000     0 SECTION LOCAL  DEFAULT    1
     2: 0000000000000000     0 SECTION LOCAL  DEFAULT    3
     3: 0000000000000000     0 SECTION LOCAL  DEFAULT    4
     4: 00000000000007c0     0 NOTYPE  LOCAL  DEFAULT  ABS BOOTSEG
     5: 0000000000000008     0 NOTYPE  LOCAL  DEFAULT    1 start2
     6: 0000000000000027     0 NOTYPE  LOCAL  DEFAULT    1 msg
     7: 0000000000000025     0 NOTYPE  LOCAL  DEFAULT    1 loop
     8: 00000000000001fe     0 NOTYPE  LOCAL  DEFAULT    1 boot_flag
     9: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT    1 _start

No version information found in this file.
```

如果用objdump -d解析，会输出如下内容

```shell
$ objdump -d helloOs.o

helloOs.o：     文件格式 elf64-x86-64


Disassembly of section .text:

0000000000000000 <_start>:
   0:   66 ea                   data16 (bad)
   2:   00 00                   add    %al,(%rax)
   4:   00 00                   add    %al,(%rax)
   6:   c0                      .byte 0xc0
   7:   07                      (bad)

0000000000000008 <start2>: #能看出与汇编对应
   8:   b8 c0 07 8e d8          mov    $0xd88e07c0,%eax
   d:   8e c0                   mov    %eax,%es
   f:   8e e0                   mov    %eax,%fs
  11:   8e e8                   mov    %eax,%gs
  13:   b8 00 00 89 c5          mov    $0xc5890000,%eax
  18:   b8 01 13 bb 0c          mov    $0xcbb1301,%eax
  1d:   00 b9 0c 00 b2 00       add    %bh,0xb2000c(%rcx)
  23:   cd 10                   int    $0x10

0000000000000025 <loop>:
  25:   eb fe                   jmp    25 <loop>

0000000000000027 <msg>:
  27:   68 65 6c 6c 6f          pushq  $0x6f6c6c65
  2c:   20 77 6f                and    %dh,0x6f(%rdi)
  2f:   72 6c                   jb     9d <msg+0x76>
  31:   64 00 00                add    %al,%fs:(%rax)
        ...

00000000000001fe <boot_flag>:
 1fe:   55                      push   %rbp
 1ff:   aa                      stos   %al,%es:(%rdi)
```

如果把这个ELF格式的二进制直接让BIOS读入，显然是无法启动的，毕竟当前电脑上什么都没有，不会识别ELF格式的文件，只有一个固定的BIOS从固定的地址0x7c00处读入内容，所以OS需要的是一个真正的裸机代码开始，通过特定的汇编指令让CPU一步步进入到设定好的流程，直到运行起来复杂的操作系统。

所以我们本次需要编译出来的二进制不能是ELF格式的，不能有重定位段、数据段这些内容，这就需要用链接器来完成。解释ld命令

```shell
ld -m elf_x86_64 -Ttext 0x0 -s --oformat binary -o helloOs.img helloOs.o
# -m elf_x86_64告诉链接器，输入是x86的64位的elf格式的文件helloOs.o
# -Ttext 0x0：-T的是表示代码段，连起来意思是代码段名字为text在二进制文件0x0的位置，即第一个字节开始就是第一条指令
# -s表示把符号去了
# --oformat binary表示让链接器不要翻译bss、重定位等段，仅需翻译代码段即可
```

最后得到helloOs.img，就是大家所说的镜像文件，再使用objdump发现已不认识该文件了，因为不是elf格式的了

```shell
$ objdump -d helloOs.img
objdump: helloOs.img: 不可识别的文件格式
```

我们可用xxd命令看下该文件的二进制情况，可见熟悉的hello world字符串。

```shell
$ xxd -a -u -s 0 -l 512 helloOs.img
00000000: 66EA 0800 0000 C007 B8C0 078E D88E C08E  f............... # 66EA是跳转指令
00000010: E08E E8B8 2700 89C5 B801 13BB 0C00 B90C  ....'...........
00000020: 00B2 00CD 10EB FE68 656C 6C6F 2077 6F72  .......hello wor
00000030: 6C64 0000 0000 0000 0000 0000 0000 0000  ld..............
00000040: 0000 0000 0000 0000 0000 0000 0000 0000  ................
*
000001f0: 0000 0000 0000 0000 0000 0000 0000 55AA  ..............U. # 结束符55AA，在510和512的位置，共512字节
```

这并不是一个完整的操作系统，仅仅是一个最最简单的引导扇区（Boot Sector），不过它能够在裸机上不依赖与任何东西跑起来。开计算机电源后，它会先进行加电自检（POST），然后寻找启动盘，若是选择从软盘启动，计算机会检查软盘的0面0磁道1扇区，如果发现它以0xAA55(9)结束，则BIOS认为它是一个引导扇区。一个正确的引导扇区除了以0xAA55结束之外，还应该包含一段少于512字节的执行码。一旦BIOS发现了引导扇区，就会将这512字节的内容装载到内存地址0000:7c00处；然后跳转到0000:7c00处将控制权彻底交给这段引导代码。到此为止，计算机不再由BIOS中固有的程序来控制，而变成由操作系统的一部分来控制。（引用于一个操作系统的实现）

dos系统就是在16位实模式下的一个操作系统。

放入仿真器运行：

硬件模拟器（用于模拟硬件平台，启动OS）http://www.oldlinux.org/Linux.old/bochs/Bochs/bochs-2.6.1/Bochs-2.6.1.exe。安装好后，配置boch的配置文件bochsrc.bxrc，helloOS放在跟它同目录下即可，配置floppya:1_44=helloOs.img, status=inserted 。

```tex
#cat bochsrc.bxrc以下内容：
# configuration file generated by Bochs
plugin_ctrl: unmapped=1, biosdev=1, speaker=1, extfpuirq=1, parallel=1, serial=1, gameport=1
config_interface: win32config
display_library: win32
memory: host=32, guest=32 #指定内存32M
romimage: file="D:\Program Files\Bochs-2.6.1/BIOS-bochs-latest"  #ROM的模拟文件
vgaromimage: file="D:\Program Files\Bochs-2.6.1/VGABIOS-lgpl-latest"  #显卡的模拟文件
boot: floppy  #指定从软盘启动，写成boot:a也可，表示从软盘a启动，因为a和b盘都是软盘。c是硬盘，但从硬盘启动更复杂，需要很多硬盘知识，后期再介绍。
floppy_bootsig_check: disabled=0
# no floppya
floppya:1_44=helloOs.img, status=inserted #定义软盘和装载的内容，就是写的helloworld版os：helloOs.img
# no floppyb
ata0: enabled=1, ioaddr1=0x1f0, ioaddr2=0x3f0, irq=14
ata0-master: type=none
ata0-slave: type=none
ata1: enabled=1, ioaddr1=0x170, ioaddr2=0x370, irq=15
ata1-master: type=none
ata1-slave: type=none
ata2: enabled=0
ata3: enabled=0
pci: enabled=1, chipset=i440fx
vga: extension=vbe, update_freq=5
cpu: count=1, ips=4000000, model=bx_generic, reset_on_triple_fault=1, cpuid_limit_winnt=0, ignore_bad_msrs=1, mwait_is_nop=0
cpuid: vendor_string="GenuineIntel", brand_string="              Intel(R) Pentium(R) 4 CPU        "
cpuid: stepping=3, model=3, family=6, mmx=1, apic=xapic, sse=sse2, sse4a=0, misaligned_sse=0
cpuid: sep=1, movbe=0, adx=0, aes=0, xsave=0, xsaveopt=0, x86_64=1, 1g_pages=0, pcid=0
cpuid: fsgsbase=0, smep=0, smap=0, mwait=1
print_timestamps: enabled=0
port_e9_hack: enabled=0
private_colormap: enabled=0
clock: sync=none, time0=local, rtc_sync=0
# no cmosimage
# no loader
log: -
logprefix: %t%e%d
debug: action=ignore
info: action=report
error: action=report
panic: action=ask
keyboard: type=mf, serial_delay=250, paste_delay=100000, user_shortcut=none
mouse: type=ps2, enabled=0, toggle=ctrl+mbutton
parport1: enabled=1, file=none
parport2: enabled=0
com1: enabled=1, mode=null, dev=none
com2: enabled=0
com3: enabled=0
com4: enabled=0
```

启动boch后，在弹出窗里选Load，选中bochsrc.bxrc

![](https://img2023.cnblogs.com/blog/964076/202305/964076-20230513235514430-1030212875.png)


![](https://img2023.cnblogs.com/blog/964076/202305/964076-20230513235450493-1742046625.png)

可见启动成功。在安装目录下还有个bochsdbg.exe，可用bochsdbg.exe -q -f bochsrc.bxrc就可启动调试模式，单步调试刚刚的汇编程序了

也可用图形界面启动dbg模式，一样是load配置文件，然后进入如下界面

```shell
Next at t=0
(0) [0x0000fffffff0] f000:fff0 (unk. ctxt): jmp far f000:e05b         ; ea5be000f0
<bochs:1> n
Next at t=1
(0) [0x0000000fe05b] f000:e05b (unk. ctxt): xor ax, ax                ; 31c0
<bochs:2> n
00000000002i[WGUI ] dimension update x=720 y=400 fontheight=16 fontwidth=9 bpp=8
Next at t=2
(0) [0x0000000fe05d] f000:e05d (unk. ctxt): out 0x0d, al              ; e60d
<bochs:3> b 0x7c00
<bochs:4> c
00000000025i[MEM0 ] allocate_block: block=0x0 used 0x1 of 0x20
00000004661i[BIOS ] $Revision: 11545 $ $Date: 2012-11-11 09:11:17 +0100 (So, 11. Nov 2012) $
00000318067i[KBD  ] reset-disable command received
00000320801i[BIOS ] Starting rombios32
00000321235i[BIOS ] Shutdown flag 0
00000321830i[BIOS ] ram_size=0x02000000
00000322251i[BIOS ] ram_end=32MB
00000362768i[BIOS ] Found 1 cpu(s)
00000376955i[BIOS ] bios_table_addr: 0x000fa448 end=0x000fcc00
00000704752i[PCI  ] i440FX PMC write to PAM register 59 (TLB Flush)
00001032679i[P2I  ] PCI IRQ routing: PIRQA# set to 0x0b
00001032698i[P2I  ] PCI IRQ routing: PIRQB# set to 0x09
00001032717i[P2I  ] PCI IRQ routing: PIRQC# set to 0x0b
00001032736i[P2I  ] PCI IRQ routing: PIRQD# set to 0x09
00001032746i[P2I  ] write: ELCR2 = 0x0a
00001033512i[BIOS ] PIIX3/PIIX4 init: elcr=00 0a
00001041228i[BIOS ] PCI: bus=0 devfn=0x00: vendor_id=0x8086 device_id=0x1237 class=0x0600
00001043498i[BIOS ] PCI: bus=0 devfn=0x08: vendor_id=0x8086 device_id=0x7000 class=0x0601
00001045607i[BIOS ] PCI: bus=0 devfn=0x09: vendor_id=0x8086 device_id=0x7010 class=0x0101
00001045836i[PIDE ] new BM-DMA address: 0xc000
00001046453i[BIOS ] region 4: 0x0000c000
00001048455i[BIOS ] PCI: bus=0 devfn=0x0a: vendor_id=0x8086 device_id=0x7020 class=0x0c03
00001048659i[UHCI ] new base address: 0xc020
00001049276i[BIOS ] region 4: 0x0000c020
00001049402i[UHCI ] new irq line = 9
00001051287i[BIOS ] PCI: bus=0 devfn=0x0b: vendor_id=0x8086 device_id=0x7113 class=0x0680
00001051520i[ACPI ] new irq line = 11
00001051532i[ACPI ] new irq line = 9
00001051561i[ACPI ] new PM base address: 0xb000
00001051575i[ACPI ] new SM base address: 0xb100
00001051603i[PCI  ] setting SMRAM control register to 0x4a
00001215694i[CPU0 ] Enter to System Management Mode
00001215704i[CPU0 ] RSM: Resuming from System Management Mode
00001379722i[PCI  ] setting SMRAM control register to 0x0a
00001394656i[BIOS ] MP table addr=0x000fa520 MPC table addr=0x000fa450 size=0xc8
00001396412i[BIOS ] SMBIOS table addr=0x000fa530
00001396470i[MEM0 ] allocate_block: block=0x1f used 0x2 of 0x20
00001398607i[BIOS ] ACPI tables: RSDP addr=0x000fa650 ACPI DATA addr=0x01ff0000 size=0xf72
00001401804i[BIOS ] Firmware waking vector 0x1ff00cc
00001403602i[PCI  ] i440FX PMC write to PAM register 59 (TLB Flush)
00001404330i[BIOS ] bios_table_cur_addr: 0x000fa674
00001531947i[VBIOS] VGABios $Id: vgabios.c,v 1.75 2011/10/15 14:07:21 vruppert Exp $
00001532018i[BXVGA] VBE known Display Interface b0c0
00001532050i[BXVGA] VBE known Display Interface b0c5
00001534975i[VBIOS] VBE Bios $Id: vbe.c,v 1.64 2011/07/19 18:25:05 vruppert Exp $
00014040328i[BIOS ] Booting from 0000:7c00
(0) Breakpoint 1, 0x0000000000007c00 in ?? ()
Next at t=14040383
(0) [0x000000007c00] 0000:7c00 (unk. ctxt): jmp far 07c0:00000008     ; 66ea08000000c007
<bochs:5> n
Next at t=14040384
(0) [0x000000007c08] 07c0:0008 (unk. ctxt): mov ax, 0x07c0            ; b8c007
<bochs:6> sreg
es:0x0000, dh=0x00009300, dl=0x0000ffff, valid=1
        Data segment, base=0x00000000, limit=0x0000ffff, Read/Write, Accessed
cs:0x07c0, dh=0x00009300, dl=0x7c00ffff, valid=1
        Data segment, base=0x00007c00, limit=0x0000ffff, Read/Write, Accessed
ss:0x0000, dh=0x00009300, dl=0x0000ffff, valid=7
        Data segment, base=0x00000000, limit=0x0000ffff, Read/Write, Accessed
ds:0x0000, dh=0x00009300, dl=0x0000ffff, valid=1
        Data segment, base=0x00000000, limit=0x0000ffff, Read/Write, Accessed
fs:0x0000, dh=0x00009300, dl=0x0000ffff, valid=1
        Data segment, base=0x00000000, limit=0x0000ffff, Read/Write, Accessed
gs:0x0000, dh=0x00009300, dl=0x0000ffff, valid=1
        Data segment, base=0x00000000, limit=0x0000ffff, Read/Write, Accessed
ldtr:0x0000, dh=0x00008200, dl=0x0000ffff, valid=1
tr:0x0000, dh=0x00008b00, dl=0x0000ffff, valid=1
gdtr:base=0x00000000000fa1b7, limit=0x30
idtr:base=0x0000000000000000, limit=0x3ff
<bochs:7> n
Next at t=14040385
(0) [0x000000007c0b] 07c0:000b (unk. ctxt): mov ds, ax                ; 8ed8
<bochs:8> n
Next at t=14040386
(0) [0x000000007c0d] 07c0:000d (unk. ctxt): mov es, ax                ; 8ec0
<bochs:9>
Next at t=14040387
(0) [0x000000007c0f] 07c0:000f (unk. ctxt): mov fs, ax                ; 8ee0
<bochs:10>
Next at t=14040388
(0) [0x000000007c11] 07c0:0011 (unk. ctxt): mov gs, ax                ; 8ee8
<bochs:11>
Next at t=14040389
(0) [0x000000007c13] 07c0:0013 (unk. ctxt): mov ax, 0x0027            ; b82700
<bochs:12> x/20xh 0x7c27   # 这个就是hello world
[bochs]:
0x0000000000007c27 <bogus+       0>:    0x6568  0x6c6c  0x206f  0x6f77  0x6c72  0x0064  0x0000  0x0000
```



第一个程序用的是AT&T的语法，与intel语法相比，简单区别

AT&T语法：立即数用%号开头，寄存器用%开头，movw %ax， %ds表示%ax(源操作数)的内容复制到%ds(目的操作数)。

intel语法：mov 目的操作数，源操作数


扩展：

> 汇编的后缀名一般是.s和.S
> 小写.s：表示改汇编程序只含汇编代码，编译器不会进行预编译
> 大写.S：表示含预编译代码，希望编译器进行预编译（宏替换）