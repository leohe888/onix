void console_init();
void gdt_init();
void interrupt_init();
void clock_init();
void hang();

void kernel_init()
{
    console_init();
    gdt_init();
    interrupt_init();
    // task_init();
    clock_init();

    asm volatile("sti");
    hang();
}
