###################################################################################
## This is the five card draw project that is being coded, so far it is creating ##
## hands and showing their values as cards themselves. The next section can also ##
## evaluate the hand and what type it is. From here we can also determine if one ##
## hand can win over the other. So far it is only one player and not computer	 ##
###################################################################################

#This is where the bulk of ascii calls for cards and and spaces for arrays
.data

#This is where the size of the hand, depending on how many players it will increase by this
hand: .word 0 : 18
suitHolder: .word 0 : 18

#This the area where the card values are translated to be a number or face card, the face cards are only going to be the first letter
Two: .asciiz "2"
Three: .asciiz "3"
Four: .asciiz "4"
Five: .asciiz "5"
Six: .asciiz "6"
Seven: .asciiz "7"
Eight: .asciiz "8"
Nine: .asciiz "9"
Ten: .asciiz "10"
Jack: .asciiz "J"
Queen: .asciiz "Q"
King: .asciiz "K"
Ace: .asciiz "A"

#This is where the area that the suits will be stored
Clubs: .asciiz "(C) "
Diamonds: .asciiz "(D) "
Hearts: .asciiz "(H) "
Spades: .asciiz "(S) "

#This area has each of the possible hands
HighCard: .asciiz "You only have a high card!"
Pair: .asciiz "You have a pair!"
TwoPair: .asciiz "You have two pairs!"
ThreeOfAKind: .asciiz "You have three of a kind!"
FourOfAKind: .asciiz "You got four a kind!"
FullHouse: .asciiz "You got a full house!"
Straight: .asciiz "You got a straight!"
Flush: .asciiz "You got a flush!"
StraightFlush: .asciiz "You got a straight flush"
RoyalFlush: .asciiz "YOU GOT A ROYAL FLUSH!"

space: .asciiz ", "

.text

mainMenu:
#This is the first part of the program that will execute and if some one chooses to go back to the main menu it jumps here


deal:
#This part of the code and the deal loop that runs for all the cards for the hand
	la $s0, hand	#Loads the size of the hand of the array in $s0
	la $s1, suitHolder	#Loads the size of the hand into of the array in $s1
	li $t0, 0	#Makes $t0 = 0 for tracking the loop
	li $a1, 51	#Sets the maximum on the random numbers
	b dealLoop	#Branches and skips the outer loop, because it is not needed on the first run

#Only executes if a repeated card has been found
outerDealLoop:
	mul $t2, $t2, 4	#Gets remaining dissposition from the innerDealLoop and multiplies by 4 for readjustment needed for $a2
	add $s0, $s0, $t2	#Readjusts to where the last random number has been rejected
	
#Inner loop that will repeat for the size of the hand
dealLoop:
	li $v0, 42	#Loads 42, which is the random number generator(rng) comman to $v0
	syscall		#System call that creates the
	
	#This section is going to be a checker to the rest of the hand to see if any cards repeat, if they do it resets at dealLoop
	la $t1, ($a0)	#Loads the random number into a temporary adress that will be used for comparisson
	la $t2, ($t0)	#Loads how many runs the dealLoop has run so far
	mul $t2, $t2, -4	#Multiplies the number of runs by -4 to find out how many bytes $a2 needs to be run back
	add $s0, $s0, $t2	#Adds the readjust ment
	la $t2, ($t0)	#Loads how many runs have occured again to have how long this inner loop must run
	innerDealLoop:	#Label to inact as a loop to compare the new $t1 to the other values in an array
		lw $t3, 0($s0)	#Loads the first number in the array in $t3
		beq $t1, $t3, outerDealLoop	#If the new number is equal to an already created card then it goes to the outerDealLoop
		addi $s0, $s0, 4	#Adjusts the array to get a new number
		addi $t2, $t2, -1	#Subtracts one to $t2, to track how many more times this loop needs to run
		bgtz $t2, innerDealLoop	#If $t2 is greater than zero then it branches to innerDealLoop again
	
	sw $t1, 0($s0)	#If it makes it through the innerDealLoop it saves the number to the array
	addi $s0, $s0, 4	#Adjusts the array to the next index
	addi $t0, $t0, 1	#Adds 1 to $t0 to track the loop
	bltu $t0, 5, dealLoop	#Branches if $t0 is less than 5, to dealLoop
	
addi $s0, $s0, -20	#Adjusts the entire array again to have it at the first index for evaluation

print:
#Prints the hand that you have available mainly for reference an checking, will be removed later
	li $t0, 5
	
printLoop:
	lw $a0, 0($s0)
	li $v0, 1
	syscall
	addi $s0, $s0, 4
	addi $t0, $t0, -1
	la $a0, space
	li $v0 4
	syscall
	bgtz $t0, printLoop

addi $s0, $s0, -20	#Needed to readjust where the array is currently indexing at
li $t4, 5	#Sets up a loop reference to count how many havce passed, need only 5 at the moment


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
## $t1 where the value is. When it branches, it jumps down to where the label next to it is and prints the card.		 ##
###################################################################################################################################

	cardReader:
		beqz $t1, zero	#Branches to zero if $t1 is zero
		li $t3, 1	#Loads the next number to compare to
		beq $t1, $t3, one
		li $t3, 2
		beq $t1, $t3, two
		li $t3, 3
		beq $t1, $t3, three
		li $t3, 4
		beq $t1, $t3, four
		li $t3, 5
		beq $t1, $t3, five
		li $t3, 6
		beq $t1, $t3, six
		li $t3, 7
		beq $t1, $t3, seven
		li $t3, 8
		beq $t1, $t3, eight
		li $t3, 9
		beq $t1, $t3, nine
		li $t3, 10
		beq $t1, $t3, ten
		li $t3, 11
		beq $t1, $t3, eleven
		li $t3, 12
		beq $t1, $t3, twelve
		
		#The next section is where the branches go to where it prints out the number or letter for the value of the card by
		#loading the address of the label in the .data section, when it is evaluated it always branches to the next step
		zero:
			la $a0, Two	#Loads the string to print
			li $v0, 4	#Preps to print
			syscall		#Prints out the string from Two
			b suiteEval	#Branches to the next section of the evaluation
		one:
			la $a0, Three
			li $v0, 4
			syscall
			b suiteEval
		two:
			la $a0, Four
			li $v0, 4
			syscall
			b suiteEval
		three:
			la $a0, Five
			li $v0, 4
			syscall
			b suiteEval
		four:
			la $a0, Six
			li $v0, 4
			syscall
			b suiteEval
		five:
			la $a0, Seven
			li $v0, 4
			syscall
			b suiteEval
		six:
			la $a0, Eight
			li $v0, 4
			syscall
			b suiteEval
		seven:
			la $a0, Nine
			li $v0, 4
			syscall
			b suiteEval
		eight:
			la $a0, Ten
			li $v0, 4
			syscall
			b suiteEval
		nine:
			la $a0, Jack
			li $v0, 4
			syscall
			b suiteEval
		ten:
			la $a0, Queen
			li $v0, 4
			syscall
			b suiteEval
		eleven:
			la $a0, King
			li $v0, 4
			syscall
			b suiteEval
		twelve:
			la $a0, Ace
			li $v0, 4
			syscall
			b suiteEval
			
	#This next section uses the register $t2 for the suits of the card using the same method as above by first comparing the 
	#register to zero and then incrementing to the top possible value
	suiteEval:
		beqz $t2, clubs	#Branches to clubs if the register has a zero
		li $t3, 1	#Loads 1 to the same register $t3 to increment comparing values
		beq $t2, $t3, diamonds
		li $t3, 2
		beq $t2, $t3, hearts
		li $t3, 3
		beq $t2, $t3, spades
		
		#Next section is for printing the suit in parentheses next to its value, similar to the value prints section
		clubs:
			la $a0, Clubs	#Loads the Clubs string in the .data section to print
			li $v0, 4	#Preps to print to the console
			syscall		#Prints the string
			b nextCard	#Branches out the next section needed
		diamonds:
			la $a0, Diamonds
			li $v0, 4
			syscall
			b nextCard
		hearts:
			la $a0, Hearts
			li $v0, 4
			syscall
			b nextCard
		spades:
			la $a0, Spades
			li $v0, 4
			syscall
			b nextCard
			
	#Next is where the total number of cards left is decremented and the index of hte array is incremented and it branches if
	#there are still cards to be evaluated
	nextCard:
	addi $t4, $t4, -1	#Decrements number of cards left
	addi $s0, $s0, 4	#Increments to the next index in the array
	bgtz $t4 card		#Branches back to card for the next card evaluation
	
	
###################################################################################################
# This next section will evaluate the hand, and tell you what kind of hand it is. Soon it will be #
# tell you wether or not you have won comparitavley to another hand				  #
###################################################################################################
addi $s0, $s0, -20
la $t3, 0	#Zeros out another temporary to account for the needed looping to find when the hand needs to be sorted
handLoop:
la $t1, 0	#Zeros out $t1 to be the counter for suit
bge $t3, 5, preSort	#If the loop has gone through and evaluated all of the cards it goes to the PreSorting section of code
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
mul $t3, $t3, -4	#Multiplies the counter by -4, to adjust to the beginning of te arrays
add $s0, $s0, $t3	#Adjusts the face value array back to the original position
add $s1, $s1, $t3	#Adjusts the suit value array back to the original position
div $t3, $t3, -4	#Divides the counter by -4 to get the counter back
addi $t3, $t3, -2	#Subtracts 2 from the counter, to account for the two cards out being compared to each other
			#so we can sort them
la $t4, 0	#Zeroes out an array tracking counter and also to compare to the $t3 counter when finished sorting

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
mul $t4, $t4, -4	#Multiplies the coutner by -4 to find the adjustment needed to get to the beginning of the arrays
add $s0, $s0, $t4	#Decrements the face value array to the starting position
add $s1, $s1, $t4	#Decrements the suit value array to the starting position
li $t5, 0	#Zeros out a counter for hand position
li $t3, 0

#Evaluates if the hand has any pairs
pairEval:
bge $t5, 5, nextChecker	#If the entire hand has been proccessed it goes to the nextChecker label
addi $t5, $t5, 1	#Adds 1 to the counter
lw $t0, 0($s0)	#Loads the next face value from the array
lw $t1, 4($s0)	#Loads the face value from the array, after the first
beq $t0, $t1, isPair	#If they are equal to each other it branches to the isPair label to find out what kind
addi $s0, $s0 4	#If reached it increments the face value array to evaluate the next possible pair
b pairEval	#Branches back to another iteration of pairEval

#If there was a successful pair
isPair:
beq $t1, $t2, threeOf	#If the latest card in the "matching pair" is equal to a previous possible pair, it branches to threeOf
			#to be processed as a three of a kind at least
bgtz $t3, twoPair	#If there was pre-determined pair or more, seen by having $t3 larger than zero
li $t3, 1	#If it is reached, by having no prior matchings, it increments $t3, for later use, if another match if found
move $t2, $t0	#Moves the first card's value into $t2, also to be used later for more possible matches
addi $s0, $s0, 4	#Increments the array
b pairEval	#Branches back to evaluate another possible pair
		
#If there were two different pairs found
twoP:
beq $t3, 3, fullHouse	#Checks to see if $t3 equals 3, later can be seen in three of a kind, to see if this makes a full house
			#If so, it branches to that label
li $t3, 2	#Loads 2, into $t3 to show there was another pair
move $t2, $t1	#Moves the matching card's value into $t2, for another possible match
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


#This section executes only if a match of two cards has not been found, if even a pair exists it is impossible to have a straight
#or a flush, hence why his is after it checks for pairs
possibleStraight:
beqz $t5, possibleStFlush	#If the counter gets all the way down to zero, going  through each card, it branches 
				#to check for a straight flush
lw $t0, 0($s0)	#Loads the next face card value from the array
lw $t1, 4($s0)	#Loads the face card value after in the array
addi $t0, $t0, 1	#Increments the face card value by one
bne $t0, $t1, possibleFlush	#If any of the two numbers do not equal, after the first being incremented, it branches to a flush
				#checker since a straigh would be impossible if this were true
addi $s0, $s0, 4	#Increments the face value array to the next card
addi $t5, $t5, -1	#Decrements the counter by one
b possibleStraight	#Branches back to the possibleStraight area

#Executes if there is a possibility if there is a straight flush
possibleStFlush:
li $t3, 5	#Loads 5 into $t3, to identify it as a straight at least in this stage
li $t5, 5	#Re increments the counter back to 5 to count down from

#Checks for a possible flush
possibleFlush:
beqz $t5, flushType	#Checks if the counter is at zero, if it is it goes to flush type
lw $t0, 0($s1)	#Loads the next suit value
lw $t1, 4($s1)	#Loads the suit value after the first
bne $t0, $t1, handType	#If the two values do not match then it skips down to handType
addi $s1, $s1, 4	#Increments the suit array to the next value
addi $t5, $t5, -1	#Decrements the counter by one
b possibleFlush	#Brances back to possibleFlush

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
li $v0, 4	#Preps to print a string
la $a0, HighCard	#Loads the appropriate hand string and prints it
syscall	#Prints the String
b exit	#Branches to exit for now, will probably be altered later to loop back and also to give pot values to the winner, after
	#of course it compares two values(player or computer hands) to each other

pair:
li $v0, 4
la $a0, Pair
syscall
b exit

twoPair:
li $v0, 4
la $a0, TwoPair
syscall
b exit

threeKind:
li $v0, 4
la $a0, ThreeOfAKind
syscall
b exit

straight:
li $v0, 4
la $a0, Straight
syscall
b exit

flushType:
beq $t3, 5, possibleRoyalFlush	#If it was a straight flush then it checks for a royal flush
#If it wasn't a straight flush then it just goes into the normal flush print out

fullHouse:
li $v0, 4
la $a0, FullHouse
syscall
b exit

fourOfaKind:
li $v0, 4
la $a0, FourOfAKind
syscall
b exit

possibleRoyalFlush:
addi $s0, $s0, -20	#Redecrements the face value card array to the begginning
lw $t0, 0($s0)	#Loads the very first card
beq $t0, 9, royalFlush	#If the card is equal to 9(really the face value of 10) and it is a straight flush it is a royal flush

li $v0, 4
la $a0, Flush
syscall
b exit

royalFlush:
li $v0, 4
la $a0, RoyalFlush
syscall

#This last bit is for exiting out of the program
exit:
	li $v0, 10	#Preps to kill the program
	syscall	#Kills the program

