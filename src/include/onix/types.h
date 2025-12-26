#ifndef ONIX_TYPES_H
#define ONIX_TYPES_H

#define EOF -1  // End of file

#define NULL 0  // 空指针

#define EOS '\0'// End of string

#define bool _Bool
#define true 1
#define false 0

#define _packed __attribute__((packed)) // 不要对结构体进行内存对齐
#define _ofp __attribute__((optimize("omit-frame-pointer"))) // 不要生成帧指针

typedef unsigned int size_t;
typedef char int8;
typedef short int16;
typedef int int32;
typedef long long int64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

#endif