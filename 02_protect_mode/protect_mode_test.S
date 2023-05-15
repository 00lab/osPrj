# 编译方法as -msyntax=intel -mnaked-reg -o protect_mode_test.o protect_mode_test.S
%include " pm.inc"

org 0x7c00
    jmp LABEL_BEGIN

LABEL_BEGIN:
    mov ax, cs
