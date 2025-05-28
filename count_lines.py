import sys

comments = ['#', ';', '--','//','/*']
open_block = '/*'
close_block = '*/'
num_lines = 0
if __name__ == "__main__":
    f_path = sys.argv[1]
    with open(f_path, 'r') as file:
        line = file.readline()
        while line: 
            if line[0:2] == open_block:
                while line and line[0:2] != close_block:
                    line = file.readline()
            elif line[0] in comments or line[0:2] in comments:
                pass
            elif line == '' or line == '\n' or line in '\n\t'or line in '\t\n':
                pass
            else:
                num_lines += 1
            line = file.readline()
    print(num_lines)

