/*-------------------------------
| VARIABLES
---------------------------------*/
[PlayerPointer]: 0x8037C8F0

[XPos]: 0x8037CF70

[XVelocity]: 0x8037CE88

[SlopeTimer]: 0x8037CCB4

/*-------------------------------
| Functions
---------------------------------*/
/* 
	NOTE: Consecutive functions identify no unknown functions in between 
	NOTE 2: If inputs or outputs are not listed, assume they are void
*/

[SetFrameSkip]: 0x8024BC00 ;Inputs: (word $a0 input) 
[GetFrameSkip]: 0x8024BC0C ;Outputs: [word $v0] //normally 2 but sometimes 3 eg. GV lobby

[GetXZVelocity]: 0x802978F8 ;Outputs: [float $f0]

[Print_TotalMenuFont]: 0x802F7A50 ;Inputs: (word $a0 XPos), (word $a1 YPos), (word $a3 fontSize), (char* $a3 str)      

[Print_CharFont]: 0x802F7ADC ;Inputs: (word $a0 XPos), (word $a1 YPos), (char* $a2 str)

[SpawnActor]: 0x80328594 ;Inputs: (word $a0 ActorIndex), (float* $a1 LocationXPtr), (??? $a2 ???)

[FToA]: 0x8033DC00 ;Inputs: (char* $a0 destinationStr), (float $a1 inputFloat), (int $a2 float precision) //appends to destination string
[IToA_10]: 0x8033DCD4 ;Inputs: (char* $a0 destinationStr), (word $a1 inputInt) //base 10
[IToA]: 0x8033DCF4 ;Inputs: (char* $a0 destinationStr), (word $a1 inputInt), (word $a2 Radix)

[CopyString]: 0x8033DEA4 ;Inputs: (char* $a0 destinationStr), (char* $a1 srcStr)
[GetStringSize]: 0x8033DED0 ;Inputs: (char* $a0 string)
							;Outputs: [word $v0]
