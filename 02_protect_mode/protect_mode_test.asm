# 编译方法as -msyntax=intel -mnaked-reg -o protect_mode_test.o protect_mode_test.S
%include " pm.inc"

org 0x7c00
    jmp LABEL_CODE16

[SECTION .gdt]
;GDT:          段基址;, 段界限, 属性
LABEL_GDT:  Descriptor 0,  0,  0  ;空描述符
;pm.inc宏：DA_C		EQU	98h	; 存在的只执行代码段属性值
;pm.inc宏：DA_32		EQU	4000h	; 32 位段
LABEL_DESC_CODE32: Descriptor 0, SegCode32Len - 1, DA_C + DA_32; 非一致代码段,98h+4000h
LABEL_DESC_VIDEO: Descriptor 0,

LABEL_CODE16:
    mov ax, cs

LABEL_SEG_CODE32:
    mov ax

; 
SegCode32Len equ $ - LABEL_SEG_CODE32