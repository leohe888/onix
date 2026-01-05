void console_init();
void gdt_init();
void interrupt_init();
void clock_init();
void time_init();
void rtc_init();
void hang();

void kernel_init()
{
    console_init();
    gdt_init();
    interrupt_init();
    clock_init();
    time_init();
    rtc_init();
    set_alarm(2);

    // task_init();

    asm volatile("sti");
    hang();
}
