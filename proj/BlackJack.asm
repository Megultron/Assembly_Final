TITLE BLACKJACK
; Description:BlackJack Project
; Team: Scott Howland, Clinton Grove, Aaron ,Jacob
; 
; Revision date:

INCLUDE Irvine32.inc




.data
deck BYTE 52 DUP(?)
shuffled_deck BYTE 52 DUP(?)
shuffle_range_size BYTE 52
shift_index DWORD ?


.code

main PROC
	call deckgen
	call shuffle

	invoke ExitProcess, 0
main ENDP



deckgen PROC
	mov bl, 1
	mov ecx, 13
	movzx esi, BYTE PTR [deck]

	ADD_TYPES:
		call addtype
		inc bl
		loop ADD_TYPES
deckgen ENDP


addtype PROC USES ecx
	mov ecx, 4
	ADD_ELEMENT:
		mov deck[esi * BYTE], bl
		inc esi
		loop ADD_ELEMENT
	ret
addtype ENDP

shuffle PROC USES esi
	mov ecx, 52
	movzx esi, BYTE PTR [shuffled_deck]
	call Randomize
	SHUFFLEL:
		movzx eax, shuffle_range_size
		inc eax
		call RandomRange
		mov bl, deck[eax * BYTE]
		mov shuffled_deck[esi * BYTE], bl
		inc esi
		dec shuffle_range_size
		call shiftleft
		loop SHUFFLEL

	ret
shuffle ENDP

shiftleft PROC USES ecx edx
	mov shift_index, eax
	mov eax, LENGTHOF deck
	sub eax, shift_index
	dec eax
	dec eax
	mov ecx, eax
	SHIFTL:
		mov eax, shift_index
		inc eax
		mov bl, deck[eax * BYTE] 
		mov edx, shift_index
		mov deck[edx * BYTE], bl
		mov eax, shift_index
		inc eax
		mov shift_index, eax
		loop SHIFTL

	ret
shiftleft ENDP

END main