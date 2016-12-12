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
shuffled_idx BYTE 0

dealer_hand BYTE 10 DUP(?)
dealer_facedown BYTE ?
dealer_idx BYTE 0

player_hand BYTE 10 DUP(?)
player_facedown BYTE ?
player_idx BYTE 0

face_up_string BYTE "Face Up: ",0
face_down_string BYTE "Face Down: ",0
dealer_faceup_string BYTE "Dealer: ",0
hit_or_stay BYTE "1. Hit or 2. Stay: ",0
bust_msg BYTE "You Busted! Press 1 to play again, 0 to exit.", 0
.code

main PROC




GameLoop:
	mov shuffled_idx, 0
	mov shift_index, 0
	mov shuffle_range_size, 52

	call deckgen
	call shuffle
	call DealHands


MainLoop:
	call clrscr
	call DisplayCards
	call HitOrStay
	call clrscr
	call CheckBust
	cmp eax, 0
	je MainLoop
	cmp eax, 1
	je Bust

Bust:
	call DisplayCards
	call crlf

	mov edx, OFFSET bust_msg
	call WriteString
	call crlf
	call ReadInt
	cmp eax, 1
	je GameLoop
	cmp eax, 0
	je ExitGame

ExitGame:
	invoke ExitProcess, 0
main ENDP

CheckBust PROC
	mov al, player_facedown
	mov esi, 0
	mov ecx, LENGTHOF player_hand
	SumLoop:
		add al, player_hand[esi]
		inc esi
		cmp eax, 21
		ja Bust
		loop SumLoop
		mov eax, 0
		ret
	Bust:
		mov eax, 1
		ret
		

ret
CheckBust ENDP

ClearHands PROC



ret
ClearHands ENDP

DealHands PROC

	mov edx, 0
	mov ebx, 0
	call DealToHand ;Player Faceup
	mov edx, 0
	mov ebx, 1
	call DealToHand ;Dealer Faceup

	mov edx, 1
	mov ebx, 0
	call DealToHand ;Player Facedown
	mov edx, 1
	mov ebx, 1
	call DealToHand ;Dealer Facedown

ret
DealHands ENDP

deckgen PROC
	mov esi, 0
	mov bl, 1
	mov ecx, 12
	;movzx esi, BYTE PTR [deck]

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

shiftleft PROC USES eax ecx edx
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

DealToHand PROC ;edx bool var to indicate face up or face down if true, ecx true if dealing to dealer
	movzx esi, shuffled_idx
	cmp edx, 1
	je FACEDOWN
	cmp edx, 0
	je FACEUP


	FACEDOWN:
		cmp ebx, 1
		je DEALER_DOWN
		cmp ebx, 0
		je PLAYER_DOWN

		DEALER_DOWN:
			mov cl, shuffled_deck[esi]
			mov dealer_facedown, cl
			inc shuffled_idx
			ret
		PLAYER_DOWN:
			mov cl, shuffled_deck[esi]
			mov player_facedown, cl
			inc shuffled_idx
			ret

	FACEUP:
		cmp ebx, 1
		je DEALER_UP
		cmp ebx, 0
		je PLAYER_UP

		DEALER_UP:
			movzx eax, dealer_idx
			mov cl, shuffled_deck[esi]
			mov dealer_hand[eax], cl
			inc shuffled_idx
			inc dealer_idx
			ret
		PLAYER_UP:
			movzx eax, player_idx
			mov cl, shuffled_deck[esi]
			mov player_hand[eax], cl
			inc shuffled_idx
			inc player_idx
			ret

DealToHand ENDP

DisplayCards PROC

	mov edx,OFFSET face_up_string
	call WriteString
	mov esi,0
	mov ecx, LENGTHOF player_hand
	PlayerHand:
		mov al, player_hand[esi]
		call WriteInt
		inc esi
		loop PlayerHand

	call crlf
	mov edx, OFFSET face_down_string
	call WriteString
	mov al, player_facedown
	call WriteInt
	call crlf

	mov edx, OFFSET dealer_faceup_string
	call WriteString
	mov al, dealer_hand[0]
	call WriteInt
	call crlf

	ret
DisplayCards ENDP

HitOrStay PROC

	mov edx,OFFSET hit_or_stay
	call WriteString
	call ReadInt
	cmp eax,1
	je HIT
	ret

	HIT:
		mov edx,0
		mov ebx,0
		call DealToHand
		ret

HitOrStay ENDP

END main