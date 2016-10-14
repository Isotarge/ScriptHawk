// Hook
.org 0x8024EE90
JAL 0x80400000

[Print]: 0x802F7870
[Return]: 0x8024E420

.org 0x80400000
PUSH ra

// Code goes here

POP ra
J @Return
NOP
