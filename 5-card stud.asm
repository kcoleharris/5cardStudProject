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
		bleu $t1, 12, cardReader	#If the value is less than or equal to 12 it branches to the next step
		addi $t1, $t1, -12	#Reduces the number by 12
		addi $t2, $t2, 1	#Increments $t2, which keeps up with the suit, by 1 if it doesn't branch
		b cardReducerLoop	#Branches back to be re-evaluated
		
################################################################################################################
#This part is used to translate one of the two remaining temporaries needed to the card value 
#It uses branching, first from zero, then it uses another register to incriment though I constantly use load to avoid having
#left over number that may accidently trigger a branch where it shouldn't, and compare to the same $t1 where the value is
#When it branches, it jumps down to where the label is
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
		li $t2, 3
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
la $t1, 0	#Zeros out $t1 to be the counter for suit
la $t3, 0
handLoop:
bgt $t3, 5, preSort
lw $t0, 0($s0)	#This loads the first card number
ble $t0, 11, skip
jal reduce
skip:
sw $t0, 0($s0)
sw $t1, 0($s1)
addi $s0, $s0, 4
addi $s1, $s1, 4
addi $t3, $t3, 1
la $t1, 0
j handLoop

reduce:
addi $t0, $t0, -11
addi $t1, $t1, 1
bgt $t1, 11, reduce
jr $ra

#Sets up for sorting so the hand can be evaluated
preSort:
mul $t3, $t3, -4
add $s0, $s0, $t3
add $s1, $s1, $t3
div $t3, $t3, -4
addi $t3, $t3, -2
la $t4, 0

#This is the sorting section of the program so it easier to evaluate the hand later, sorts by their face value, not suits
sort:
lw $t0, 0($s0)
lw $t1, 4($s0)
bgt $t3, $t4, postSort
blt $t1, $t0, swap
addi $s0, $s0, 4
addi $s1, $s1, 4
addi $t4, $t4, 1

#Swaps the registers that keeps up with the cards and their suits
swap:
sw $t0, 4($s0)
sw $t1, 0($s0)
lw $t0, 0($s1)
lw $t1, 4($s1)
sw $t0, 4($s1)
sw $t1, 0($s1)
mul $t4, $t4, -4
add $s0, $s0, $t4
add $s1, $s1, $t4
la $t4, 0
j sort

postSort:
mul $t4, $t4, -4
add $s0, $s0, $t4
add $s1, $s1, $t4
li $t5, 0

pairEval:
bgt $t5, 5, nextChecker
lw $t0, 0($s0)
lw $t1, 4($s0)
beq $t0, $t1, isPair
addi $s0, $s0 4
addi $t5, $t5, 1
b pairEval

isPair:
beq $t1, $t2, threeOf
bgtz $t3, twoPair
li $t3, 1
move $t2, $t0
addi $s0, $s0, 4
b pairEval
		
twoP:
beq $t3, 3, fullHouse
li $t3, 2
li $t4, 1
move $t2, $t1
addi $s0, $s0, 4
b pairEval
	
threeOf:
beq $t3, 3, fourOfaKind
beq $t3, 2, fullHouse
li $t3, 3
addi $s0, $s0, 4
b pairEval

nextChecker:
bgtz $t3, handType
mul $t5, $t5, -4
add $s0, $s0, $t5
div $t5, $t5, -4

possibleStraight:
beqz $t5, possibleStFlush
lw $t0, 0($s0)
lw $t1, 4($s0)
addi $t0, $t0, 1
bne $t0, $t1, possibleFlush
addi $s0, $s0, 4
addi $t5, $t5, -1
b possibleStraight

possibleStFlush:
li $t3, 5
li $t5, 5

possibleFlush:
beqz $t5, flushType
lw $t0, 0($s1)
lw $t1, 4($s1)
bne $t0, $t1, handType
addi $s1, $s1, 4
addi $t5, $t5, -1
b possibleFlush

handType:
beqz $t3, highCard
beq $t3, 1, pair
beq $t3, 2, twoPair
beq $t3, 3, threeKind
beq $t3, 5, straight

highCard:
li $v0, 4
la $a0, HighCard
syscall
b exit

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
beq $t3, 5, possibleRoyalFlush
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
addi $s0, $s0, -20
lw $t0, 0($s0)
beq $t0, 9, royalFlush

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

