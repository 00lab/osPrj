# 通用资料



## 汇编语法 AT&T

### intel汇编与AT&T汇编

x86 汇编指令的两大风格，Intel 汇编、AT&T 汇编。常见的汇编编译器有以下所列（参考其他博文）：

-  Intel 汇编语法
  - Linux 下的能产生 16 位代码的 as86 汇编器，使用配套的 ld86 链接器
  - 微软汇编器（MASM）
  - Netwide汇编器（NASM）
  - Borland的Turbo汇编器（TASM）
-  AT&T 汇编语法
  - Linux 下 GNU 的 汇编器 gas（as），使用 GNU ld 链接器来连接产生的目标文件
  - 目前gcc的gas（GNU assembler），和llvm的汇编器，默认产生的文本形式的汇编指令都是AT&T语法的
    简单对比：

intel: mov 目的操作数 源操作数，mov eax, 1表示eax=1，注释用;号

AT&T: AT&T 中寄存器有前缀 %，立即数有前缀 $，mov 源操作数 目的操作数 ，注释用#号

| Intel 汇编语法   | AT&T 汇编语法     |
| ------------ | ------------- |
| mov eax, 1   | movl $1, %eax |
| mov ebx, eax | movl $0, %ebx |
| int 80h      | int $0x80     |

### AT&T语法
#### 跳转指令

cmp %r10,%r11 // 比较r10 和 r11，根据比较结果来设置CPU的状态寄存器，从而影响后面的jump语句；
cmp $99,%r11 // 比较99和r11，根据比较结果来设置CPU的状态寄存器，从而影响后面的jump语句；
jmp label //跳转到label
je label //如果相等，跳转到label
jne label // 如果不相等，跳转到label
jl label // 如果小于，跳转到label
jg label // 如果大于，跳转到label
call label // 调用函数
ret // 从函数调用返回
syscall //系统调用 (32位模式下, 使用"int $0x80" 软中断)

#### 汇编指示符assembler directive

汇编指示符都由句号（'.'）开头。命令名的其余是字母,通常使用小写。

**1，.byte 表达式（expression_rs）**

.byte可不带参数或者带多个表达式参数，表达式之间由逗点分隔。每个表达式参数都被汇编成下一个字节。在stage1.s中，有这么一段代码：

```
after_BPB:
CLI
.byte 0x80,0xca
```

那么编译器在编译时，就会在cli指令的下面接着放上0x80和0xca，因为每个表达式要占用1个字节，所以此处一共占用2个字节。

**2，.word 表达式**

这个表达式表示任意一节中的一个或多个表达式（同样用逗号分开），表达式占一个字（两个字节）。类似的还有.long。例：

```
.word 0x800
```

**3，.file 字符（string）**

.file 通告编译器我们准备开启一个新的逻辑文件。 string 是新文件名。总的来说，文件名是否使用引号‘"’都可以；但如果您希望规定一个空文件名时，必须使用引号""。本语句将来可能不再使用—允许使用它只是为了与旧版本的as编译器程序兼容。在as的一些配置中，已经删除了.file以避免与其它的汇编器冲突。例如stage1.s中：

```
.file ”stage1.s”
```

**4，.text 小节（subsection）**

通知as编译器把后续语句汇编到编号为subsection的正文子段的末尾，subsection是一个纯粹的表达式。如果省略了参数subsection，则使用编号为0的子段。例：

```
.text
```

**5，.code16**

告诉编译器生成16位的指令

**6，.globl**

.globl使得连接程序（ld）能够看到symbol，如果gemfield在局部程序中定义了symbol，那么与这个局部程序链接的局部程序也能存取symbol，例：

```
.globl SYMBOL_NAME(idt) 
```

定义idt为全局符号。

**7，.fill repeat , size , value**

repeat, size 和value都必须是纯粹的表达式。本命令生成size个字节的repeat个副本。Repeat可以是0或更大的值。Size 可以是0或更大的值, 但即使size大于8,也被视作8，以兼容其它的汇编器。各个副本中的内容取自一个8字节长的数。最高4个字节为零，最低的4个字节是value，它以as正在汇编的目标计算机的整数字节顺序排列。每个副本中的size个字节都取值于这个数最低的size个字节。再次说明，这个古怪的动作只是为了兼容其他的汇编器。size参数和value参数是可选的。如果不存在第2个逗号和value参数，则假定value为零。如果不存在第1个逗号和其后的参数，则假定size为1。

例如，在linux初始化的过程中，对全局描述符表GDT进行设置的最后一句为：

```
.fill NR_CPUS*4,8,0
```

意思是.fill给每个cpu留有存放4个描述符的位置，并且每个描述符是8个字节。不过要注意的是，这种包含程序已初始化数据的节（.data）和包含程序程序还未初始化的数据的节（.bss），编译器会把它们在4字节上对齐，例如，.data是25字节，那么编译器会将它放在28个字节上。当这种以后缀名.s编写的A T&T格式的汇编代码完成后，就是编译和链接了。

## x86 寄存器

寄存器分类

1. 16 位
  自 Intel 8086和 8088 起，有 14 个 16 比特寄存器（AX、BX、CX、DX、SI、DI、SP、BP、IP、CS、SS、DS、ES、PSW）。

- 四个（AX, BX, CX, DX）是通用寄存器，每个寄存器可被当成两个分开的字节访问（因此 BX 的高比特可以被当成 BH，低比特则可以当成 BL）。
- 四个段寄存器（CS、DS、SS、ES）。用于产生存储器的绝对地址。
- 两个指针寄存器（SP指向堆栈底部，BP可指向堆栈或存储器的其它地方）。
- 两个指针寄存器（SI和DI），可指向数组的内部。
- 标志寄存器（含进位、溢出、结果为零等状态标志）。
- IP 用来指向目前执行指令的偏移地址。

2. 32位

Intel 80386 后，四个通用寄存器（EAX, EBX, ECX, EDX），它们较低的 16 位分别与原本 16 位的通用寄存器（AX, BX, CX, DX）重叠共享。指针寄存器（EIP, EBP, ESP, ESI, EDI）、区段寄存器除了原本的（CS、DS、SS、ES），另外新增（FS、GS），但是区段寄存器在 32 位模式下改做为存储器区块的选择子寄存器。标志寄存器被扩展为 32 位，较低的 16 位与原本在 16 位下的标志寄存器重叠共享。
3. 64位
  MMX 寄存器（MM0～MM7），分别与浮点运算器〈FP0～FP7〉相重叠，所以 MMX 与浮点运算不可同时使用，必须透过切换选择要使用哪一种。
4. AMD64
  AMD 自行把 32 位 x86（或称为 IA-32）拓展为 64 位，并命名为x86-64 或 Hammer 架构，而后更名为 AMD64 架构。由于 AMD 的 64 位处理器产品线首先进入市场，且微软也不愿意为 Intel 代号为 Yamhill 的 64 位版 x86 处理器开发第三个不同的 64 位操作系统，Intel 被迫采纳 AMD64 架构且增加某些新的扩展到他们自己的产品，命名为 EM64T 架构，EM64T 后来被 Intel 正式更名为 Intel 64。
  这个架构也被称为 64 位拓展架构，即 x64，四个通用寄存器（RAX, RBX, RCX, RDX）是由 32 位的（EAX, EBX, ECX, EDX）64 位扩展而来，指针寄存器（RIP, RBP, RSP, RSI, RDI）也扩展了 ，增加八个通用寄存器（R8～R15）。 这些资源只可在 x64 处理器的 64 位模式下使用，在用来支持 x86 软件的遗留模式和兼容模式中不可见。


# 共享文件夹，交叉开发
https://www.cnblogs.com/UFO-blogs/p/17426478.html

# VmWare安装共享目录工具

选择菜单栏：虚拟机-->（重新）安装VmWare Tools，这是一个共享工具，点后会在虚拟机下方弹出：

.... 在客户机中装载虚拟CD驱动器，启动终端，解压后使用vmware-install.pl安装....



首先挂载cdrom

```shell
sudo mkdir /mnt/cdrom
sudo mount /dev/cdrom /mnt/cdrom
```

挂载成功后

```shell
$ ls /mnt/cdrom/
manifest.txt  run_upgrader.sh  VMwareTools-9.9.0-2304977.tar.gz  vmware-tools-upgrader-32  vmware-tools-upgrader-64
tar -xvf /mnt/cdrom/VMwareTools-9.9.0-2304977.tar.gz
# 解压到当前目录
cd /home/test/vmware-tools-distrib
./vmware-install.pl
#安装
The configuration of VMware Tools 9.9.0 build-2304977 for Linux for this
running kernel completed successfully.

You must restart your X session before any mouse or graphics changes take
effect.

You can now run VMware Tools by invoking "/usr/bin/vmware-toolbox-cmd" from the
command line.

To enable advanced X features (e.g., guest resolution fit, drag and drop, and
file and text copy/paste), you will need to do one (or more) of the following:
1. Manually start /usr/bin/vmware-user
2. Log out and log back into your desktop session; and,
3. Restart your X session.

```

显示最后内容便安装成功了