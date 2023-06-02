# Linux shell
## linux命令
### awk统计命令
$0则表示所有域,$1表示第一个域，$n表示第n个域。默认域分隔符是"空白键" 或 "[tab]键
```shell
cat userinfo | awk -F ':' '{print $1}'rootdaemonbinsys
```

## shell脚本
### if 条件判断
```shell

-e : 检查文件名是否存在，只要同名的文件或文件夹都返回true。 To check if the file name exists
-f : 检查文件是否存在，如果不是文件返回false。 To check if a file exists
-d : 判断目录是否存在
-n : 判断字符串非空， 例子 -n "${TEST}"
```
## linux函数
### 文件操作函数
| 类别 | 函数 | 说明 |
| ---- | ---- | ---- |
| 打开 | FILE *f = fopen(filename, "r") | 打开文件, 模式:"r" "w" "rw" "a"|
| 关闭 | fclose(f) | 关闭文件 |
| 读块 | fread(buf[64], sizeof(int), 64 / sizeof(int), f) | 读取文件中一块数据, 按sizeof(char)单位读，共读入64 / sizeof(char)个单位，总共64字节 |
| 写块 | fwrite() | 写入一块数据到文件中 |
| 格式化读 | fscanf | 格式化读取文件数据到内存 |
| 格式化写 | fprintf(f, "test %s, %d", buf, a) | 格式化写入数据到文件中 |
| 写字符 | fputc | 向文件流写入一字节数据 |
| 读字符 | fgetc | 读取文件一字节数据 |
| 写一行 | fputs | 写文件流写入一行数据 |
| 读一行 | ffgets | 文件流读一行数据 |
| 文件指针 | feof | 测试给定流 stream 的文件结束标识符 |
| 文件指针 | fflush | 刷新流 stream 的输出缓冲区 |
| 文件指针 | fseek | 设置流 stream 的文件位置为给定的偏移 offset，参数 offset 意味着从给定的 whence 位置查找的字节数 |
| 文件删 | remove | 删除给定的文件名 filename，以便它不再被访问 |
| 重命名 | rename | 重名给定的文件 |

```c
// fopen
函数名:FILE *fopen( const char *filename, const char *mode );
函数功能:打开文件,并返回文件句柄
函数参数:
    const char *filename ： 文件路径
    const char *mode : 打开模式 
                w-> 创建,并可写 , 
                r->只读 ,
                r+->可读可写,
                a->追加,
                b->二进制
   例如:"rb", "wb", "ab", "rb+", "r+b", "wb+", "w+b", "ab+", "a+b"
函数返回值:
    成功: 非NULL地址  
    失败: NULL
说明: FILE 文件流结构体(称之句柄)
r	打开一个已有的文本文件，允许读取文件。
w	打开一个文本文件，允许写入文件。如果文件不存在，则会创建一个新文件。在这里，您的程序会从文件的开头写入内容。如果文件存在，则该会被截断为零长度，重新写入。
a	打开一个文本文件，以追加模式写入文件。如果文件不存在，则会创建一个新文件。在这里，您的程序会在已有的文件内容中追加内容。
r+	打开一个文本文件，允许读写文件。
w+	打开一个文本文件，允许读写文件。如果文件已存在，则文件会被截断为零长度，如果文件不存在，则会创建一个新文件。
a+	打开一个文本文件，允许读写文件。如果文件不存在，则会创建一个新文件。读取会从文件的开头开始，写入则只能是追加模式

// fclose
函数名:int fclose( FILE *fp );
函数功能:关闭文件流对象(文件句柄)
函数参数:
    FILE *fp ： 文件句柄
函数返回值: 0
// fprintf
函数名:int fprintf(FILE *stream, const char *format, ...)
函数功能:格式化输出数据到文件中
函数参数:
    FILE *stream ： 文件句柄
    const char *format ： 控制符
    ...             对应参数
函数返回值: 
    如果成功，则返回写入的字符总数，否则返回一个负数

// fscanf
函数名:int fscanf(FILE *stream, const char *format, ...)
函数功能:格式化将文件数据读取内存
函数参数:
    FILE *stream ： 文件句柄
    const char *format ： 控制符
    ...             对应参数
函数返回值: 
    如果成功，则返回写入的字符总数，否则返回一个负数

// fwrite
函数名:size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream)
函数功能:将数据以二进制块的方式写入到文件
函数参数:
    const void *ptr :   数据块的首地址
    size_t size :   块的大小
    size_t nmemb:   块的个数
    FILE *stream:   文件句柄
函数返回值: 
    如果成功，该函数返回一个 size_t 对象，表示元素的总数
// fread
函数名:size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream)
函数功能:将文件内容以二进制块的方式读取到pti指向内存中
函数参数:
    void *ptr : 数据块的首地址
    size_t size :   块的大小
    size_t nmemb:   块的个数
    FILE *stream:   文件句柄
函数返回值: 
    如果成功，该函数返回一个 size_t 对象，表示元素的总数
// feof
函数名:int feof(FILE *stream)
函数功能:测试给定流 stream 的文件结束标识符
函数参数:
    stream : 这是指向 FILE 对象的指针，该 FILE 对象标识了流
函数返回值: 
    当设置了与流关联的文件结束标识符时，该函数返回一个非零值，否则返回零
    没到末尾:0
    到达末尾:1
// fseek
函数名:int fseek(FILE *stream, long int offset, int whence)
函数功能:设置流 stream 的文件位置为给定的偏移 offset，参数 offset 意味着从给定的 whence 位置查找的字节数
函数参数:
    stream -- 这是指向 FILE 对象的指针，该 FILE 对象标识了流。
    offset -- 这是相对 whence 的偏移量，以字节为单位。
    whence -- 这是表示开始添加偏移 offset 的位置。它一般指定为下列常量之一，有以下常量
      SEEK_SET	文件的开头
      SEEK_CUR	文件指针的当前位置
      SEEK_END	文件的末尾
函数返回值: 
    如果成功，则该函数返回零，否则返回非零值。
// fputc
函数名:int fputc(int c, FILE *stream)
函数功能:把参数 char 指定的字符（一个无符号字符）写入到指定的流 stream 中，并把位置标识符往前移动。
函数参数:
    int c : 要写入的字符
    FILE *stream:文件流(文件句柄)
函数返回值: 如果没有发生错误，则返回被写入的字符。如果发生错误，则返回 EOF，并设置错误标识符。
// fgetc
函数名:int fgetc(FILE *stream)
函数功能:从指定的流 stream 获取下一个字符（一个无符号字符），并把位置标识符往前移动
函数参数:
    FILE *stream:文件流(文件句柄)
函数返回值: 
    成功读取的字符
// fputs
函数名:int fputs(const char *str, FILE *stream)
函数功能:把字符串写入到指定的流 stream 中，但不包括空字符
函数参数:
    const char *str:要写入的字符串
    FILE *stream:文件流(文件句柄)
函数返回值: 
    该函数返回一个非负值，如果发生错误则返回 EOF。
注意:不会自动在末尾加上一个 换行'\n'
// fgets
函数名:char *fgets(char *str, int n, FILE *stream)
函数功能:从指定的流 stream 读取一行，并把它存储在 str 所指向的字符串内。当读取 (n-1) 个字符时，或者读取到换行符时，或者到达文件末尾时，它会停止，具体视情况而定
函数参数:
    char *str:存放读取上来的内容空间首地址
    int n:要读取的字节数
    FILE *stream:文件流(文件句柄)
函数返回值: 
    如果成功，该函数返回相同的 str 参数。如果到达文件末尾或者没有读取到任何字符，str 的内容保持不变，并返回一个NULL。
    如果发生错误，返回一个NULL。
注意:fgets会去读换行符

// remove
函数名:int remove(const char *filename)
函数功能:删除指定文件(既可以删除“空”目录文件,也删除普通文件)
函数参数:
    const char *filename : 要删除的文件名称
函数返回值: 
    如果成功，则返回零。如果错误，则返回 -1，并设置 errno。
// rename
函数名:int rename(const char *old_filename, const char *new_filename)
函数功能:把 old_filename 所指向的文件名改为 new_filename
函数参数:
    old_filename : 这是 C 字符串，包含了要被重命名/移动的文件名称。
    new_filename : 这是 C 字符串，包含了文件的新名称。
函数返回值: 
    如果成功，则返回零。如果错误，则返回 -1，并设置 errno。
```

## linux内存
### 程序二进制内存分布
在linux里，可用size命令查看一个二进制的内存分布
```shell
size ./output/bin/lexer_bin
   text    data     bss     dec     hex filename
  54331    1288       8   55627    d94b ./output/bin/lexer_bin
# 总的55627字节
```
一个二进制文件，有代码段（存指令）、数据段（全局变量）、bss段（未赋值的全局变量），堆栈段（stack）则在运行时创建。
- BBS段（Block Started by Symbol）：存放未初始化的全局变量，体现为一个占位符，只记录所需空间大小，不分配实际空间，所以.bss段不占用二进制文件空间，由OS分配及初始化。
- 数据段：程序中已初始化的全局变量，属于静态内存分配。占用二进制文件大小，由程序初始化。
- 代码段：存放可执行代码，在程序运行时已确定
- 堆（heap）：malloc的内存，需开发者手动free。未释放的内存，window在进程退出时由os释放，Linux只在整个系统关闭时才由os释放。
- 栈（stack）：堆栈，运行时存放临时局部变量，如函数内非static变量，由os运行时管理，os分配和释放。
### linux运行进程的内存
根据/proc/进程id/smaps里的数据，可将进程内存分为代码段、数据段、堆、共享内存四个部分。


