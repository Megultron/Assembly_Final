TITLE BLACKJACK
; Description:BlackJack Project
; Team: Scott Howland, Clinton Grove, Aaron ,Jacob
; 
; Revision date:



INCLUDE Irvine32.inc

.data
;Deck of Cards and Shuffled Deck info
deck BYTE 52 DUP(?)
shuffled_deck BYTE 52 DUP(?)
shuffle_range_size BYTE 52
shift_index DWORD ?
shuffled_idx BYTE 0

;Contains dealer hand info, same as player's
dealer_hand BYTE 10 DUP(?)
dealer_facedown BYTE ?
dealer_idx BYTE 0

;Contains all of the player's face up cards
player_hand BYTE 10 DUP(?)
;Contains the player's face down card
player_facedown BYTE ?
;Contains total number of player's cards
player_idx BYTE 0

;Variable to signify if the player stayed
player_stay BYTE 0

;All of the possible output messages
face_up_string BYTE "Face Up: ",0
face_down_string BYTE "Face Down: ",0
dealer_faceup_string BYTE "Dealer: ",0
hit_or_stay BYTE "1. Hit or 2. Stay: ",0
bust_msg BYTE "You Busted! Press 1 to play again, 0 to exit.", 0
win_msg BYTE "You won! Press 1 to play again, 0 to exit.",0
.code

main PROC
;Main Game Loop, clears players hands and reset indecies for shuffling cards after a complete game
GameLoop:
	call ClearHands

	mov shuffled_idx, 0
	mov shift_index, 0
	mov shuffle_range_size, 52

	call deckgen
	call shuffle
	call DealHands

;Contains calls to functions for actual gameplay
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
	ja Win
;Contains the win message
Win:
	call DisplayCards
	call crlf
	mov edx, OFFSET win_msg
	call WriteString
	call crlf
	call ReadInt
	cmp eax, 1
	je GameLoop
	cmp eax, 0
	je ExitGame
;Contains the Bust Message
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

;Invokes Exits Process
ExitGame:
	invoke ExitProcess, 0
main ENDP

;Checks if players hand is a bust and if so, sets eax to 1
;Adds up player's hand and compares to 21
CheckBust PROC
	mov al, player_facedown
	mov esi, 0
	mov ecx, LENGTHOF player_hand
	SumLoop:
		add al, player_hand[esi]
		inc esi
		cmp eax, 21
		je Win
		ja Bust
		loop SumLoop
		mov eax, 0
		ret
	Bust:
		mov eax, 1
		ret
	Win:
		mov eax, 2
		ret
		

ret
CheckBust ENDP

;Clears both the player's and dealer's hands in order to reset the game
ClearHands PROC
mov ecx, 11
mov esi, 0

mov dealer_facedown, 0
mov player_facedown, 0

mov player_idx, 0
mov dealer_idx, 0

clearhand:
	mov player_hand[esi],0
	mov dealer_hand[esi],0
	inc esi
	loop clearhand


ret
ClearHands ENDP

;deals hands to player or dealers faceup or facedown arrays based on edx and ebx values
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

;generates deck of cards values 1-10
deckgen PROC
	mov esi, 0
	mov bl, 1
	mov ecx, 9
	;movzx esi, BYTE PTR [deck]

	ADD_TYPES:
		call addtype
		inc bl
		loop ADD_TYPES
	mov ecx,3
	ADD_TEN: ;adds extra cards with values of 10 to represent all the face cards
		call addtype
		loop ADD_TEN
deckgen ENDP

;procedure used by deckgen to add different types of cards to the deck with values 1-10
addtype PROC USES ecx
	mov ecx, 4
	ADD_ELEMENT:
		mov deck[esi * BYTE], bl
		inc esi
		loop ADD_ELEMENT
	ret
addtype ENDP

;shuffles cards using a random selection then shift left algorithm from the cards array into the shuffled cards array
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

;procedure used by shuffle to shift cards left after random card selection has occured
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

;displays card values for players faceup and facedown cards while hiding the dealers facedown values
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

;user choice to hit or stay, uses ebx and edx to control dealtohand proc
HitOrStay PROC

	mov edx,OFFSET hit_or_stay
	call WriteString
	call ReadInt
	cmp eax,1
	je HIT
	mov player_stay, 1
	ret

	HIT:
		mov edx,0
		mov ebx,0
		call DealToHand
		ret

HitOrStay ENDP

END main