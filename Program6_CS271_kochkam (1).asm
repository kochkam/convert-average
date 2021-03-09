TITLE Program 6     (Program6_CS271_kochkam.asm)
;-------------------------------------------------------------------------------------------
; Author: Michael Kochka
; Last Modified: 6/6/2020
; OSU email address: kochkam@oregonstate.edu
; Course number/section: 271_400
; Project Number: 6                 Due Date: 6/7/2020
; Description:The following program prompts a user for 10 intergers and validates the input.
; Input must fit in a 32-bit register otherwise an error message will appear and user will
; be repromted for another integer. Error message will appear if any non valid data is 
; entered. The program will convert the string of integers entered into a number and then
; calculate the sum and average of the numbers entered. The program will then convert the
; numbers back into a string and then display those numbers, the average and sum as a string.
;-------------------------------------------------------------------------------------------

INCLUDE Irvine32.inc

;-------------------------------------------------------------------------------------------
; Constants & Symbols: Define Constants & Symbols
;-------------------------------------------------------------------------------------------

lengthString EQU DWORD PTR [ebp-4]

counter      EQU DWORD PTR [ebp-8]

digit        EQU DWORD PTR [ebp - 12]

sum          EQU DWORD PTR [ebp -16]

multiplier   EQU DWORD PTR [ebp -20]

sign         EQU DWORD PTR [ebp - 24]

average      EQU DWORD PTR [ebp - 28]

newPointer   EQU DWORD PTR [ebp - 32]

ARRAYSIZE = 10

.data
;-------------------------------------------------------------------------------------------
; Define Variables: 
;-------------------------------------------------------------------------------------------

arrayS      BYTE    120         DUP (?) 

arrayInts   DWORD   ARRAYSIZE   DUP (?)

arrayCon    DWORD   12          DUP (?)

num_count   DWORD   0

total       DWORD   0

average_ar  DWORD   0

stringSize  DWORD   0

;-------------------------------------------------------------------------------------------
; Defines Strings: 
;-------------------------------------------------------------------------------------------
intro_1	    BYTE	"		Program 6		By: Michael Kochka",0

intro_2     BYTE    "Welcome to the Average and Sum calculator Program!",0

extra_cred  BYTE    "**EC: DESCRIPTION: number each line of user input and display a running subtotal of the user's numbers.",0

inst_1      BYTE    "Please provide 10 signed decimal integers. Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",0

dis_num     BYTE    "Please enter an signed number: ",0

error       BYTE    "ERROR: You did not enter a signed number or your number was too big.",0

try_again   BYTE    "Please try again: ",0

dis_numbers BYTE    "You entered the following numbers: ",0

dis_sum     BYTE    "The sum of these numbers is: ",0

dis_avg     BYTE    "The rounded average is: ",0

bye         BYTE    "Thanks for coming. HAGS!",0

string      BYTE    12 DUP(0)

altString   BYTE    12 DUP(0)

spacing     BYTE    ". ",0

spaces      BYTE    ", ",0

;-------------------------------------------------------------------------------------------
displayString MACRO buffer:REQ
;
; Writes a string variable to standard output.
; Receives: OFFSET of a string variable name.
; Returns: None
;-------------------------------------------------------------------------------------------
     push  edx
     mov   edx, buffer
     call  WriteString
     pop   edx
ENDM


;-------------------------------------------------------------------------------------------
getString MACRO var:REQ, size:REQ
;
; Reads in a string variable to input.
; Receives: OFFSET of string variable name.
; Returns: None
;-------------------------------------------------------------------------------------------
     push  edx
     push  ecx
     mov   edx, var
     mov   ecx, size
     call  ReadString
     call  CrLf
     pop   ecx
     pop   edx
ENDM


;-------------------------------------------------------------------------------------------
; Main: Main calls the procedures used within the program and pushses/passes variables used in 
; each procedure on the stack
;-------------------------------------------------------------------------------------------
.code
   main PROC

   push             OFFSET intro_1
   push             OFFSET intro_2
   push             OFFSET extra_cred
   push             OFFSET inst_1
   call             Intro                   ;display intro messages

   push             OFFSET arrayInts
   push             OFFSET error
   push             OFFSET spacing
   push             num_count
   push             OFFSET arrayS
   push             OFFSET dis_num
   push             OFFSET string
   push             SIZEOF string
   call             readVal                 ;read in values


   mov              eax, OFFSET string
   add              eax, SIZEOF string      ;find the end of the string and subtract one to leave room for null terminator (used for filling an empty string)
   sub              eax, 1
   mov              stringSize, eax

   push             OFFSET dis_sum
   push             OFFSET dis_avg
   push             OFFSET dis_numbers
   push             OFFSET spaces
   push             OFFSET string
   push             stringSize
   push             SIZEOF arrayInts
   push             average_ar
   push             total
   push             OFFSET dis_avg
   push             OFFSET arrayInts
   call             writeVal                ;write values, average and sum to display for user

   call             CrLf
   call             CrLf
   displayString    OFFSET bye              ;display goodbye message


endOfProgram:
   exit
main ENDP


;-------------------------------------------------------------------------------------------
; Intro:  Displays the introductory messages of the program and uses the displayString macro.
; receives:intro_1(ref), intro_2(ref), extra_cred(ref), inst_1(ref)
; returns: none
; preconditions:  parameters must be passed in the following order intro_1(ref), intro_2(ref), 
; extra_cred(ref), inst_1(ref)
; registers changed: none
;-------------------------------------------------------------------------------------------
 Intro  PROC
    Enter             0,0
    displayString     [ebp + 20]
    call              CrLf
    call              CrLf
    displayString     [ebp + 16]
    call              CrLf
    call              CrLf
    displayString     [ebp + 12]
    call              CrLf
    call              CrLf
    displayString     [ebp + 8]
    call              CrLf
    call              CrLf
    Leave
    Ret               16

Intro   ENDP
;-------------------------------------------------------------------------------------------
; readVal:  invoke the getString macro to get the user’s string of digits. It then
; converts the digit string to numeric, while validating the user’s input.
; receives:extra_cred1(ref), intro_1(ref), intro_2(ref), extra_cred(ref),ins_1(ref)
; returns: none
; preconditions:  parameters must be passed in the following order  extra_cred1(ref), intro_1(ref), 
; registers changed: edx, ebp
; *EC:  number each line of user input and display a running subtotal of the user’s numbers. 
;-------------------------------------------------------------------------------------------
readVal PROC

    Enter           28,0
    mov             ecx, 10            
    mov             edi, [ebp + 20]    ;string to prompt user to enter a number
    mov             ebx, [ebp + 24]    ;counter variable num_count for tracking numbers entered
    mov             edx, [ebp + 36]    ;holds arrayInts 
    push            edx
    mov             edx, 0
    JMP             ReadValues
;-------------------------------------------------------------------------------------------
;Description: Sign variable will be applied to the final sum of the converted string 
; to convert it to a negative or positive value depending on the value of sign.
;-------------------------------------------------------------------------------------------

NewString:
    mov             eax, sign
    cmp             eax, -1
    JE              negative
    cmp             eax, +1
    JE              positive
negative:
    mov             eax, sum
    mov             eax, -1
    IMUL            eax, sum
    JMP             StoreInt
positive:
    mov             eax, +1
    IMUL            eax, sum
;-------------------------------------------------------------------------------------------
;Description: Store the converted string (now integer) into an array
;-------------------------------------------------------------------------------------------
        
StoreInt:
    JO              wrong                     ;Do a final check to make sure overflow or carry does not occur during multiplication
    JC              wrong
    cmp             eax, 2147483647
    JG              wrong
    cmp             eax, -2147483647
    JL              wrong
    mov             sum, eax
    pop             edx                       ;pop the array into the register that ints will be stored in
    push            edi
    mov             edi, edx
    mov             eax, sum
    mov             [edi], eax
    add             edi, 4
    mov             edx, edi
    pop             edi
    push            edx                       ; save the current location pointed to in array
    cmp             ecx, 0                    ;check if last  
    JE              bottom

;-------------------------------------------------------------------------------------------
;Description: Prompt user for integer and getString from user. Get character from string
;using lodsb and covert from from character into int. 
;-------------------------------------------------------------------------------------------


ReadValues:
    inc             ebx                       ;tracks how many numbers the user has entered and display to user
TryAgain:
    displayString   [ebp + 16]                ;display message to prompt user for integer
    mov             eax, ebx
    call            CrLf
    call            WriteDec
    mov             edx,[ebp + 28]                      
    call            WriteString               ;Display a period after running total of numbers entered by user.
    getString       [ebp + 12], [ebp + 8]
    CLD
    mov             lengthString, eax
    mov             esi, [ebp + 12]
    mov             counter, 0
    mov             multiplier, 10
    mov             sum, 0
    mov             digit, 0
loopString: 
    LODSB
    cmp             eax, 45                   ;check if bit is a negative or positive sign  if so validate it
    JE              Validate
    cmp             eax, 43
    JE              Validate
    sub             al, 48
    movsx           eax, al
    mov             digit, eax
    JMP             Validate

;-------------------------------------------------------------------------------------------
;Description: Once number is validated multiply sum by 10 and the add the converted int to the sum.
;-------------------------------------------------------------------------------------------

Valid:
    mov             eax, multiplier
    IMUL            eax, sum
    mov             sum, eax
    JO              wrong
    JC              wrong
    mov             eax, digit
    add             sum, eax
    mov             eax, sum

    STOSB
    mov             edx, counter
    inc             edx
    mov             counter, edx
    cmp             edx, lengthString
    JL              loopString
    dec             ecx
    cmp             ecx, 0
    JG              NewString
    JMP             NewString
;-------------------------------------------------------------------------------------------
;Description: This segment validates the string byte once it has been converted from the
; ASCII chart. If the value in digit is less then 0 or greater the 0 it is invalid and
; we jump to the error message.  
;-------------------------------------------------------------------------------------------

Validate:
    mov             edx, 0
    cmp             edx, counter              ;counter tracks where we are at in the string. If its zero we know to check the sign of the number. 
    JE              validateSign                
validateNum:
    mov             eax, digit
    cmp             eax, 0
    JL              wrong
    cmp             al, 9
    JG              wrong
    JMP             Valid
validateSign:
    cmp             eax, 45                  ;Jumps to appropriate sign initalizer based on the string bit in eax
    JE              minus
    cmp             eax, 43
    JE              plus
    JMP             normalInt
;-------------------------------------------------------------------------------------------
;Description: Variable sign is initalized to determine if the byte should be treated as a 
; negative or positive value. The error message is also displayed in the segment. Before
; the string is stored as integer the sign variable will be multiplied by that converted string. 
;-------------------------------------------------------------------------------------------

plus:
    mov             sign, +1
    mov             digit, 0                ; This essentially ignores the first byte in the string if its a sign value and will use the sign variable to track if the string is positive or negative
    mov             edx, 1
    cmp             edx, lengthString       ; throw error if the only thhing entered is a + sign
    JE              wrong
    JMP             Valid

minus:
    mov             sign, -1
    mov             digit, 0
    mov             edx, 1
    cmp             edx, lengthString       ; throw error if the only thhing entered is a - sign
    JE              wrong
    JMP             Valid

wrong:                              
    displayString   [ebp + 32]              ;display error message 
    call            CrLf
    JMP             TryAgain                ;go to rempromt and validate the new integer

normalInt:                                  ;if the string has no positive or negative sign the sign variable defaults to +1
    mov             sign, +1
    JMP             validateNum

bottom:
    Leave
    Ret             28



readVal ENDP

;-------------------------------------------------------------------------------------------
; writeVal: convert a numeric value to a string of digits, and invoke the displayString
; macro to produce the output.
; receives: array(ref), string(ref), var(val), var(val),var(val), var(val), string(ref),string(ref)
; string(ref), string(ref), string(ref)
; returns: none
; preconditions: DWORD array needs to be filled with 10 values that will be converted. 
;-------------------------------------------------------------------------------------------

writeVal PROC
    Enter           28,0
    displayString   [ebp + 40]              ;display string to display numbers 
    call            CrLf
    mov             esi, [ebp + 8]          ;pass array with ints stored in it
    mov             counter, 10
    mov             edi, [ebp + 32]         ;pass offset of string 

;-------------------------------------------------------------------------------------------
; Description: Intialize registers with values passed on stack and pass parameters to 
; convertInt procedure. Get int from array and pass it on stack and iterate through array. 
; Displays newly filled string when convertInt returns. 
;-------------------------------------------------------------------------------------------   
loadInt:
    JMP             createNewString
resume:
    mov             eax, [ebp + 28]         ;pass stringSize which stores the location of the end of the string minus 1
    mov             ebx, [esi]
    add             esi, 4
    push            esi
    push            edi
    push            eax
    push            ebx
    call            convertInt
    displayString   [ebp + 32]              ;Display the convertedInt in a string
    displayString   [ebp + 36]              ;print comma
    dec             counter
    cmp             counter, 1
    JGE             loadInt
    JMP             calcAvgSum
;-------------------------------------------------------------------------------------------
;Description: Clear string of the old value and set every byte to null. 
;-------------------------------------------------------------------------------------------
createNewString:
    push            esi
    push            edi
    push            ecx
    mov             edi, [ebp + 32]          ;put offset of string in edi
    mov             ecx, 12
    mov             al, 0
    cld
    rep             stosb
    pop             ecx
    pop             edi
    pop             esi
    JMP             resume
;-------------------------------------------------------------------------------------------
;Description: calculate the average and sum of integers entered by user
;-------------------------------------------------------------------------------------------
calcAvgSum:
    mov             ecx, [ebp + 24]         ;displays message to display average 
    mov             eax, [ebp + 20]         ;average variable
    mov             ebx, [ebp + 16]         ;total variable
    mov             edx, [ebp + 12]         ;dis average
    mov             esi, [ebp + 8]          ;offset of arrayInts
    push            eax
    push            ebx
    push            esi
    call            calculateAvgSum
    push            eax                     ;save sum  and push it on stack
    mov             eax, ebx                ;instialize average from procedure

;-------------------------------------------------------------------------------------------
;Description: Display average
;-------------------------------------------------------------------------------------------

displayAvg:
    call            CrLf
    displayString   [ebp + 44]               ;display average message
    call            CrLf
    mov             eax, eax                 ;average 
    mov             edi, [ebp + 32]          ;offset of string
    mov             ebx, [ebp + 28]          ;string size 
    push            edi
    push            ebx
    push            eax
    call            convertInt
    displayString   [ebp + 32]              ;display average
;-------------------------------------------------------------------------------------------
;Description: Display Sum
;-------------------------------------------------------------------------------------------

displaySum:
    call            CrLf
    displayString   [ebp + 48]              ;display sum message
    call            CrLf
    pop             eax                     ;sum
    mov             edi, [ebp + 32]         ;offset of string
    mov             ebx, [ebp + 28]         ;string size 
    push            edi
    push            ebx
    push            eax
    call            convertInt
    displayString   [ebp + 32]

adios:
    pop             ebx
    pop             ecx
    Leave
    Ret             44


writeVal ENDP

;-------------------------------------------------------------------------------------------
; convertInt: converts an integer into a string 
; receives: var(val), string(ref), var(val)
; returns: none (string is filled with new data)
; preconditions:  must be passed a value to be converted and an empty string to fill 
; registers changed: edx, ebp
;-------------------------------------------------------------------------------------------

convertInt PROC
    Enter           28,0

    push            eax
    push            ecx
    push            ebx
    push            esi
    push            edi

    mov             counter, 0
    mov             eax, [ebp + 8]
    mov             ecx, [ebp + 12]
    mov             ebx, 10
    push            ecx                     ;points to end of string
    push            edi                     ;push offset of string
    push            eax                     ;push number to covert
    call            checkNegative            
    add             counter, esi
    mov             digit ,eax
    JMP             calculateArray
;-------------------------------------------------------------------------------------------
; Description: Intialize registers adds number of digits in int to ecx to have pointer point
; to correct location in string
;-------------------------------------------------------------------------------------------

initializeReg:
    mov             ecx, edi                ;offset of string
    add             ecx, counter
    mov             eax, digit
    mov             edi, [ebp + 16]
    mov             ebx,  10
;-------------------------------------------------------------------------------------------
;Description: Convert integer back to ASCII char. Fill string in reverse
;-------------------------------------------------------------------------------------------

convert:
    xor             edx, edx
    idiv            ebx
    add             edx, 48
    mov             BYTE PTR [ecx], dl      ;Sources Cited: http://masm32.com/board/index.php?topic=5195.0 By: Vortex Date: 6/4/2020
    dec             ecx
    test            eax, eax
    JE              goodbye
    JMP             convert
;-------------------------------------------------------------------------------------------
;Description: Calculate how many decimal places/digits are in integer.
;-------------------------------------------------------------------------------------------

calculateArray:
    xor             edx, edx
    idiv            ebx
    add             edx, 48
    test            eax, eax
    JE              initializeReg
    inc             counter
    JMP             calculateArray 
    
goodbye:
    mov             ecx, [ebp + 12]
    pop             esi
    pop             ebx
    pop             ecx
    pop             eax

    Leave
    Ret             12
convertInt ENDP

;-------------------------------------------------------------------------------------------
; checkNegative: calculate the average and sum of integers in the array
; receives: var(ref), string(ref), var(val)
; returns: ecx(string pointer location), eax (value of int being checked), esi (counter)
; preconditions:  must be passed a negative or positive value to be checked 
; registers changed: ebx, edx, esi, eax, ecx
;-------------------------------------------------------------------------------------------
checkNegative PROC

    Enter       0,0
    push        ebx
    push        edx
    mov         ebx, 0
    xor         edx, edx
    xor         esi, esi
    mov         eax, [ebp + 8]
    cmp         eax, 2147483647     ; skip edge cases 
    JE          dunzo
    cmp         eax, 0
    JE          dunzo
    not         eax
    mov         ecx, [ebp + 16]
    add         eax, 1
    JNS         writeNeg            
    mov         eax, [ebp + 8]
    JMP         dunzo


writeNeg: 
   mov         esi, 1
   mov         eax, [ebp + 8]
   not         eax                  ;convert negative to positive
   add         eax, 1
   mov         ebx, [ebp + 12]
   xor         edx, edx
   mov         dl, 45               
   mov         BYTE PTR [ebx], dl   ;fill the first byte in the string 


dunzo:
    pop         edx
    pop         ebx
    Leave       
    Ret         16

checkNegative ENDP


;-------------------------------------------------------------------------------------------
; calculateAvgSum: calculate the average and sum of integers in the array
; receives:var(val), var(val), array(ref)
; returns: eax, ebx (sum, average)
; preconditions:  must be passed an array filled with values to calculate the sum & average 
; registers changed: ecx, esi, eax, ebx
;-------------------------------------------------------------------------------------------
calculateAvgSum PROC
    Enter       28,0
    push        ecx
    push        esi
    mov         ecx, 10
    mov         eax, [ebp + 16]
    mov         ebx, [ebp + 12]
    mov         esi, [ebp +8]
    mov         average, 0
    mov         sum, 0
   

summing:
    mov         eax, [esi]
    add         esi, 4
    add         sum, eax
    mov         eax, sum
    LOOP        summing         ;iterate through loop and sum the array of ints

avg:
    mov         eax, sum
    cdq
    mov         ebx, 10
    idiv        ebx
    mov         average, eax

    mov         eax, sum
    mov         ebx, average

    
    pop         esi
    pop         ecx

    Leave                      ;return eax and ebx with the sum and average values
    Ret        12


calculateAvgSum ENDP

END main
