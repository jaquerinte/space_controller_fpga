

# implement the function to generate the hex code
def generate_hex_code(op, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8):
    # generate the op code that is the first 3 bits of the 52 bit hex code
    
    op_code = op << 27
    # generate the register 7 code that is the 5 bit after the op code
    reg7_code = reg7 << 22
    # generate the register 6 code that is the 5 bit after the register 7 code
    reg6_code = reg6 << 17
    # generate the register 5 code that is the 5 bit after the register 6 code
    reg5_code = reg5 << 12
    # generate the register 4 code that is the 5 bit after the register 5 code
    reg4_code = reg4 << 7
    # generate the register 3 code that is the 5 bit after the register 4 code
    reg3_code = reg3 << 2
    # generate the register 2 code that is the 5 bit after the register 3 code
    reg2_code = reg2 >> 3
    # generate the register 1 code that is the 5 bit after the register 2 code
    reg1_code = reg1 >> 8
    # generate the register 0 code that is the 5 bit after the register 1 code
    reg0_code = reg0 >> 13
    # generate the 8 bit code that is the 9 bit after the register 0 code
    reg8_code = reg8 << 1
    # generate the hex code
    hex_code = op_code + reg7_code + reg6_code + reg5_code + reg4_code + reg3_code + reg2_code + reg1_code + reg0_code + reg8_code
    # return the hex code
    return hex(hex_code)

def main():
    # Will ask the user a series of questions to generate a output hex code
    # ask the instruction op that is an int

    input_op = input("Enter the instruction op: ")
    # check if the input is an int
    if not input_op.isdigit():
        print("The input is not an int")
        return
    input_op = int(input_op)
    # get the register 0 value and check if it is an int
    input_reg0 = input("Enter the register 0 value: ")
    if not input_reg0.isdigit():
        print("The input is not an int")
        return
    input_reg0 = int(input_reg0)
    # get the register 1 value and check if it is an int
    input_reg1 = input("Enter the register 1 value: ")
    if not input_reg1.isdigit():
        print("The input is not an int")
        return
    input_reg1 = int(input_reg1)
    # get the register 2 value and check if it is an int
    input_reg2 = input("Enter the register 2 value: ")
    if not input_reg2.isdigit():
        print("The input is not an int")
        return
    input_reg2 = int(input_reg2)
    # get the register 3 value and check if it is an int
    input_reg3 = input("Enter the register 3 value: ")
    if not input_reg3.isdigit():
        print("The input is not an int")
        return
    input_reg3 = int(input_reg3)
    # get the register 4 value and check if it is an int
    input_reg4 = input("Enter the register 4 value: ")
    if not input_reg4.isdigit():
        print("The input is not an int")
        return
    input_reg4 = int(input_reg4)
    # get the register 5 value and check if it is an int
    input_reg5 = input("Enter the register 5 value: ")
    if not input_reg5.isdigit():
        print("The input is not an int")
        return
    input_reg5 = int(input_reg5)
    # get the register 6 value and check if it is an int
    input_reg6 = input("Enter the register 6 value: ")
    if not input_reg6.isdigit():
        print("The input is not an int")
        return
    input_reg6 = int(input_reg6)
    # get the register 7 value and check if it is an int
    input_reg7 = input("Enter the register 7 value: ")
    if not input_reg7.isdigit():
        print("The input is not an int")
        return
    input_reg7 = int(input_reg7)
    # get the 8 bit value for the registers
    input_reg8 = input("Enter the 8 bit value for the registers: ")
    if not input_reg8.isdigit():
        print("The input is not an int")
        return
    input_reg8 = int(input_reg8)
    # generate the 52 bit hex code, this code is compose of 3 bits of the op, 5 bits for the registers and 9 bits for the 8 bit value been the 9 th bit a 0 always
    hex_code = generate_hex_code(input_op, input_reg0, input_reg1, input_reg2, input_reg3, input_reg4, input_reg5, input_reg6, input_reg7, input_reg8)
    # print the hex code
    print(hex_code)

if __name__ == "__main__":
    main()