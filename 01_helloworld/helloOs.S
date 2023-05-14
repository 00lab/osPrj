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
