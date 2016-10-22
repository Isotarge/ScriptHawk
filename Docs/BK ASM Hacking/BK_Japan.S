/*-------------------------------
| VARIABLES
---------------------------------*/
[PlayerPointer]: 0x8037CA20

[XPos]: 0x8037D0A0

[XVelocity]: 0x8037CFB8

[SlopeTimer]: 0x8037CDE4

/*-------------------------------
| Functions
---------------------------------*/
/* 
	NOTE: Consecutive functions identify no unknown functions in between 
	NOTE 2: If inputs or outputs are not listed, assume they are void
*/

[SetFrameSkip]: 0x8024AD18 ;Inputs: (word $a0 input) 
[GetFrameSkip]: 0x8024AD24 ;Outputs: [word $v0] //normally 2 but sometimes 3 eg. GV lobby

[GetXZVelocity]: 0x80296958 ;Outputs: [float $f0]

[Print_TotalMenuFont]: 0x802F6CA4 ;Inputs: (word $a0 XPos), (word $a1 YPos), (word $a3 fontSize), (char* $a3 str)      

[Print_CharFont]: 0x802F6D30 ;Inputs: (word $a0 XPos), (word $a1 YPos), (char* $a2 str)

[SpawnActor]: 0x803285C4 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (??? $a2 ???)

[FToA]: 0x8033DC30 ;Inputs: (char* $a0 destinationStr), (float $a1 inputFloat), (int $a2 float precision) //appends to destination string
[IToA_10]: 0x8033DD04 ;Inputs: (char* $a0 destinationStr), (word $a1 inputInt) //base 10
[IToA]: 0x8033DD24 ;Inputs: (char* $a0 destinationStr), (word $a1 inputInt), (word $a2 Radix)

[CopyString]: 0x8033DED4 ;Inputs: (char* $a0 destinationStr), (char* $a1 srcStr)
[GetStringSize]: 0x8033DF00 ;Inputs: (char* $a0 string)
							;Outputs: [word $v0]
