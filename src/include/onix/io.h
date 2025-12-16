#ifndef ONIX_IO_H
#define ONIX_IO_H

#include <onix/types.h>

u8 inb(u16 port);    // 输入一个字节
u16 inw(u16 port);   // 输入一个字

void outb(u16 port, u8 data);  // 输出一个字节
void outw(u16 port, u16 data); // 输出一个字


#endif
