import sys, math

def WaitForInput():
    input("Wait for enter press . . .")

def WaitForInput2():
    raw_input("Wait for enter press . . .")

def error(argument):
    print("Error: " + argument)
    WaitForInput()
    sys.exit()

def SMWTranslevel(Level):
    if Level > 0x24:
        Level += 0xDC
    return Level

def WriteLine(Level, MMP):
    Number = format(Level, '04X')
    Text = "dw $" + Number
    for x in range(1, MMP):
        Text += ",$" + Number
    Text += "\t; Level " + format(Level, '04X') + '\n'
    return Text

# Main Code
if (sys.version_info < (3, 0)):
    print("Error: This script is only compatible with python 3 or newer.")
    WaitForInput2()
    sys.exit()

if len(sys.argv) <= 1:
    NumOfMMP = eval(input("How many midway points do you want to use: "))
else:
    NumOfMMP = eval(sys.argv[1])

if NumOfMMP > 256:
    error("You can have only up to 256 midway points.")
elif NumOfMMP < 1:
    error("You have to have at least one midway point.")

Header = "!total_midpoints = $" + format(NumOfMMP, '04X') + "\n\nlevel_mid_tables:\n"

with open('multi_midway_tables.asm', 'w') as file:
    file.write(Header)
    for i in range(0, 96):
        Datei = file.write(WriteLine(SMWTranslevel(i), NumOfMMP))

print("multi_midway_tables.asm was created successfully.")
WaitForInput()
