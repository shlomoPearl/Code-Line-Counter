import sys

comments = ['#', ';', '--','//']
open_block = ['/*',"'''",'"""']
close_block = ['*/',"'''",'"""']
num_lines = 0
if __name__ == "__main__":
    f_path = sys.argv[1]
    type_f = sys.argv[2]
    with open(f_path, 'r') as file:
        line = file.readline()
        while line: 
            line = line.strip()
            if line == '' or line == '\n' or line in '\n\t'or line in '\t\n':
                continue
            if line[0] == '#' and (type_f != 'c' or type_f != 'cpp'):
                continue
            if line[0] in comments or line[0:2] in comments:
                continue
            if line[0:2] == on open_block:
                pass
            num_lines += 1
    print(num_lines)

