void kmain()
{
    *(char*)0xb8000 = 'W';
    *(char*)0xb8001 = 1;
    while(1) {}
}