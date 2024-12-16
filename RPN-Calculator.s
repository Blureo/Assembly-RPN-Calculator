    .text
    .global _start
_start:

// This program is an RPN Calculator

// startup
        LDR     r0, =welcome_prompt // "boot-up" prompt
        BL      printf
        LDR     r0, =newline // making space between instructions and calculator interface
        BL      printf

// initialize stack size
        MOV     r11, #0

loop: // all outcomes result in branches to subroutines, which all branch back to loop, not the lr. Thus, loop works

// print space between new cycle (stack) and previous
        LDR     r0, =newline
        BL      printf

// Print Stack
        B       print_stack1

post_print_stack:

// print an greater than arrow character to indicate the user can type
        LDR     r0, =userType
        BL      printf

// get input
        LDR     r0, =console_in      // location where string is stored
        LDR     r1, =console_in_sz  
        LDR     r2, =stdin
        LDR     r2, [r2]
        BL      fgets

// get result of sscanf on input
        LDR     r0, =console_in
        LDR     r1, =format_in
        LDR     r2, =input          // sscanf places parsed integer here
        BL      sscanf


// determine if input was an integer using sscanf output
        CMP     r0, #1
        BEQ     enter

// determining which command the user inputted
        LDR     r0, =console_in
        LDRB    r0, [r0] // first charcter of the string input

// if - we subtract
        MOV     r1, #'-'
        CMP     r1, r0 // comparing input string to string literal '-'
        BEQ     subtract

// if + we add
        MOV     r1, #'+'
        CMP     r1, r0 // comparing input string to string literal '+'
        BEQ     addition

// if * we multiply
        MOV     r1, #'*'
        CMP     r1, r0 // comparing input string to string literal '*'
        BEQ     multiplication

// if e we quit program
        MOV     r1, #'e'
        CMP     r1, r0 // comparing input string to string literal '*'
        BEQ     end

// if no tests are true; else statement
        B       error1

print_stack1:
        // intializes values for stack printing
        MOV     r10, r11 // Holds value of stack size that we can decrement without destroying our knowledge of the stack's size
        MOV     r9, sp // holds stack pointer so we can decrement it when printing stack

        MOV     r7, #4       // load #4 into r7 for multiplication (requires register?)
        MUL     r8, r11, r7  // multiplying stack size by 4
        ADD     r9, r9, r8   // adding 4 times stack size to sp (r9)
        SUB     r9, r9, #4   // subtracting 4 because sp is already at location thus I really need this:
                             // sp = sp + (r11 - #1) * 4
        /*
        The above 4 lines of code allow us to print the stack in the right order as
        defined by how RPN calculators work. Without adding 4 times the stack size, 
        subtracting 4, and adding 4 to r9 (as opposed to subtracting), the stack gets
        printed backwards to how one is used to seeing the stack on an RPN calculator.
        If this step was not taken, the calculator would still be functional. However,
        as opposed to new values being inserted at the bottom and the math taking place
        "at the bottom," the math takes place at the top and values are placed at the top.
        Oddly enough, the behavior is still the same as an RPN, so if you have a 4 on
        top with a 5 below, and you subract, you get a +1 instead of a -1. The math is 
        sound, but the visual was odd.
        */
        B       print_stack2

print_stack2:
        // this function prints the stack
        CMP     r10, #0 // checks if there are any items to print.
        BEQ     end_print_stack

        LDR     r0, =stack_out // loads "%d\n" print format
        LDR     r1, [r9] // loads stack value
        BL      printf

        SUB     r9, r9, #4 // decrements stack pointer for future interation
        SUB     r10, r10, #1 // decreases temp stack size. Printing stops when r10 is zero.
        B       print_stack2 // loop this function until stack size (represeted by r10) is zero

end_print_stack:
        B       post_print_stack

addition:
        // Need to make sure size of stack is big enough
        CMP     r11, #2
        BLT     error2

        POP     {r0}        // take lower arg off stack
        POP     {r1}        // take upper arg off stack
        ADD     r2, r1, r0  // do the addition
        PUSH    {R2}        // put result back on stack
        SUB     r11, r11, #1 // decrement stack size as the operation takes 2 args and returns 1

        B       loop // if + test was true then no others are. Branch back to beginning of loop instead of lr

multiplication:
        // Need to make sure size of stack is big enough
        CMP     r11, #2
        BLT     error2

        POP     {r0}        // take lower arg off stack
        POP     {r1}        // take upper arg off stack
        MUL     r2, r1, r0  // do the multiplication
        PUSH    {R2}        // put result back on stack
        SUB     r11, r11, #1 // decrement stack size as the operation takes 2 args and returns 1

        B       loop // if * test was true then no others are. Branch back to beginning of loop instead of lr

subtract:
        // Need to make sure size of stack is big enough
        CMP     r11, #2
        BLT     error2
        
        // do the subtraction
        POP     {r0}        // take lower arg off stack
        POP     {r1}        // take upper arg off stack
        SUB     r2, r1, r0  // do the subtraction
        PUSH    {R2}        // put result back on stack
        SUB     r11, r11, #1 // decrement stack size as the operation takes 2 args and returns 1

        B       loop // if - test was true then no others are. Branch back to beginning of loop instead of lr


// Puts a value onto the stack
enter:
        LDR     r0, =input    // location of integer from sscanf
        LDR     r1, [r0]      // stores value of integer at location "input"

        PUSH    {r1}          // push integer input onto stack
        ADD     r11, r11, #1  // increment stack size

        B       loop // if integer test was true then no others are. Branch back to beginning of loop instead of lr

// Entered value was not a number or operation
error1:
        LDR     r0, =ValueError
        BL      printf

        B       loop // if no valid input then nothing can happen. Repeat cycle


// Stack is not large enough to perform operation (multiplication, addition, subtraction)
error2:
        LDR     r0, =sizeError
        BL      printf

        B       loop // if not enough arguments then nothing can happen. Repeat cycle

end:
        LDR     r0, =exit_prompt
        BL      printf
        MOV     r0, #0
        BL      exit

    .data
welcome_prompt: .asciz "RPN Calculator by JT, limited to real numbers.\n Input + to add, - to subtract, and * to multiply.\n Enter e to exit program.\n"

exit_prompt: .asciz "Calculator has been shut down.\n"

ValueError: .asciz "The value you entered was not a valid number or command\n"

sizeError: .asciz "Not enough numbers in stack\n"

newline: .asciz "\n\n"

format_in: .asciz "%d" // sscanf parse format

stack_out: .asciz "%d\n" // stack printing format

userType: .asciz "> " // prints so that user knows when they can input

console_in: .space 50 // where fgets stores input string
    .equ console_in_sz, (.-console_in)

input: .word 0 // where sscanf stores parsed integer
