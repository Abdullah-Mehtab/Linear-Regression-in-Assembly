.data
buffer:  .space 1024      # Buffer to store the read string
filename: .asciiz "data/test.csv"
all_data: .space 1024  # Adjust the size based on the maximum number of rows and columns
train_data: .space 1024
test_data: .space 512

averages: .space 64    # 1-D Array of averages
numerator:   .space 64  # 1-D Array of numerators
denominator: .space 64  # 1-D Array of denominators

weights:   .space 256 # 1-D Array of weights after Linear Regression

predicted: .space 256 # 1-D Array of predicted elements

# For Printing Output in a clean way
raww: .asciiz "Data read from file:\n"
formatted_raww: .asciiz "\nGiven Data (ignore empty X values):\nY\tX1\tX2\tX3"
num_rows: .asciiz "\n\nRows: "
num_cols: .asciiz "\nCols: "

trained: .asciiz "\nTrain Data: \n"
tested: .asciiz "\nTest Data: \n"
average: .asciiz "\nAverages:\n"
weight: .asciiz "Weights:\n"
formula: .asciiz "\n\nFormula:\nY = b0 + x1 * b1 + x2 * b2 . . . xn * bn\nY = "
plusX:  .asciiz " + (X"
actual: .asciiz "\nActual: "
predicc: .asciiz "\tPredicted: "

Goodbye: .asciiz "\n\n  |\\_/|   ****************************  (\\_/)\n / @ @ \\  *     Project Complete!    * (='.'=)\n( > º < ) *         Goodbye!         * (')_(')\n `>>x<<´  *     (Abdullah Mehtab)    *\n /  O  \\  *"
# For printing testing data (self-help and debugging)

calc1: .asciiz " -> "
calc2: .asciiz " = "
calc3: .asciiz " - "
calc4: .asciiz " * "
calc5: .asciiz " || "
calc6: .asciiz " / "
calc7: .asciiz " += "
calc8: .asciiz " => "

Nummy: .asciiz "\nNummy: "
Dummy: .asciiz "\nDummy: "

# randy: .asciiz "\nRandy: "
# trainy: .asciiz "\nTrainy (t4): "
# testy: .asciiz "\nTesty (t5): "

.text
main:
    # UDF-1 (Assignment 2 :v)
    jal ReadnStore
    # UDF-2 
    jal test_train_data
    # UDF-3
    jal linRegression
    # UDF-4
    jal testModel

    li $v0, 4
    la $a0, Goodbye
    syscall

    j Exit

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # UDF-1 --> Read Raw data, convert to integer and store in Matrix # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

ReadnStore:
    # Open the file for reading
    li $v0, 13            # System call code for open file
    la $a0, filename      # Load the address of the filename
    li $a1, 0             # Flags: read-only
    li $a2, 0             # Mode: not needed for reading
    syscall

    move $s0, $v0         # Save the file descriptor

    # Read from the file
    li $v0, 14            # System call code for read from file
    move $a0, $s0         # File descriptor
    la $a1, buffer        # Buffer to store the read string
    li $a2, 1024          # Maximum number of bytes to read
    syscall

    # Print the read string
    li $v0, 4             
    la $a0, raww
    syscall
    
    li $v0, 4             
    la $a0, buffer
    syscall
    move $a2, $a0 # a2 = file's data

    # Close the file
    li $v0, 16            # System call code for close file
    move $a0, $s0         # File descriptor
    syscall
    
    # Store 1st byte (which is telling number of rows)
    lb $s0, 0($a2) # Row
    sub $s0, $s0, 48 # Conv to integer
    
    # Check if number of rows is in 'TENS' || If next chr is a comma, its ONES.
    addi $a2, $a2, 1 # Check next bit
    lb $s2, 0($a2)
    beq $s2, ',', ignoreA 
    
    sub $s2, $s2, 48 # Conv to integer
    mul $s3, $s0, 10 # Previous integer was in TENS
    addi $a2, $a2, 1
    add $s0, $s2, $s3 # Store Integer (in tens) in 's0' (number of rows)
 		
    ignoreA:
    # Display number of rows
    li $v0, 4             
    la $a0, num_rows
    syscall
        
    li $v0, 1           
    move $a0, $s0 # s0 = Number of Rows
    syscall
    
    li $v0, 11          
    la $a0, '\n'
    syscall  
    
    # Do the same for columns
    addi $a2, $a2, 1 # Ignore the comma
    lb $s1, 0($a2)# Col
    sub $s1, $s1, 48
    
    li $v0, 4             
    la $a0, num_cols
    syscall
    
    li $v0, 1            
    move $a0, $s1 # s1 = Number of Cols
    syscall
    
    li $v0, 11          
    la $a0, '\n'
    syscall  
    
    addi $a2, $a2, 3 # jump the col-integer and nextline chr
    # Remove semi-colons from the input string and print it with tabs

    move $t9, $a2 # Save buffer's address in t9 constant for later use
    move $t1, $a2 # Address of the input string

    li $v0, 4             
    la $a0, formatted_raww
    syscall
    
    # # This printer is printing data directly from the buffer in a formatted order

    # print_formattedCHR:
    #    lb $t2, 0($t1) # Load a character from the input string

    #    # Check if the end of the input string is reached
    #    beqz $t2, forwardA

    #    # Check if the character is a comma
    #    beq $t2, ',', print_tab
    #    # Print the character that is not a space
    #    li $v0, 11
    #    move $a0, $t2
    #    syscall
    #    # Move to the next character in the input string
    #    addi $t1, $t1, 1
    #    j print_formattedCHR

    #    print_tab:
	#    li $v0, 11        
	#    la $a0, '\t'
	#    syscall

    #        # Move to the next character in the input string
    #        addi $t1, $t1, 1
    #        j print_formattedCHR
            
    #forwardA:
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # Raw work is done, now actual programming and calculating  #
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    li $v0, 11   
    la $a0, '\n'
    syscall

    # li $t6, 0 # Counter and checker for --> s0 = Number of Rows
    # li $t7, 0 # Counter and checker for --> s1 = Number of Cols

    move $t1, $t9 # Address of the input string
    la $t8, all_data 
    li $t7, 0 # Flag to check TENS or ONES in integers (2 = TENS, 1 = ONES)

    save_matt:
            lb $t2, 0($t1) # Load a character from the input string

        beqz $t2, forwardB
        
            beq $t2, '\n', reset_flag
            beq $t2, ',', reset_flag

            # Move to the next character in the input string
            addi $t1, $t1, 1

        # If current char is not "\n", comma, or null.. its an integer
        subi $t2, $t2, 48
        beq $t2, -35, reset_flag # weird bug?
        
        addi $t7, $t7, 1

        # If integer is in ONEs (t7 = 1) --- save and jump ahead
        beq $t7, 1, save_ones
        # Else
        addi $t8, $t8, -4 # Move to previous integer in array
        lw $t3, 0($t8)    # Load it
        mul $t3, $t3, 10  # Mul by 10
        add $t2, $t2, $t3 # Add current integer

        sw $t2, 0($t8)    # Save it back
        addi $t8, $t8, 4
        j save_matt
        
    save_ones:
        andi $t8, $t8, -4
        
        sw $t2, 0($t8) # Matrix[row][col] = t2 (integer)
        addi $t8, $t8, 4
        j save_matt
        
    reset_flag:
        li $t7, 0 # Reset Flag
        addi $t1, $t1, 1
        j save_matt

        
    forwardB:
        # Display the matrix

        #--> s0 = Number of Rows
        #--> s1 = Number of Cols

        la $t2, all_data    # $t2 = address of matrix
        li $t3, 0        # Initialize row index

        # Loop through rows
        display_matrix:
            li $t4, 0    # Initialize column index

            # Loop through columns
            display_row:
                # Load the matrix element
                andi $t2, $t2, -4    # Align to the previous word boundary
                lw $a0, 0($t2)           # $a0 = matrix[row][column]

                # Print the matrix element
                li $v0, 1            
                syscall

                # Print tab
                li $v0, 11
                la $a0, '\t'
                syscall

                # Move to the next column
                addi $t4, $t4, 1
                addi $t2, $t2, 4          # Move to the next element in the matrix

                # Check if we have reached the end of the row
                bne $t4, $s1, display_row

            # Print newline
            li $v0, 11
            la $a0, '\n'
            syscall

            # Move to the next row
            addi $t3, $t3, 1

            # Check if we have reached the end of the matrix
            bne $t3, $s0, display_matrix

jr $ra

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # UDF-2 --> Divide 80% of Matrix for Training and 20% for Testing # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

test_train_data:
    la $t9, all_data
    la $t8, train_data
    la $t7, test_data

    mul $s2, $s0, 8 # 80% for TRAIN
    div $s2, $s2, 10 # Save for printing later
    move $t4, $s2

    mul $s3, $s0, 2 # 20% for TEST
    div $s3, $s3, 10
    move $t5, $s3 # Save for printing later

    # Loop through All_Data and store in test-train randomly 
    divide_data:
        # (MARS random number generator)
    	li $a1, 2  #Here you set $a1 to the max bound.
        li $v0, 42  #generates the random number.
        syscall
        #add $a0, $a0, 100  #Here you add the lowest bound
        move $s7, $a0 # s7 has random number in it
        
        # li $v0, 4
        # la $a0, randy
        # syscall
            
        # li $v0, 1
        # move $a0, $s7
        # syscall
            
        # li $v0, 4
        # la $a0, trainy
        # syscall
            
        # li $v0, 1
        # move $a0, $t4
        # syscall
            
        # li $v0, 4
        # la $a0, testy
        # syscall
            
        # li $v0, 1
        # move $a0, $t5
        # syscall
            
        # If s7 = 0 --> Include current row in train_data
        beqz $s7, include_in_train_data
        # else s7 = 1 --> Include current row in test_data
        j include_in_test_data

    include_in_train_data:
        # Check if 80% of rows from ALL are filled in TRAIN
        beqz, $t4, end_train

        # Copy the row from ALL_Data to Train_Data
        li $t3, 0 # Counter to check if all items in row were saved (using columns)
        addi $t4, $t4, -1 # One Row in TRAIN filled
        copy_rowTR:
            # If Counter == Num of Cols
            beq $t3, $s1, divide_data # Row Copied!

	    andi $t9, $t9, -4
	    andi $t8, $t8, -4
            lw $t2, 0($t9) # Load Element from ALL
            sw $t2, 0($t8) # Save in TRAIN

            addi $t9, $t9, 4 # Goto next element in ALL
            addi $t8, $t8, 4 # Goto next element in TRAIN
            addi $t3, $t3, 1 # Counter += 1

            j copy_rowTR 

    include_in_test_data:
        # Check if 20% of rows from ALL are filled in TEST
        beqz, $t5, end_test

        # Copy the row from ALL_Data to Train_Data
        li $t3, 0 # Counter to check if all items in row were saved (using columns)
        addi $t5, $t5, -1 # One Row in TEST filled
        copy_rowTS:
            # If Counter == Num of Cols
            beq $t3, $s1, divide_data # Row Copied!

	    andi $t9, $t9, -4
	    andi $t7, $t7, -4
            lw $t2, 0($t9) # Load Element from ALL
            sw $t2, 0($t7) # Save in TRAIN

            addi $t9, $t9, 4 # Goto next element in ALL
            addi $t7, $t7, 4 # Goto next element in TRAIN
            addi $t3, $t3, 1 # Counter += 1

            j copy_rowTS

    end_train:
        # Check if 20% of test data is complete too
        beqz $t5, end_divide_data
        # Otherwise loop again
        j divide_data

    end_test:
        # Check if 80% of train data is complete too
        beqz $t4, end_divide_data
        # Otherwise loop again
        j divide_data

    end_divide_data:
        # Display the Train and Test Data
        
        # First Display Train
        la $t2, train_data  
        li $t3, 0        # Initialize row index

        li $v0, 4
        la $a0, trained
        syscall        

        # Loop through rows
        display_matrixTR:
            li $t4, 0    # Initialize column index

            # Loop through columns
            display_rowTR:
                # Load the matrix element
                andi $t2, $t2, -4    # Align to the previous word boundary
                lw $a0, 0($t2)           # $a0 = matrix[row][column]

                # Print the matrix element
                li $v0, 1            
                syscall

                # Print tab
                li $v0, 11
                la $a0, '\t'
                syscall

                # Move to the next column
                addi $t4, $t4, 1
                addi $t2, $t2, 4          # Move to the next element in the matrix

                # Check if we have reached the end of the row
                bne $t4, $s1, display_rowTR

            # Print newline
            li $v0, 11
            la $a0, '\n'
            syscall

            # Move to the next row
            addi $t3, $t3, 1

            # Check if we have reached the end of the matrix
            bne $t3, $s2, display_matrixTR # s2 = Rows in TRAIN Data


        # Display Test
        la $t2, test_data  
        li $t3, 0        # Initialize row index

        li $v0, 4
        la $a0, tested
        syscall        

        # Loop through rows
        display_matrixTS:
            li $t4, 0    # Initialize column index

            # Loop through columns
            display_rowTS:
                # Load the matrix element
                andi $t2, $t2, -4    # Align to the previous word boundary
                lw $a0, 0($t2)           # $a0 = matrix[row][column]

                # Print the matrix element
                li $v0, 1            
                syscall

                # Print tab
                li $v0, 11
                la $a0, '\t'
                syscall

                # Move to the next column
                addi $t4, $t4, 1
                addi $t2, $t2, 4          # Move to the next element in the matrix

                # Check if we have reached the end of the row
                bne $t4, $s1, display_rowTS

            # Print newline
            li $v0, 11
            la $a0, '\n'
            syscall

            # Move to the next row
            addi $t3, $t3, 1

            # Check if we have reached the end of the matrix
            bne $t3, $s3, display_matrixTS # s3 = Rows in TEST Data


jr $ra

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # UDF-3 --> Train the data using Linear Regression (find weights) # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

linRegression:

    # Print the Average of each column while storing in an Array
    li $v0, 4      
    la $a0, average
    syscall

    la $t0, train_data
    la $t2, averages
    li $t4, 0 # Counter of how many columns have been calculated

    # Store the number of ROWS (in train) as a FLOAT (to be divided for average)
    mtc1 $s2, $f0 # s2 --> f0
    cvt.s.w $f0, $f0
    
    print_col_sum_loop:
        li $t6, 0
        li $t3, 0
        li $t9, 0 # Helper temporary variable
        
        compute_col_sum_loop:
            andi $t0, $t0, -4    # Align to the previous word boundary
            lw $t5, 0($t0)
            add $t6, $t6, $t5

            # Next column jumper checker
    	    mul $t9, $s1, 4
            # Move to the next column
            add $t0, $t0, $t9
            addi $t3, $t3, 1

            # Check if we have reached the end of the matrix
            bne $t3, $s2, compute_col_sum_loop

        # Divide the sum of the column by the number of rows (to get average)
        # We need answer in float hence converting sum (int) to float
        mtc1 $t6, $f1 # f2 = t6
    	cvt.s.w $f1, $f1
    	
        div.s $f2, $f1, $f0 # Divide the SUM by nROWs for AVG and store result in $f2

        # Print the result (f12 for floats is same as a0 for integers)
        li $v0, 2          # Syscall for printing float
        mov.s $f12, $f2    # Load the float value to be printed into $f12 
        syscall   

        # Save the result in Average Array (It has 1-to-1 Correspondence to Train_Data's Columns)
        andi $t2, $t2, -4    # Align to the previous word boundary
        s.s $f2, 0($t2)
        addi $t2, $t2, 4     # Jump to next item in averages array

        # Print tab
        li $v0, 11
        la $a0, '\t'
        syscall        
       
        # Counter += 1
        addi $t4, $t4, 1
         
        # Move to the next column's first row
        la $t0, train_data
        mul $t9, $t4, 4
        add $t0, $t0, $t9

        # Check if we have reached the end of the columns
        bne $t4, $s1, print_col_sum_loop

    # # Display Float Array of Averages ONCE again (testing array has stored values correctly or not)
    # li $v0, 11
    # la $a0, '\n'
    # syscall   

    # li $v0, 4      
    # la $a0, average
    # syscall

    # la $t2, averages
    # # Size of Array = Number of columns --> is constant --> t1
    # move $a2, $s1

    # avg_arr_display:
    #     andi $t2, $t2, -4 

    #     li $v0, 2            # System call code for printing float
    #     lwc1 $f12, 0($t2)    # Load the float value from the array into $f12
    #     syscall            

    #     li $v0, 11
    #     la $a0, '\t'
    #     syscall        

    #     addi $t2, $t2, 4     # Move to the next element in the array
    #     sub $a2, $a2, 1      # Decrement the loop counter

    #     bnez $a2, avg_arr_display      

        li $v0, 11
        la $a0, '\n'
        syscall
	
	# Calculate Numerator and Denominator
	la $t0, train_data # Simple traversal
	la $a1, train_data # For Y values (using columns)
	la $t3, averages
	la $t4, numerator
	la $t5, denominator
	
	li $t1, 0
	li $t2, 0
	
	# Load Y-bar in f0 (constant)
	andi $t3, $t3, -4
	l.s $f0, 0($t3)

	# Load f10 = 1.0 (small helper float)
	li $t9, 1
	mtc1 $t9, $f10 # Convert integer to FLOAT
	cvt.s.w $f10, $f10
	# Save 1.0 in Average list (as first element)
	s.s $f10, 0($t3)	

        # Debugger (Element moving too far ahead during first iteration, so forcing it back)
	mul $t6, $s1, -4
        add $a1, $a1, $t6
        
	Iterate_train:
	    # First element of each row (Y elements in TRAIN)
	    mul $a2, $s1, 4
	    add $a1, $a1, $a2
            andi $a1, $a1, -4   # Align to the previous word boundary
            lw $t6, 0($a1)
            mtc1 $t6, $f20      # Convert integer to FLOAT
       	    cvt.s.w $f20, $f20
        Iterate_elements:
            # Ybar = f0
            sub.s $f3, $f20, $f0 # Y_Diff
            
            # Jump to next item in array 
            # addi $t0, $t0, 4
            # addi $t3, $t3, 4
            
            andi $t0, $t0, -4    # Align to the previous word boundary
            lw $t6, 0($t0)
            mtc1 $t6, $f11 # Convert integer to FLOAT
       	    cvt.s.w $f11, $f11
            
            andi $t3, $t3, -4
            l.s $f2, 0($t3) # Load average as float
            
            sub.s $f4, $f11, $f2 # X_Diff
                
            # Jump to next item in array
            addi $t0, $t0, 4
            addi $t3, $t3, 4
            
            # Save Numerator 
            mul.s $f5, $f3, $f4
            
            andi $t4, $t4, -4
            l.s $f6, 0($t4) # Load Element as float
        
            add.s $f6, $f6, $f5
        
            s.s $f6, 0($t4) # Save Element as float
            
            addi $t4, $t4, 4
                
            # Save Denominator
            mul.s $f7, $f4, $f4
            
            andi $t5, $t5, -4
            l.s $f8, 0($t5) # Load Element as float

            add.s $f8, $f8, $f7
        
            s.s $f8, 0($t5) # Save Element as float

            addi $t5, $t5, 4
            addi $t1, $t1, 1 # Col counter
            
            # # Debug printer
            # li $v0, 11
            # la $a0, '\n'
            # syscall
            
            # li $v0, 1
            # move $a0, $t2
            # syscall
            
            # li $v0, 11
            # la $a0, ' '
            # syscall
            
            # li $v0, 1
            # move $a0, $t1
            # syscall
            
            # li $v0, 4      
            # la $a0, calc1
            # syscall

            # li $v0, 2
            # mov.s $f12, $f3
            # syscall
            
            # li $v0, 4      
            # la $a0, calc2
            # syscall

            # li $v0, 2
            # mov.s $f12, $f20
            # syscall
            
            # li $v0, 4      
            # la $a0, calc3
            # syscall

            # li $v0, 2
            # mov.s $f12, $f0
            # syscall
          
            # li $v0, 4      
            # la $a0, calc5
            # syscall
            
            # li $v0, 2
            # mov.s $f12, $f4
            # syscall
            
            # li $v0, 4      
            # la $a0, calc2
            # syscall

            # li $v0, 2
            # mov.s $f12, $f11
            # syscall
            
            # li $v0, 4      
            # la $a0, calc3
            # syscall

            # li $v0, 2
            # mov.s $f12, $f2
            # syscall
            
            # li $v0, 11
            # la $a0, '\n'
            # syscall
            
            # li $v0, 1
            # move $a0, $t2
            # syscall
            
            # li $v0, 11
            # la $a0, ' '
            # syscall

            # li $v0, 1
            # move $a0, $t1
            # syscall
            
            # li $v0, 4      
            # la $a0, calc1
            # syscall

            # li $v0, 2
            # mov.s $f12, $f5
            # syscall

            # li $v0, 11
            # la $a0, '\t'
            # syscall

            # li $v0, 11
            # la $a0, '"'
            # syscall

            # li $v0, 2
            # mov.s $f12, $f6
            # syscall

            # li $v0, 11
            # la $a0, '"'
            # syscall
            
            # li $v0, 4      
            # la $a0, calc5
            # syscall
            
            # li $v0, 2
            # mov.s $f12, $f7
            # syscall

            # li $v0, 11
            # la $a0, '\t'
            # syscall

            # li $v0, 11
            # la $a0, '"'
            # syscall

            # li $v0, 2
            # mov.s $f12, $f8
            # syscall

            # li $v0, 11
            # la $a0, '"'
            # syscall
	        # # Debug printer
            
            bne $t1, $s1, Iterate_elements
         
        # Reset Addresses
        la $t3, averages
        la $t4, numerator
        la $t5, denominator

        li $t1, 0 # Reset Col counter
        addi $t2, $t2, 1

        bne $t2, $s2, Iterate_train

# # # # # # # # # #
    # # Print numerator and denominaotr (to check)
    # li $v0, 11
    # la $a0, '\n'
    # syscall

    # la $t1, numerator
    # la $t2, denominator

    # # Size of Array = Number of columns --> is constant --> s1
    # move $a2, $s1

    # numdem_display:
    #     andi $t1, $t1, -4 
    #     andi $t2, $t2, -4 
        
    # 	li $v0, 4
    # 	la $a0, Nummy
    # 	syscall
    
    #     li $v0, 2            # System call code for printing float
    #     lwc1 $f12, 0($t1)    # Load the float value from the array into $f12
    #     syscall            

    # 	li $v0, 4
    # 	la $a0, Dummy
    # 	syscall
    
    #     li $v0, 2            # System call code for printing float
    #     lwc1 $f12, 0($t2)    # Load the float value from the array into $f12
    #     syscall 

    #     li $v0, 11
    #     la $a0, '\t'
    #     syscall        

    #     addi $t1, $t1, 4     # Move to the next element in the array
    #     addi $t2, $t2, 4     # Move to the next element in the array
    #     sub $a2, $a2, 1      # Decrement the loop counter

    #     bnez $a2, numdem_display      

    # Calculate and Store weights 

    la $t0, weights
    la $t1, numerator
    la $t2, denominator

    # Save a NULL Float (to prevent 0 division)
    mtc1 $zero, $f3
    cvt.s.w $f3, $f3
    
    li $t3, 0

    Calculate_weight:
        beq $t3, $s1, end_calc_weight

	andi $t2, $t2, -4
	andi $t1, $t1, -4
	andi $t0, $t0, -4
	
	lw $t4, 0($t2) 
        # If Denominator is zero, store as weight (because cant divide)
        beqz $t4, null_element
        # Else
        l.s $f1, 0($t2) # Load Float (Denominator)
        l.s $f2, 0($t1) # Load Float (Numerator)

        div.s $f4, $f2, $f1

        # # Debug Printer
        # li $v0, 11
        # la $a0, '\n'
        # syscall

        # li $v0, 1
        # move $a0, $t3
        # syscall

        # li $v0, 4
        # la $a0, calc1
        # syscall

        # li $v0, 2
        # mov.s $f12, $f4
        # syscall

        # li $v0, 4
        # la $a0, calc2
        # syscall

        # li $v0, 2
        # mov.s $f12, $f2
        # syscall

        # li $v0, 4
        # la $a0, calc6
        # syscall

        # li $v0, 2
        # mov.s $f12, $f1
        # syscall

        # li $v0, 11
        # la $a0, '\n'
        # syscall
        # # Debug Printer

        s.s $f4, 0($t0) # Save Float (Weights)

        # Jump to next elements
        addi $t0, $t0, 4
        addi $t1, $t1, 4
        addi $t2, $t2, 4
        addi $t3, $t3, 1

        j Calculate_weight

    null_element:
        # Save the null element in weights
        s.s $f1, 0($t0)

        # Jump to next elements
        addi $t0, $t0, 4
        addi $t1, $t1, 4
        addi $t2, $t2, 4
        addi $t3, $t3, 1

        j Calculate_weight

    end_calc_weight:

    # Find Y slope-intercept (b0) || First element in weights (fix value)

    la $t0, weights
    la $t1, averages
    # Jump to second element
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    
    la $t2, 1 # Col counter

    mov.s $f30, $f0 # Save Ybar in temp (to be changed and stored as b0)

    Find_intercept:
        beq $t2, $s1, Found_intercept
    
        andi $t1, $t1, -4
        andi $t0, $t0, -4
    
        l.s $f1, 0($t0) # Load element in weights
        l.s $f2, 0($t1) # Load corresponding X-bar (average)

        mul.s $f3, $f1, $f2

        sub.s $f30, $f30, $f3

        # # Debug Printer
        # li $v0, 11
        # la $a0, '\n'
        # syscall

        # li $v0, 1
        # move $a0, $t2
        # syscall

        # li $v0, 4
        # la $a0, calc1
        # syscall

        # li $v0, 2
        # mov.s $f12, $f0
        # syscall

        # li $v0, 4
        # la $a0, calc1
        # syscall

        # li $v0, 2
        # mov.s $f12, $f30
        # syscall

        # li $v0, 4
        # la $a0, calc7
        # syscall

        # li $v0, 2
        # mov.s $f12, $f3
        # syscall

        # li $v0, 4
        # la $a0, calc6
        # syscall

        # li $v0, 2
        # mov.s $f12, $f1
        # syscall        
        
        # li $v0, 4
        # la $a0, calc4
        # syscall

        # li $v0, 2
        # mov.s $f12, $f2
        # syscall

        # li $v0, 11
        # la $a0, '\n'
        # syscall
        # # Debug Printer

        addi $t2, $t2, 1
        j Find_intercept

    Found_intercept:
    # Store the Yintercept element into the weights array at first index
    la $t0, weights
    andi $t0, $t0, -4
    
    # # Load f10 = Number of columns (small helper float)
    # mtc1 $s1, $f10 # Convert integer to FLOAT
    # cvt.s.w $f10, $f10
    # The intercept should be number of columns times MORE than current value, hence multiplying
    # mul.s $f30, $f30, $f10
    s.s $f30, 0($t0)

    # Printing weights
    li $v0, 11
    la $a0, '\n'
    syscall
    li $v0, 4
    la $a0, weight
    syscall

    # Size of Array = Number of columns --> is constant --> s1
    move $a2, $s1

    
    weights_display:
        andi $t0, $t0, -4 

        li $v0, 2            # System call code for printing float
        lwc1 $f12, 0($t0)    # Load the float value from the array into $f12
        syscall            

        li $v0, 11
        la $a0, '\t'
        syscall        

        addi $t0, $t0, 4     # Move to the next element in the array
        sub $a2, $a2, 1      # Decrement the loop counter

        bnez $a2, weights_display      


jr $ra

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # UDF-4 --> Test the data using the weights and display the data  # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

testModel:
    # Fill the predicted array with slope value (b0), its always added :v
    la $t4, predicted
    li $t1, 0

    Fill_predicc:
        # Adjust the addresses
        andi $t4, $t4, -4
        s.s $f30, 0($t4)
        addi $t1, $t1, 1 # counter
        addi $t4, $t4, 4
        bne $t1, $s1, Fill_predicc
    
    # Test the model using weights
    la $t0, test_data
    la $t3, weights
    la $t4, predicted

    li $t1, 1
    li $t2, 0
    
    # Ignore Y elements (we are predicting them :v)
    addi $t0, $t0, 4
    addi $t3, $t3, 4

    Predictor_Loop:
        # Adjust the addresses
        andi $t0, $t0, -4
        andi $t3, $t3, -4
        andi $t4, $t4, -4

        # Load test element
        lw $t5, 0($t0)
        mtc1 $t5, $f1
        cvt.s.w $f1, $f1

        # Load weight element
        l.s $f2, 0($t3)

        # Calculate
        mul.s $f3, $f2, $f1

        # Load element from prediction at current column, add to it and save back
        l.s $f4, 0($t4)
        add.s $f4, $f4, $f3
        s.s $f4, 0($t4)

        addi $t0, $t0, 4
        addi $t1, $t1, 1 # counter
        addi $t3, $t3, 4


    	# # Debug Printing
    	# li $v0, 11
    	# la $a0, '\n'
    	# syscall
    	
    	# li $v0, 1
    	# move $a0, $t1
    	# syscall
    	
    	# li $v0, 4
    	# la $a0, calc1
    	# syscall
    	
    	# li $v0, 2
    	# mov.s $f12, $f4
    	# syscall
    	
    	# li $v0, 4
    	# la $a0, calc7
    	# syscall
    	
    	# li $v0, 2
    	# mov.s $f12, $f3
    	# syscall
   
    	# li $v0, 4
    	# la $a0, calc8
    	# syscall
    	
    	# li $v0, 2
    	# mov.s $f12, $f2
    	# syscall
    	
    	# li $v0, 4
    	# la $a0, calc4
    	# syscall
    	
    	# li $v0, 2
    	# mov.s $f12, $f1
    	# syscall
    	
    	# li $v0, 11
    	# la $a0, '\n'
    	# syscall
    	# # Debug Printing 
    	
        bne $t1, $s1, Predictor_Loop

    # Reset addresses
    la $t3, weights
    la $t4, predicted
    
    addi $t0, $t0, 4 # Ignoring Y value again
    addi $t3, $t3, 4
    
    # Move to next prediction
    addi $t4, $t4, 4
    
    li $t1, 1
    addi $t2, $t2, 1

    bne $t2, $s3, Predictor_Loop

    # Display the Formula
    li $v0, 4
    la $a0, formula
    syscall

    li $v0, 2
    mov.s $f12, $f30
    syscall

    la $t0, weights
    addi $t0, $t0, 4

    li $t1, 1

    Display_formula:
        li $v0, 4
        la $a0, plusX
        syscall

        li $v0, 1
        move $a0, $t1
        syscall

        li $v0, 4
        la $a0, calc4
        syscall

        andi $t0, $t0, -4
        l.s $f1, 0($t0)
        addi $t0, $t0, 4

        li $v0, 2
        mov.s $f12, $f1
        syscall

        li $v0, 11
        la $a0, ')'
        syscall

        addi $t1, $t1, 1

        bne $t1, $s1, Display_formula

    # Display Actual data vs Predicted Data

    li $v0, 11
    la $a0, '\n'
    syscall

    la $t0, test_data
    la $t1, predicted

    li $t9, 0 # Helper variable to jump rows
    li $t2, 0 # Row counter

    Final_Display:
        andi $t0, $t0, -4
        andi $t1, $t1, -4

        li $v0, 4
        la $a0, actual
        syscall

        li $v0, 1
        lw $a0, 0($t0)
	syscall 
	
        li $v0, 4
        la $a0, predicc
        syscall

        li $v0, 2           
        lwc1 $f12, 0($t1)   
        syscall     

        # Move to next ROW (not element) in matrix
        # s3 = ROWS || s1 = COLS
        mul $t9, $s1, 4
        # Move to the next column
        add $t0, $t0, $t9
        addi $t1, $t1, 4

        li $v0, 11
        la $a0, '\n'
        syscall

        addi $t2, $t2, 1

        bne $t2, $s3, Final_Display

jump_back_to_main:

jr $ra

Exit:
    # Exit
    li $v0, 10       
    syscall

