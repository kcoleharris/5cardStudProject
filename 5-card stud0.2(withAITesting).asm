###################################################################################
## This is the five card draw project that is being coded, so far it is creating ##
## hands and showing their values as cards themselves. The next section can also ##
## evaluate the hand and what type it is. From here we can also determine if one ##
## hand can win over the other. So far it is only one player and not computer	 ##
###################################################################################

#This is where the bulk of ascii calls for cards and and spaces for arrays
.data

#This section is where the buffer and the string for displaying the hand is stored
exchangePrompt: .ascii "Please enter the number of cards you wish to exchange.\n 0 is for if you don't wish to exchange any cards\n1-3 because 3 is the max in House Rules"
exchange: .ascii "Which card from 1-5 would you like to exchange?\nIf you enter the same number twice it will deal a new card in that position\n and then remove that card and deal another new card in the position"
handPrompt: .ascii "\nYou're hand so far is: "
display: .space 30
invalidInput: .asciiz "That was an invalid choice, possibly not even a number!"
InvalidNum: .asciiz "That is not an available number!"

# This last ascii section is for displaying the winner of a hand and both the player's hand and the AI's hand
player:	.ascii "Player 1's hand: "
finalHands: .space 30
AIHand:	.ascii "\nAI's hand: "
AIFinalHand: .space 30	

playerWins: .asciiz "You Won!"
AIWins:	.asciiz "The computer won."

#This is where the size of the hand, depending on how many players it will increase by this
hand: .word 0 : 10
suitHolder: .word 0 : 10
exchangeCards: .word 0 : 8

#This area has each of the possible hands
HighCard: .asciiz "\nYou only have a high card!"
Pair: .asciiz "\nYou have a pair!"
TwoPair: .asciiz "\nYou have two pairs!"
ThreeOfAKind: .asciiz "\nYou have three of a kind!"
FourOfAKind: .asciiz "\nYou got four a kind!"
FullHouse: .asciiz "\nYou got a full house!"
Straight: .asciiz "\nYou got a straight!"
Flush: .asciiz "\nYou got a flush!"
StraightFlush: .asciiz "\nYou got a straight flush"
RoyalFlush: .asciiz "\nYOU GOT A ROYAL FLUSH!"

# The next was for all of the AI's hands
HighCardAI: .asciiz "\nThey only have a high card!"
PairAI: .asciiz "\nThey have a pair!"
TwoPairAI: .asciiz "\nThey have two pairs!"
ThreeOfAKindAI: .asciiz "\nThey have three of a kind!"
FourOfAKindAI: .asciiz "\nThey got four a kind!"
FullHouseAI: .asciiz "\nThey got a full house!"
StraightAI: .asciiz "\nThey got a straight!"
FlushAI: .asciiz "\nThey got a flush!"
StraightFlushAI: .asciiz "\nThey got a straight flush"
RoyalFlushAI: .asciiz "\nTHEY GOT A ROYAL FLUSH!"


.text

mainMenu:
#This is the first part of the program that will execute and if some one chooses to go back to the main menu it jumps here


deal:
#This part of the code and the deal loop that runs for all the cards for the hand
	la $s0, hand	#Loads the size of the hand of the array in $s0
	la $s1, suitHolder	#Loads the size of the hand into of the array in $s1
	li $t0, 0	#Makes $t0 = 0 for tracking the loop
	li $a1, 51	#Sets the maximum on the random numbers
	li $v0, 42	#Preps to generate a randomn number


#Save card is used to only save the number of cards that are needed in the program
saveCard:
jal dealLoop	#Jumps and links to the dealLoop code
sw $a0, 0($s0)	#After linking back it saves the new card number in the array
addi $s0, $s0, 4	#Increments the card array
addi $t0, $t0, 1	#Increments the counter of cards
blt $t0, 10, saveCard	#Branches if there are still cards that are needed to be created and dealt
					#The back 5 are the ones for the computer's AI

addi $s0, $s0, -40	#Needed to readjust where the array is currently indexing at
li $t4, 5	#Sets up a loop reference to count how many havce passed, need only 5 at the moment
la $s2, display	#Loads the buffer for use to display the cards
la $s3, exchangeCards	#Sets up the array that will take in the exchanged cards
li $t0, 0	# Counter for the buffers
jal card #Juamps and links to cards to build a string to be displayed later
#Then it goes straight into the next needed section of code

###################################################################################################
# This next section will evaluate the hand, and tell you what kind of hand it is. Soon it will be #
# tell you wether or not you have won comparitavley to another hand				 		   #
###################################################################################################
la $t3, 0	#Zeros out another temporary to account for the needed looping to find when the hand needs to be sorted
la $t1, 0	#Zeros out $t1 to be used in the loop

possibleLoop:
li $v0, 51	#Prompts to put in a dialogue box that takes in an integer
la $a0, exchangePrompt	#Loads the string that will be printed as a message in the dialogue box
syscall	#Puts out the dailogue bo
bltz $a1, invalidChoice	#If the input character/s changed the status to a non-OK status, branches to invalidChoice for it
bgt $a0, 3, invalidNum	#If the input integer was greater than 3, it branches to an invalid number handler
bltz $a0, invalidNum	#If the input integer was less than 0, it branches to an invalid numer handler
move $t1, $a0	#Moves the integer to $t1 to be used
move $t4, $a0	#Moves the same integer to $t4, so it can be used without interfering with the secondary counter
beqz $t1, read2	# If the player wants 0 cards traded
#If a valid number is given it goes straight to the tradeCards loop

#This method is to store the position of all of the cards the user wants to trade
tradeCards:
beqz $t1, newDeal	#If the secondary reaches 0 then it branches to newDeal
li $v0, 51	#Prompts a dialogue box to show the user all of their options
la $a0, exchange	#Loads the message that is to prompt the message
syscall	#Prompts the message box and gets ready to take in integer input
bltz $a1, invalidChoice	#If the input character/s changed the status to a non-OK status, branches to invalidChoice for it
bgt $a0, 5, invalidNum	#If the input integer was greater than 3, it branches to an invalid number handler
blt $a0, 1,invalidNum	#If the input integer was less than 0, it branches to an invalid numer handler
add $t0, $a0, -1	#Takes the input number and subracts 1 to adjust for it being an array
sw $t0, 0($s3)	#Stores the number in the discardCard array
addi $s3, $s3, 4	#Increments the array
addi $t1, $t1, -1	#Decrements the counter by 1
b tradeCards	#Branches back to tradeCards

#If the choice chosen was an invalid one
invalidChoice:
li $v0, 55	#Prompts a message box
la $a0, invalidInput	#Loads the message
syscall 	#Outputs the dialogue box for the user to see
beqz $t1, possibleLoop	#If the $t1 was equal to zero, it branches back to possiblLoop
b tradeCards	#If $t1 is different from 0, then it branches to tradeCards

#If the choice chosen was an invalid number
invalidNum:
li $v0, 55	#Prompts a message box
la $a0, InvalidNum	#Loads the messagae
syscall	#Outputs the dialogue box for the user to see
beqz $t1, possibleLoop	#If the $t1 was equal to zero, it branches back to possibleLoop
b tradeCards	#If $t1 is different from 0, then it branches to tradeCards

#This is the section that gives new cards into the main array
newDeal:
mul $t4, $t4, -4	#Takes $t4 and multiplies it by -4 to find how much $s3 array needs to be adjusted
add $s3, $s3, $t4	#Adjusts the discardCards array
div $t4, $t4, -4	#Divides $t4 by -4 to find the original value to be used as a counter
addi $s0, $s0, 20	#Adds twenty so that you start at the beginning of the player's hand size a the buffere creater went 20 bytes in
li $t9, 1	#Loads a flag value for the cardChecking loop for dealing new cards
li $v0, 42	#Preps to create a random integer
li $a1, 51	#Loads the maximum for the random numbers
li $t0, 10	#Loads 5 for the $t0 to use as a counter in the dealing loops
newDealLoop:	
lw $t5, 0($s3)	#Loads the next number inwhich is the position in the array the user wishes to replace with a new card
mul $t3, $t3, -4	# Find the necessary number of bytes to add to the discard array to set it to its original position
add $s3, $s3, $t3	#Adds the adjustment to the discard array
div $t3, $t3, -4	# Divides the adjustment back to be a coutner again
jal dealLoop	#Jumps and links to the dealLoop
addi $s0, $s0, -40	#After jumping back it decrements the hand array to its original position
mul $t5, $t5, 4	#Gets the position that the user wants a new card in by taking the number and multiplying by 4
add $s0, $s0, $t5	#Then it adjusts the array to that position
lw $t6, 0($s0)	#Loads the word into $t6
sw $a0, 0($s0)	#Saves the new card into the hand array
mul $t3, $t3, 4	#Finds out how many bytes forward the array needs to be adjusted back to the current position of the card
add $s3, $s3, $t3	#Adjusts the array to its current position
div $t3, $t3, 4	#Divides the adjustment back to the number of cards
sw $t6, 0($s3)	#Saves the old card in the discardCardArray
sub $s0, $s0, $t5	#Readjusts the array back from the altering position to the original position
addi $s0, $s0, 40	#Adjusts the array all the way to the end
addi $s3, $s3, 4	#Increments the array to its new position
addi $t3, $t3, 1	#Increments the number of cards in the discard array
addi $t4, $t4, -1	#Decrements the counter by 1
bgtz $t4, newDealLoop	#If the counter is greater than zero it branches back to newDealLoop
addi $s0, $s0, -20	#Decrements the array all the way back to the original position
read2:	# Label just added incase the player wants zero added cards
addi $s0, $s0, -20	# This was added to avoid an error if a player only wanted one card
li $t4, 5	#Loads $t4 with five to be used as the counter in the card subroutine
la $s2, finalHands	# Loads the final hand buffer so the player's hand and the AI's hand can be displayed later
jal card	#Jumps and links to the card subroutine
move $t8, $t3	#Gives $t8 the value so it can be store temporarily and then used as a counter from the discard array again
li $t3, 0

# This is a sorting set up for the AI's hand first grabbing all of its cards and 
preSortAI:
lw $t0, 0($s0)	#Grabs the value of the AI's first card
blt $t0, 13, next
jal reduce	#Jumps and links to reduce to find face value
next:
sw $t0, 0($s3)	#Saves face value into discard array, uss discard array so it will be overridden by position or -1 flag value
lw $t0, 4($s0)	#Does the same thing to the AI's second card
blt $t0, 13, next1
jal reduce
next1:
sw $t0, 4($s3)
lw $t0, 8($s0)	#Then third
blt $t0, 13, next2
jal reduce
next2:
sw $t0, 8($s3)
lw $t0, 12($s0)#Fourth
blt $t0, 13, next3
jal reduce
next3:
sw $t0, 12($s3)
lw $t0, 16($s0)#Then finally the fifth and final
blt $t0, 13, next4
jal reduce
next4:
sw $t0, 16($s3)
li $t6, 3 #Loads the number of cards minus 2 to account for the two cards that are always out of array being compared
la $t4, 0	#Zeros out $t4 to use as a counter

sortAI:
lw $t0, 0($s3)	#Gets the earlier face value
lw $t1, 4($s3) #Loads the next face value to compare to
bgt $t4, $t6, postSortAI	#If the sorting is finished because all values have been gone through once it branches to the next step
blt $t1, $t0, swapAI	#If the first is greater than the second face value then it sorts them by branching to it
addi $s0, $s0, 4	#Increments the hand array
addi $s3, $s3, 4	#Increments the discard array
addi $t4, $t4, 1	#Increments the counter for this loop
b sortAI	#branche immediatley back to sortAI

swapAI:	#This is used if positions of two value need to be changed
sw $t0, 4($s3)	#Stores the greater value in the new high position
sw $t1, 0($s3)	#Stores the lesser value in the new lower position
lw $t0, 0($s0)	#Loads the same position in the hand array
lw $t1, 4($s0)	#Loads the same position in the hand array
sw $t0, 4($s0)	#Then it swaps them in their appropriate new locations because of sorting by face value
sw $t1, 0($s0)	
mul $t4, $t4, -4 # Multiplies the upwards counter by -4 to find the amount of space the arrays need to be adjusted to get
			  # back to the beginning of the AI's hand
add $s0, $s0, $t4	#Adjusts the hand array back to the beginning of the AI's hand
add $s3, $s3, $t4	#Adjusts the discard, temporarily face array, to the beginning of the AI's hand
la $t4, 0	#Zeros out the upwards counter 
j sortAI	#Jumps back to sortAI


postSortAI:
mul $t4, $t4, -4	#Multiplies the coutner by -4 to find the adjustment needed to get to the beginning of the arrays
add $s0, $s0, $t4	#Decrements the face value array to the starting position
add $s3, $s3, $t4	#Decrements the suit value array to the starting position
li $t2, -1	#Gives a null non-card value to $t2 to be compared to if there was a previous match
li $t6, 0	#Zeros out $t3 for use to track number of matching cards or other values
li $t4, -1	#This is the value that will be saved in the array if this is a cards that is not to be discarded(in $s3)
li $t5, 0	#Zeros out a counter for hand position
li $t3, 0	# Zeros out the $t3 counter that keeps hand value

pairEvalAI:
addi $t5, $t5, 1	#Adds 1 to the counter
bge $t5, 5, handTypeAI	#If the entire hand has been proccessed it goes to the nextChecker label
lw $t0, 0($s3)	#Loads the next face value from the array
lw $t1, 4($s3)	#Loads the face value from the array, after the first
beq $t0, $t1, isPairAI	#If they are equal to each other it branches to the isPair label to find out what kind
beq $t1, $t2, threeOfAI	# If there is a previous pair and there is another of the same kind then it is three of a kind
					# Also if there was a previous pair both are already marked with a -1 flag
addi $s3, $s3 4	#If reached it increments the face value array to evaluate the next possible pair
b pairEvalAI	#Branches back to another iteration of pairEval

isPairAI:
bgtz $t6, twoPairAI	#If there was pre-determined pair or more, seen by having $t3 larger than zero
li $t6, 1	#If it is reached, by having no prior matchings, it increments $t3, for later use, if another match if found
move $t2, $t0	#Moves the first card's value into $t2, also to be used later for more possible matches
#Then it saves both cards involved in the pair
sw $t4, 0($s3)	#Saves the first card by giving it a -1 value in the array
sw $t4, 4($s3)	#Saves the second card by giving it a -1 value in the array
addi $s3, $s3, 4	#Increments the temp face array
b pairEvalAI	#Branches back to evaluate another possible pair
		
#If there were two different pairs found
twoPairAI:
beq $t6, 3, skipTradeAI	#Checks to see if $t3 equals 3, later can be seen in three of a kind, to see if this makes a full house
			#If so, it branches to that label
li $t6, 2	#Loads 2, into $t3 to show there was another pair
#Saves the two cards in the array for this new and different pair with -1 values
sw $t4, 0($s3)	#Saves the first card by giving it a -1 value in the array
sw $t4, 4($s3)	#Saves the second card by giving it a -1 value in the array

move $t2, $t0	#Moves the matching card's value into $t2, for another possible match
addi $s3, $s3, 4	#Increments the temp face array to the next card
b pairEvalAI
	
#If the match was found to be part of a three of a kind
threeOfAI:
beq $t6, 3, skipTradeAI	#If there was a 3 in $t3, already had three of a kind, it branches to the fourOfaKind label
beq $t6, 2, skipTradeAI	#If there was a two pair found befoore hand, it branches to the fullHouse label
li $t6, 3	#Loads 3 in $t3, for possible later use if there is a two pair found after this three of a kind to be
		#proccessed as a full house
#If it defies the other two possible and great outcomes it saves the third card with -1 value
sw $t4, 4($s3)
addi $s3, $s3, 4	#Increments the array by another card
b pairEvalAI

#After all pairs have been checked for
nextCheckerAI:	
bgtz $t3, handTypeAI	#If a match has ever been found
mul $t5, $t5, -4	#Multiplies the counter by -4 to find the needed adjustment to set teh array back to its start position
add $s3, $s3, $t5	#Adjusts the face value array back to its start position
div $t5, $t5, -4	#Divides the counter by -4 to use it as a counter for the section after

#####################################################################################
## Another thing that maybe added is a smater AI that will be able to identify and ##
## that can take in for flush and straights and try for them if there is no pairs  ##
## for now it is not done yet											   ##
#####################################################################################

#Evaluates the hand based on the $t3 values
handTypeAI:
beqz $t6, highCardAI	#If $t3 is zero, and it hasn't branched to another area already, then the hand only has a high card
bgtz $t6, commenceTradingAI

preHighCardAI:
addi $t5, $t5, 1
mul $t6, $t5, -4
add $s3, $s3, $t6
#The section after this are all the labels for all possible hands and prints out to let the user know what hand they have
#Most of these are just loadings of strings and then system calls for printing
highCardAI:
sw $t4, 0($s3)
sw $t4, -4($s3)

#This section more prepares to use the trading ai, mainly it is used to make the position of the cards that are going
#to be traded, by checking if they are equal to -1 or not, if they aren't they are automatically skipped over. Couldn't
#use a 0 value because it could be mistaken as a card by the dealoop checkers
commenceTradingAI:
li $t4, 0	#Rezeros the $t4 register to act as an overall counter

# This part of the code goes to current values in the discard and sees if they have been marked with a -1
# If they are not from the previous code, that finds any possible pair and saves their position with -1 as
# a null value that will also not be mistaken as a card in the search of the discard card comparissons
preTradeAI:
addi $s3, $s3, -20	# It then adjusts the discard array by that number of bytes
addi $t3, $t8, -1	# Both moves the number of cards currently in the discard array but also adjusts for tradeAI
li $t4, -1	# Loads -1 to start since the tradeAI adds one in the beginning of the phase
li $v0, 42	# Prepares to create a randomn number	
li $a1, 51	# Loads the maximum for card numbers, 51 if you include 0 different cards
addi $s0, $s0, -4	# Preps the hand array for beginning incrementation 
li $t8, 1	# If this wasn't tripped before because of lack of players cards being traded it is tripped now

# This is the trading AI that basically goes through each and every card in the hand, using the discard card as a reference
# for whether or not the card is being traded or not
tradeAI:
addi $t3, $t3, 1	# Increments the dicard card array coutner
addi $t4, $t4, 1	# Increments the counter
addi $s3, $s3, 4	# Increments the discard array
addi $s0, $s0, 4
beq $t4, 5, preHandLoop	# If the value of $t4 is equal to five it goes the presort starter
lw $t6, 0($s3)	# This loads the current card that it is on
beq $t6, -1, tradeAI	# If the current card's value is -1 then it branches back to tradeAI
subi $t5, $t4, 5	# This should find the correct adjustment for the array to start at the end of the hand array
mul $t5, $t5, -4	# Adjustment from current position in the end array for the hands
add $s0, $s0, $t5	# Adjusts the hand array at the end of the hand array
mul $t5, $t3, -4
add $s3, $s3, $t5	# Adjusts the discard array to the beginning of it
li $t0, 10	# Loads the instant of 10 where the card's value used to be, though it is still in the array
jal dealLoop	# Jumps and links to the dealLoop where it will find another card value that is not in the other current arrays
add $s0, $s0, -20	# Starts the counter at the beginning of the AI's hand
mul $t5, $t4, 4	# This is the adjustment for beginning of the AI's hand to its current position in the trade
add $s0, $s0, $t5	# Adjusts the hand array to its current position
mul $t5, $t3, 4	# Adjustment that is needed to get to the current position in the discard hand
add $s3, $s3, $t5	# Adjusts the discard array by the number of cards already in the array to find its  current position again
lw $t6, 0($s0)	# Gets the old card in the array
sw $t6, 0($s3)	# Saves the old card into the discard array
sw $a0, 0($s0)	# Saves the new card into the hand array
b tradeAI


skipTradeAI:
#Skip trading and go into betting if that is available during

preHandLoop:
addi $s0, $s0, -20	# This sets the hand array back to the begining of the AI's hand and 
la $s2, AIFinalHand
jal card	# Jumps and links to the card subroutine to put the cards that are in the AI's hand in the same box\
li $t3, 0	# Loads zero into $t3 to start the hand loop and do it 10 times
addi $s0, $s0, -40	# Adjusts the hand array all the way to its begginning
handLoop:
li $t1, 0	# Zeros out the suit for each run that occurs
bge $t3, 10, preSort	#If the loop has gone through and evaluated all of the cards it goes to the PreSorting section of code
lw $t0, 0($s0)	#This loads the first card number
ble $t0, 12, skip	#If the card's number value is less than 1
jal reduce	#If the skip label is not reached, it jumps and links to the reduce subroutine, so that the card can be
			#reduced and the suit is placed in the label
skip:	#Label if the hand is already been minimized
sw $t0, 0($s0)	#Saves the card face value  back into it's original array
sw $t1, 0($s1)	#Saves the suit value, for easier reference, in a seperate array
addi $s0, $s0, 4	#Increments the face value array
addi $s1, $s1, 4	#Increments the suit array
addi $t3, $t3, 1	#Increments the counter for how far along in the hand the program is in
j handLoop	#Jumps back to handLoop to evaluate the next card

reduce:	#A reducing subroutine, that will seperate the suit and face values in two temporary registers
addi $t0, $t0, -13	#Decrements the card by 12, number of cards in a suit
addi $t1, $t1, 1	#Increments the suit counter
bgt $t0, 12, reduce	#Branches back to reduce, if the value is still greater than 11
jr $ra	#Jump register to return address, to jump back to the position saved when a jump and link occured

#Sets up for sorting so the hand can be evaluated
preSort:
li $t9, 0	# This will contain a flag value that  will tell the program that this needs to run one more time for the AI's hand
mul $t3, $t3, -4	#Multiplies the counter by -4, to adjust to the beginning of the arrays
add $s0, $s0, $t3	#Adjusts the face value array back to the original position
add $s1, $s1, $t3	#Adjusts the suit value array back to the original position
li $t3, 3
li $t4, 0
b sort
preSort2:	# This label is for reference for the second sort run that is needed to sort the AI's hand
li $t3, 3	# Loads 3 because that is the number of loops to compare each value in one hand, this will repeat once more though
la $t4, 0	#Zeroes out an array tracking counter and also to compare to the $t3 counter when finished sorting
li $t9, 1
addi $s0, $s0, 4
addi $s3, $s3, 4

#This is the sorting section of the program so it easier to evaluate the hand later, sorts by their face value, not suits
sort:
lw $t0, 0($s0)	#Loads the next face value of a card
lw $t1, 4($s0)	#Loads the face value card after the first one aformentioned
bgt $t4, $t3, postSort	#If the incremented counter($t4) is greater than the starting counter($t3) it branches out of the sort
blt $t1, $t0, swap	#If the second value is less than the first it goes to swap "labe"
addi $s0, $s0, 4	#Increments the face value array
addi $s1, $s1, 4	#Increments the suit value array
addi $t4, $t4, 1	#Increments counter for the loop
b sort

#Swaps the registers that keeps up with the cards and their suits
swap:
sw $t0, 4($s0)	#Saves larger face value in a higher array position
sw $t1, 0($s0)	#Saves smaller face value in a lower array position
lw $t0, 0($s1)	#Loads the first suit value that needs to be swapped
lw $t1, 4($s1)	#Loads the second suit value that needs to be swapped
sw $t0, 4($s1)	#Saves the suit value in its new position
sw $t1, 0($s1)	#Saves the suit value in its new position
mul $t4, $t4, -4	#Multiplies the counter by -4 to find the adjustment needed to get to the beginning of the arrays
add $s0, $s0, $t4	#Decrements the face value array to the starting position
add $s1, $s1, $t4	#Decrements the suit value array to the starting position
la $t4, 0	#Zeros out counter for loop
j sort	#Jumps back to sort

#After the sort is done and hand evaluation is going to take place, label is there to break from sorting loops
postSort:
beqz $t9, preSort2
li $t4, -40	# This is the needed adjustment to change the arrays to their beginning positions
add $s0, $s0, $t4	#Decrements the face value array to the starting position
add $s1, $s1, $t4	#Decrements the suit value array to the starting position
li $t2, -1	#Gives a null non-card value to $t2 to be compared to if there was a previous match
li $t3, 0	#Zeros out $t3 for use to track number of matching cards or other values
li $t5, 0	#Zeros out a counter for hand position
li $t8, 0	# Zeros out t8 just incase because it is needed for comparing hands
li $t6, 0	# Zeros out t6 so it can accept the players highest card, either matching value or highest card
addi $s0, $s0, 4
addi $s1, $s1, 4
b pairEval

# This section is for the AI evaluation
secondEval:
addi $s0, $s0, 4	# Increments to the AI's face values
addi $s1, $s1, 4	# Increments to the AI's suit values
move $t6, $t2	# Moves the highest value being store in t2 to t7
move $t8, $t9	# Moves the player's type of hand to t8
li $t2, -1	# Non card value for $t2
li $t3, 0	# Zeros out $t3 for card match tracking
li $t5, 0	# Zeros out t5 for a counter in hand position

#Evaluates if the hand has any pairs
pairEval:
addi $t5, $t5, 1	#Adds 1 to the counter
bge $t5, 5, nextChecker	#If the entire hand has been proccessed it goes to the nextChecker label
lw $t0, 0($s0)	#Loads the next face value from the array
lw $t1, 4($s0)	#Loads the face value from the array, after the first
beq $t0, $t1, isPair	#If they are equal to each other it branches to the isPair label to find out what kind
addi $s0, $s0 4	#If reached it increments the face value array to evaluate the next possible pair
b pairEval	#Branches back to another iteration of pairEval

#If there was a successful pair
isPair:
beq $t1, $t2, threeOf	#If the latest card in the "matching pair" is equal to a previous possible pair, it branches to threeOf
			#to be processed as a three of a kind at least
bgtz $t3, twoP	#If there was pre-determined pair or more, seen by having $t3 larger than zero
li $t3, 1	#If it is reached, by having no prior matchings, it increments $t3, for later use, if another match if found
move $t2, $t0	#Moves the first card's value into $t2, also to be used later for more possible matches
addi $s0, $s0, 4	#Increments the array
b pairEval	#Branches back to evaluate another possible pair
		
#If there were two different pairs found
twoP:
beq $t3, 3, fullHouse	#Checks to see if $t3 equals 3, later can be seen in three of a kind, to see if this makes a full house
			#If so, it branches to that label
li $t3, 2	#Loads 2, into $t3 to show there was another pair
move $t2, $t0	#Moves the matching card's value into $t2, for another possible match
addi $s0, $s0, 4	#Increments the array to the next card
b pairEval
	
#If the match was found to be part of a three of a kind
threeOf:
beq $t3, 3, fourOfaKind	#If there was a 3 in $t3, already had three of a kind, it branches to the fourOfaKind label
beq $t3, 2, fullHouse	#If there was a two pair found befoore hand, it branches to the fullHouse label
li $t3, 3	#Loads 3 in $t3, for possible later use if there is a two pair found after this three of a kind to be
		#proccessed as a full house
addi $s0, $s0, 4	#Increments the array by another card
b pairEval

#After all pairs have been checked for
nextChecker:	
bgtz $t3, handType	#If a match has ever been found
mul $t5, $t5, -4	#Multiplies the counter by -4 to find the needed adjustment to set teh array back to its start position
add $s0, $s0, $t5	#Adjusts the face value array back to its start position
div $t5, $t5, -4	#Divides the counter by -4 to use it as a counter for the section after
addi $s0, $s0, 4


#This section executes only if a match of two cards has not been found, if even a pair exists it is impossible to have a straight
#or a flush, hence why his is after it checks for pairs
possibleStraight:
addi $t5, $t5, -1	#Decrements the counter by one
beqz $t5, possibleStFlush	#If the counter gets all the way down to zero, going  through each card, it branches 
				#to check for a straight flush
lw $t0, 0($s0)	#Loads the next face card value from the array
lw $t1, 4($s0)	#Loads the face card value after in the array
addi $t0, $t0, 1	#Increments the face card value by one
bne $t0, $t1, preFlush	#If any of the two numbers do not equal, after the first being incremented, it branches to a flush
				#checker since a straigh would be impossible if this were true
addi $s0, $s0, 4	#Increments the face value array to the next card
b possibleStraight	#Branches back to the possibleStraight area

#Executes if there is a possibility if there is a straight flush
possibleStFlush:
li $t3, 5	#Loads 5 into $t3, to identify it as a straight at least in this stage
li $t5, 5	#Re increments the counter back to 5 to count down from

#Adjust so Flush can run normally
preFlush:
mul $t5, $t5, 4	# Adjustment needed to get to the end of the hand array
add $s0, $s0, $t5	# Adjusts the hand array to the end of this hand
addi $s1, $s1, 4
addi $s0, $s0, -4
li $t5, 5	#Re-adjusts the counter so it can be used to search for a flush

#Checks for a possible flush
possibleFlush:
addi $t5, $t5, -1	#Decrements the counter by one
beqz $t5, flushType	#Checks if the counter is at zero, if it is it goes to flush type
lw $t0, 0($s1)	#Loads the next suit value
lw $t1, 4($s1)	#Loads the suit value after the first
bne $t0, $t1, preHandType	#If the two values do not match then it skips down to handType
addi $s1, $s1, 4	#Increments the suit array to the next value
b possibleFlush	#Brances back to possibleFlush

# This is just to readjust the suit array incase the player's hand gets to this point so it doesn't mess up the AI's checkers
preHandType:
mul $t5, $t5, 4	# Adjustment needed to get to the end of the suit array for this hand
add $s1, $s1, $t5


#Evaluates the hand based on the $t3 values
handType:
beqz $t3, highCard	#If $t3 is zero, and it hasn't branched to another area already, then the hand only has a high card
beq $t3, 1, pair	#If $t3 is equal to 1 then it is a pair
beq $t3, 2, twoPair	#If $t3 is two, then it is two pair
beq $t3, 3, threeKind	#If $t3 is three, then it is three of a kind
beq $t3, 5, straight	#If $t3 is five, then it is only a straight

#The section after this are all the labels for all possible hands and prints out to let the user know what hand they have
#Most of these are just loadings of strings and then system calls for printing
highCard:
li $t9, 1
lw $t2, 0($s0)	# Loads the last card in the array for comparrison incase of a tie
b ending	#Branches to exit for now, will probably be altered later to loop back and also to give pot values to the winner, after
	#of course it compares two values(player or computer hands) to each other

pair:
li $t9, 2
addi $s1, $s1, 16
b ending

twoPair:
li $t9, 3
addi $s1, $s1, 16
b ending

threeKind:
li $t9, 4
addi $s1, $s1, 16
b ending

straight:
lw $t2, 0($s0)	# Loads the last card in the face values for comparrison if needed
li $t9, 5
b ending

flushType:
beq $t3, 5, possibleRoyalFlush	#If it was a straight flush then it checks for a royal flush
#If it wasn't a straight flush then it just goes into the normal flush print out
lw $t2, 0($s0)	# Loads the last card in the hand for comparrison if needed
li $t9, 6
b ending

fullHouse:
li $t9, 7
addi $s1, $s1, 16
b ending

fourOfaKind:
li $t9, 8
addi $s1, $s1, 16
b ending

possibleRoyalFlush:
lw $t0, 0($s0)	#Loads the very first card
beq $t0, 12, royalFlush	#If the card is equal to 9(really the face value of 10) and it is a straight flush it is a royal flush
#If it doesn't branch to royalFlush it just simply goes and gets the StraightFlush String ready
lw $t2, 0($s0)	# Loads the last card in the straight flush for the comparrison
li $t9, 9
b ending

royalFlush:
lw $t2, 0($s1)	# If by some small miniscual chance there are two royal flushes it takes the suit type as a comparrison
li $t9, 10

# One of these ending types is soon chosen
ending:
beqz $t8, secondEval
li $v0, 59
la $a0, player
la $a1, AIHand
syscall
bgt $t8, $t9, playerWin
blt $t8, $t9, AIWin
beq $t8, $t9, tieBreaker

playerWin:
jal findPlayerHand
jal findAIHand
syscall
li $v0, 55
la $a0, playerWins
syscall
b exit

AIWin:
jal findPlayerHand
jal findAIHand
syscall
li $v0, 55
la $a0, AIWins
syscall
b exit

tieBreaker:
bge $t6, $t2, playerWin	# If the player has the slightly better or the same hand
blt $t6, $t2, AIWin	# If the AI has the slightly better hand

#This last bit is for exiting out of the program
exit:
	li $v0, 10	#Preps to kill the program
	syscall	#Kills the program


#This is where the cards are both evaluated and printed in their card form
card:
	lw $t1, 0($s0)	#Loads the next integer to be check from $a2 to $t1
	li $t2, 0	#Zeros out $t2 from previous evaluations
	
	cardReducerLoop:
	#This loop is to reduce the card and it will keep up with suit
		ble $t1, 12, cardReader	#If the value is less than or equal to 12 it branches to the next step
		addi $t1, $t1, -13	#Reduces the number by 13
		addi $t2, $t2, 1	#Increments $t2, which keeps up with the suit, by 1 if it doesn't branch
		b cardReducerLoop	#Branches back to be re-evaluated
		
###################################################################################################################################
## This part is used to translate one of the two remaining temporaries needed to the card value. It uses branching, first from   ##
## zero, then it uses another register to incriment though I constantly use load immediate to zero out register, this way I can  ##
## avoid accidentally having a left over number that may accidently trigger a branch where it shouldn't, and compare to the same ##
## $t1 where the value is. When it branches, it jumps down to where the label next to it is and prints the card.		 	    ##
###################################################################################################################################

	cardReader:
		blt $t1, 8, singleDigit	#If the face value is a single digit
		beq $t1, 8, eight	#If the face value is 10
		beq $t1, 9, nine	#The face value is a jack
		beq $t1, 10, ten	#The face value is a queen
		beq $t1, 11, eleven	#The face value is a king
		beq $t1, 12, twelve	#The face value is an ace
		
		#The next section is where the branches go to where it adds to the card's information to the buffer
		singleDigit:
			add $t1, $t1, 50	#Adds 50 to get the ascii values from 2-9
			sb $t1, 0($s2)	#Adds the ascii code to the buffer
			b suiteEval	#Branches to the next section of the evaluation
		eight:
			li $t1, 49	#Loads the ascii code for 1
			sb $t1, 0($s2)	#Saves the code to the buffer
			li $t1, 48	#Loads teh ascii code for 0
			sb $t1, 1($s2)	#Saves the code to the buffer
			addi $s2, $s2, 1	#Increments the buffer by 1 to account for this face value being double digit
			addi $t0, $t0, 1 #Increments the counter for the buffer that I can clear the buffer, or overwrite it when needed
			b suiteEval
		nine:
			li $t1, 74	#Loads the ascii code for J
			sb $t1, 0($s2)	#Saves the code to the buffer
			b suiteEval
		ten:
			li $t1, 81	#Loads the ascii code for Q
			sb $t1, 0($s2)	#Saves the code to the buffer
			b suiteEval
		eleven:
			li $t1, 75	#Loads the ascii code for K
			sb $t1, 0($s2)	#Saves the code to the buffer
			b suiteEval
		twelve:
			li $t1, 65	#Loads the ascii code for A
			sb $t1, 0($s2)	#Saves the code to the buffer
			b suiteEval
			
	#This next section uses the register $t2 for the suits of the card using the same method as above by first comparing the 
	#register to zero and then incrementing to the top possible value
	suiteEval:
		li $t1, 40	#Loads the ascii code for (
		sb $t1, 1($s2)	#Saves the code to the buffer
		beqz $t2, clubs	#Branches to clubs if the register has a zero
		beq $t2, 1, diamonds
		beq $t2, 2, hearts
		beq $t2, 3, spades
		
		#Next section is for printing the suit in parentheses next to its value, similar to the value prints section
		clubs:
			li $t1, 67	#Loads the ascii code for C
			sb $t1, 2($s2)
			b nextCard	#Branches out the next section needed
		diamonds:
			li $t1, 68	#Loads the ascii code for D
			sb $t1, 2($s2)
			b nextCard
		hearts:		
			li $t1, 72	#Loads the ascii code for H
			sb $t1, 2($s2)
			b nextCard
		spades:
			li $t1, 83	#Loads the ascii code for S
			sb $t1, 2($s2)
			b nextCard
			
	#Next is where the total number of cards left is decremented and the index of hte array is incremented and it branches if
	#there are still cards to be evaluated
	nextCard:
	li $t1, 41	#Loads the ascii code for )
	sb $t1, 3($s2)
	li $t1, 32	#Loads the ascii code for a space
	sb $t1, 4($s2)
	addi $s2, $s2, 5	#Increments the buffer by all the characters added
	addi $t0, $t0, 5
	addi $t4, $t4, -1	#Decrements number of cards left
	addi $s0, $s0, 4	#Increments to the next index in the array
	bgtz $t4 card		#Branches back to card for the next card evaluation
	jr $ra
	

discardDealLoop:
sub $t2, $t4, $t3	#Find the difference between the counter, and ho far the discard loop counter got to(will be negative)
mul $t2, $t2, 4	#With the difference it multiplies it by -4 to find out how much $s0 needs to be adjusted(no negative needed)
add $s3, $s3, $t2	#Adjusts the discardCard array to its starting position

#This outerDealLoop is only used if a randomn number that is going to be a card is already been introduced in the arrays
outerDealLoop:
sub $t1, $t0, $t1	#Finds the difference between the counter, and how far the innerloop's counter got to
mul $t1, $t1, -4	#With the difference it multiplies it by -4 to find out how much $s0 needs to be adjusted
add $s0, $s0, $t1	#Adjusts the array back to the the beginning position
syscall	#Creates a new randomn number to check
move $t1, $t0	#Resets the deal counter to the card counter
b innerDealLoop	#Branches straight back into the inner loop for the new randomn number to be checked against

dealLoop:
syscall	#Creates the randomn number
move $t1, $t0	#Moves the value of the counter to $t1, so this loop can use the counter without interfering with the other counter
mul $t2, $t1, -4	#Finds the needed adjustment that $s0 needs 
add $s0, $s0, $t2	#Adjusts the $s0 array back to its original position
bgtz $t0, innerDealLoop	#Checks if this is the first card to be created
jr $ra	#If it is the first card to be created it jumps straigh to save the card
innerDealLoop:
	lw $t2, 0($s0)	#Loads the next card in the array, starting from the beginning
	beq $t2, $a0, outerDealLoop	#If the number is equal to the same number created it branches to the outerDealLoop
	addi $s0, $s0, 4	#Increments the array
	addi $t1, $t1, -1	#Increments the deal counter
	bgtz $t1, innerDealLoop	#If the deal counter is greater than zero
	beqz $t9, skipDiscardCards	#If this is before the discard card phase, it skips the secondary checker
	beqz $t3, skipDiscardCards	#If this is the first card to be added in the discardCard phase it skips and returns
	move $t7, $t3	#Moves upwards counter of number of cards in discard array into $t7
	discardLoop:
	lw $t2, 0($s3)	#Loards first next card in the discardCard array
	beq $t2, $a0, discardDealLoop	#Branches if the randomn number and a card in the loop mathc it branches outside the outerDealLoop
	addi $s3, $s3, 4	#Increments the discardCard array
	addi $t7, $t7, -1	#Decrements the deal counter
	bgtz $t7, discardLoop	#If the counter is above zero it branches back as a loop
	#If valid it reaches this point and just goes straight into jumping back to the original register
	mul $t7, $t3, -4	#Finds out how many bytes that this discard array needs  to be readjusted
	add $s3, $s3, $t7	#Adjusts the array by this amount
skipDiscardCards:	#Section to skip to if this isn't the discard phase
jr $ra	#Jumps back to the jal that it was called from

findPlayerHand:
beq $t8, 1, highCardp
beq $t8, 2, pairp
beq $t8, 3, twoPairp
beq $t8, 4, threeOfAKindp
beq $t8, 5, straightp
beq $t8, 6, flushp
beq $t8, 7, fullHousep
beq $t8, 8, fourOfAKindp
beq $t8, 9, straightFlushp
beq $t8, 10, royalFlushp

highCardp:
la $a0, HighCard
jr $ra
pairp:
la $a0, Pair
jr $ra
twoPairp:
la $a0, TwoPair
jr $ra
threeOfAKindp:
la $a0, ThreeOfAKind
jr $ra
straightp:
la $a0, Straight
jr $ra
flushp:
la $a0, Flush
jr $ra
fullHousep:
la $a0, FullHouse
jr $ra
fourOfAKindp:
la $a0, FourOfAKind
jr $ra
straightFlushp:
la $a0, StraightFlush
jr $ra
royalFlushp:
la $a0, RoyalFlush
jr $ra

findAIHand:
beq $t9, 1, highCardAI2
beq $t9, 2, pairAI2
beq $t9, 3, twoPairAI2
beq $t9, 4, threeOfAKindAI2
beq $t9, 5, straightAI
beq $t9, 6, flushAI
beq $t9, 7, fullHouseAI
beq $t9, 8, fourOfAKindAI2
beq $t9, 9, straightFlushAI
beq $t9, 10, royalFlushAI

highCardAI2:
la $a1, HighCardAI
jr $ra
pairAI2:
la $a1, PairAI
jr $ra
twoPairAI2:
la $a1, TwoPairAI
jr $ra
threeOfAKindAI2:
la $a1, ThreeOfAKindAI
jr $ra
straightAI:
la $a1, StraightAI
jr $ra
flushAI:
la $a1, FlushAI
jr $ra
fullHouseAI:
la $a1, FullHouseAI
jr $ra
fourOfAKindAI2:
la $a1, FourOfAKindAI
jr $ra
straightFlushAI:
la $a1, StraightFlushAI
jr $ra
royalFlushAI:
la $a1, RoyalFlushAI
jr $ra
