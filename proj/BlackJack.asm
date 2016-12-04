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



.code

main PROC
	call deckgen


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

shuffle PROC
	

	ret
shuffle ENDP

END main