/*-------------------------------
| VARIABLES
---------------------------------*/
[PlayerPointer]:0x8037BF20

[XPos]: 0x8037C5A0

[XVelocity]: 0x8037C4B8

[SlopeTimer]: 0x8037C2E4


/*-------------------------------
| Functions
---------------------------------*/

[ClampInt]: 0x80257EA8 ;Inputs: word $a0 input,
                       ;        word $a1 lowerLimit,
                       ;        word $a2 upperLimit
                       ;Outputs: void

[SelectMaxInt]: 0x8025892C ;Inputs: word $a0 input1,
                           ;        word $a1 input2
                           ;Outputs: word $v0

[SelectMinInt]: 0x80258948 ;Inputs: word $a0 input1,
                           ;        word $a1 input2
                           ;Outputs: word $v0

[GetXZVelocity]: 0x80297AB8 ;Inputs: void
                            ;Outputs: (float) $f0

[Print_TotalMenuFont]: 0x802F7870 ;Inputs: word $a0 XPos,
                                  ;        word $a1 YPos,
                                  ;        word $a3 fontSize,
                                  ;        char* $a3 str
                                  ;Outputs: void

[Print_CharFont]: 0x802F78FC ;Inputs: word $a0 XPos,
                             ;        word $a1 YPos,
                             ;        char* $a2 str
                             ;Outputs: void

[PauseMenu]: 0x80313380 ;Inputs: void
                        ;Outputs: void

[SpawnActor]: 0x8032813C ;Inputs: word $a0 ActorIndex,
                         ;        float* $a1 LocationXPtr,
                         ;        ???    $a2 ???
                         ;Outputs: void

[FToA]: 0x8033D7B0 ;Inputs: char* $a0 destinationStr (appends),
                   ;        float $a1 inputFloat,
                   ;        int $a2 float precision
                   ;Outputs: void


[CopyString]:0x8033DA54 ;Inputs: char* $a0 destinationStr,
                        ;        char* $a1 srcStr
                        ;Outputs: void

[AppendString]:0x8033D670 ;Inputs: char* $a0 destinationStr,
                          ;        char* $a1 srcStr
                          ;Outputs: void