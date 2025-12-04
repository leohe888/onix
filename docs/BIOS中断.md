# BIOS 中断

## int 0x10

- AH = 0x00 —— 设置视频模式。
  - AL = 0x03：80x25 文本模式。

- AH = 0x0e —— 显示字符，并移动光标。
  - AL = 要显示的字符。

## 参考文献

- [BIOS 中断](https://www.ngpaws.com/downloads/dosvault/8086_bios_and_dos_interrupts.html)