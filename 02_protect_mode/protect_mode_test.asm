# 编译方法as -msyntax=intel -mnaked-reg -o protect_mode_test.o protect_mode_test.S
%include " pm.inc"

org 0x7c00
    jmp LABEL_CODE16

; GDT（Global Descriptor Table）
; 保护模式下，地址依然是“段:偏移”，段值仍然由原来16位的cs、ds等寄存器表示，
; 但此时它仅仅变成了一个索引，该索引指向一个数据结构的一个表项，表项中详细定义了
; 段的起始地址、界限、属性等内容
; GDT的作用是用来提供段式存储机制，这种机制是通过段寄存器和GDT中的描述符共同提供
[SECTION .gdt]
;GDT:              段基址,        段界限,           属性
LABEL_GDT:         Descriptor 0,  0,               0  ;空描述符
;定义在pm.inc宏：DA_C		EQU	98h	; 存在的只执行代码段属性值
;定义在pm.inc宏：DA_32		EQU	4000h	; 32 位段
LABEL_DESC_CODE32: Descriptor 0,  SegCode32Len - 1, DA_C + DA_32 ; 非一致代码段,98h+4000h
LABEL_DESC_VIDEO:  Descriptor 0B800h, 0ffffh, DA_DRW ;  显存首地址

; 扩展，$$表示一个节（section）的开始处被汇编后的地址，$-$$常用于表示本行距离程序开始处的相对距离
GdtLen equ $ - LABEL_GDT ; $表示当前行被汇编后的地址，这行表示GdtLen=GDT长度
GdtPtr dw GdtLen - 1 ; GDT界限
       dd 0          ; GDT基地址

; GDT选择子
SelectorCode32 equ LABEL_DESC_CODE32 - LABEL_GDT
SelectorVideo  equ LABEL_DESC_VIDEO  - LABEL_GDT

LABEL_CODE16:
    mov ax, cs

LABEL_SEG_CODE32:
    mov ax

; 
SegCode32Len equ $ - LABEL_SEG_CODE32