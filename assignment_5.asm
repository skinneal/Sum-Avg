;TITLE Program 5    (assignment_5.asm)

; Author: Allison Skinner
; Last Modified:
; OSU email address: skinneal@oregonstate.edu
; Course number/section: CS271-400
; Assignment Number: #5                Due Date: 8/9/2020
; Description: 
; 1) Implement and test your own ReadVal and WriteVal procedures for unsigned integers.
; 2) Implement macros getString and displayString.
;	2a) getString should display a prompt then get user's input into a mem location.
;	2b) displayString should display the stored string in a specified mem location.
;	2c) readVal should invoke the getString macto to get the user's string.
; Then convert digit string to numeric, while validating user's input.
;	2d) writeVal should convert a numeric value to a string of digits
; and invoke the displayString macro to produce to output
; 3) Write a small test program that gets 10 valid integers from the user
; and store the numeric values in an array.
; The program then displays the integers, their sum, and their average.

INCLUDE Irvine32.inc

; Constants
	MAXINPUT = 10

;----------------------------------------
; MACRO: displayString
; Description: Display the string stored
; in a specific memory location
; Parameters: stringResult
;-----------------------------------------

displayString MACRO stringResult
	push edx
	mov edx, OFFSET stringResult
	call WriteString
	pop edx
ENDM

;----------------------------------------
; MACRO: getString
; Description: Display a prompt for user
; then get uer's input and put into
; a memory location
; Parameters: address, length
;-----------------------------------------

getString MACRO string, length
	push edx
	push ecx
	mov edx, string
	mov ecx, length
	call ReadString
	pop ecx
	pop edx
ENDM

.data

programTitle	BYTE	"Program 5: Low-Level I/O Procedures", 0
programmer		BYTE	"Programmer: Allison Skinner", 0
instructions	BYTE	"Please provide 10 unsigned decimal integers.", 0
instructions2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
instructions3	BYTE	"When you're finished inputting raw numbers, I will display a list", 0
instructions4	BYTE	"of the integers, their sum, and their average.", 0
prompt			BYTE	"Please enter an unsigned number: ", 0
errorMessage	BYTE	"ERROR: You did not enter an unsigner number or your number was too big.", 0
errorMessage2	BYTE	"Please try again. ", 0
goodbye			BYTE	"Thank you. Have a nice day!", 0
inputBuffer		BYTE	200 DUP(0)
temp			BYTE	32 DUP(0)

average		DWORD	?
sum			DWORD	?
array		DWORD MAXINPUT DUP(?)
spacing		BYTE	" , ", 0

youEntered	BYTE	"You entered the following numbers: ", 0
theSum		BYTE	"The sum of the numbers is: ", 0
theAvg		BYTE	"The average is: ", 0

EC1	BYTE	"EXTRA CREDIT: 1. Number each line of user input and display a running subtotal of the user's numbers.", 0
lineNumber	DWORD	?
punct		BYTE	".) ", 0
totalEntered	BYTE	"Total numbers entered: ", 0

.code
main PROC

	;------------------------------------------------------
	; Intro
	;------------------------------------------------------
	call introduction

	; Set up loop controls
	mov edi, OFFSET array
	mov ecx, MAXINPUT

	;------------------------------------------------------
	; userInput
	; Description: Get values from user and display values
	;------------------------------------------------------
	userInput:
		displayString prompt	; macro to display prompt
		push OFFSET inputBuffer	; push address onto stack by reference
		push SIZEOF inputBuffer	; push size onto stack by value
		call ReadVal

		mov eax, DWORD PTR inputBuffer
		mov [edi], eax
		add edi, 4				; go to next position in array
		loop userInput			; if 10 values haven't been received yet

		mov ecx, MAXINPUT		; counter 10 in ecx
		mov esi, OFFSET array
		mov ebx, 0
		displayString youEntered ; display title before displaying user input
		call Crlf

	;------------------------------------------------------
	; sums
	; Description: Dispy the sum. Calculate the average,
	; determine if it requires rounding up.
	;------------------------------------------------------
	sums:
		mov eax, [esi]
		add ebx, eax		; adding value in eax to sum in ebx
		push eax			; pushing parameters (eax and temp) 
		push OFFSET temp	; push temp by reference
		call WriteVal
		call Crlf
		add esi, 4			; to the next element in array
		loop sums

		mov eax, ebx		; ebx holds sum, putting in eax to display
		mov sum, eax
		displayString theSum	; macro to display sum title
		push sum			; pushing parameters (eax and temp) 
		push OFFSET temp	; push temp by reference
		call WriteVal
		call Crlf

		mov ebx, MAXINPUT	; setting ebx to 10
		mov edx, 0			; clear remainder to prepare for division
		div ebx

		; Check if rounding is necessary
		mov ecx, eax
		mov eax, edx
		mov edx, 2
		mul edx
		cmp eax, ebx
		mov eax, ecx
		mov average, eax
		jb noRounding
		inc eax				; if rounding is required, increment by 1
		mov average, eax

	noRounding:
		displayString theAvg	; macro to display avg title
		push average			;push average by value
		push OFFSET temp		;push temp by reference
		call WriteVal
		call Crlf

	;------------------------------------------------------
	; Extra Credit
	;------------------------------------------------------
	displayString totalEntered	; macro to display running total of user's input
	mov eax, lineNumber
	call WriteDec
	call Crlf
	call Crlf

	;------------------------------------------------------
	; Farewell
	;------------------------------------------------------
	call farewell


	exit	; exit to operating system

main ENDP

;------------------------------------------------------------------
; PROC: Introduction
; Description:Introduce program name, programmer, and instructions
; Receives: None
; Returns: Prints program title, programmer name, and 
; program description
; Registers Changed: EDX
;-------------------------------------------------------------------

introduction PROC

	; Display program title
	mov edx, OFFSET programTitle
	call WriteString
	call Crlf

	; Display programmer
	mov edx, OFFSET programmer
	call WriteString
	call Crlf
	call Crlf

	; Display instructions
	mov edx, OFFSET instructions
	call WriteString
	call Crlf
	mov edx, OFFSET instructions2
	call WriteString
	call Crlf
	mov edx, OFFSET instructions3
	call WriteString
	call Crlf
	mov edx, OFFSET instructions4
	call WriteString
	call Crlf

	; Display extra credit
	mov edx, OFFSET EC1
	call WriteString
	call Crlf
	call Crlf

	ret

introduction ENDP

;------------------------------------------------------------------
; PROC: Farewell
; Description: Farewell message
; Receives: None
; Returns: Goodbye message
; Registers Changed: EDX
;-------------------------------------------------------------------

farewell PROC

	; Display goodbye message
	mov edx, OFFSET goodbye
	call WriteString
	call Crlf
	call Crlf

	ret

farewell ENDP

;------------------------------------------------------------------
; PROC: readVal
; Description: Invoke getString to get user's string and convert
; digit to numeric
; Receives: OFFSET inputBuffer, SIZEOF inputBuffer
;-------------------------------------------------------------------

readVal PROC

	push ebp		; push old edp +4
	mov ebp, esp	; set stack frame pointer
	pushad			; save all registers

	; Ask user for number
	askNumber:
		mov eax, 1			; EC1: Display line numbers
		add lineNumber, eax
		mov eax, lineNumber
		call WriteDec
		mov edx, OFFSET punct
		call WriteString

		mov edx, [ebp+12]	; address of inputBuffer
		mov ecx, [ebp+8]	; size of inputBuffer array stored in ecx
		getString edx, ecx	; invoke getString to get user input

		; Setting up registers for conversion to numeric
		mov esi, edx		; esi now holds address of inputbuffer
		mov eax, 0
		mov ecx, 0
		mov ebx, MAXINPUT	; maxinput is 10

	; Utilize LODSB, which loads a byte from memory at ESI into AX.
	; ESI is incremented/decremented based on state of Direction Flag
	loadBytes:
		lodsb			; loads a byte from memory at esi into ax
		cmp ax, 0		; comparing to check if end of string has been reached
		je done

		cmp ax, 57		; validate char is an int, 9 is ASCII 57
		ja invalidInput	; jump to error message if it is above
		cmp ax, 48		; validate char is an int, 0 is ASCII 48
		jb invalidInput	; jump to error message if it is below

		; If no invalid input, adjust string for the value of the digit
		sub ax, 48		; subtracting 48 for the value
		xchg eax, ecx	; exchanging the value of the char in ecx, with eax
		mul ebx			; since ebx holds maxinput 10, multiply value of char by 10
		jc invalidInput	; if carry flag is set which determines OF
		jnc valid		; if carry flag is not set

	invalidInput:
		mov edx, OFFSET errorMessage
		call WriteString
		call Crlf
		mov edx, OFFSET errorMessage2
		call WriteString
		call Crlf
		jmp askNumber

	valid:
		add eax, ecx	; adding the digit to to the total
		xchg eax, ecx	; exchanging eax and ecx for the next loop
		jmp loadBytes	; check the next byte

	done:
		xchg ecx, eax
		mov DWORD PTR inputBuffer, eax	; saving the int by moving eax to the pointer
		popad			; restore the registers
		pop ebp			; restore stack
		ret 8			; return bytes pushed before the call
		
readVal ENDP

;------------------------------------------------------------------
; PROC: writeVal
; Description: Convert numeric value to a string of digits and
; invoke displayString to produce
; Receives: integer, string
;-------------------------------------------------------------------

writeVal PROC

	push ebp			; push old ebp +4
	mov ebp, esp		; set stack frame pointer
	pushad				; save registers

	; Loop through integers
	mov eax, [ebp+12]	; move int to be converted to a string in eax
	mov edi, [ebp+8]	; move the address to edi to store string
	mov ebx, MAXINPUT	
	push 0				; top of the stack

	conversion:
		mov edx, 0		; clear remainder
		div ebx			; divide value by 10 to extract minimal digit
		add edx, 48
		push edx		; push following digit onto stack
		cmp eax, 0		; check if the end has been reached
		jne conversion	; keep looping conversion until end is reached

	pops:
		pop [edi]
		mov eax, [edi]
		inc edi			; edi holds the counter, increment it
		cmp eax, 0		; check if the end has been reached
		jne pops		; keep looping pop until end has been reached

	mov edx, [ebp+8]	; write string using macro
	displayString OFFSET temp
	call Crlf

	popad				; restore all registers
	pop ebp				; restore stack
	ret 8				; return bytes pushed before the call

writeVal ENDP

END main
