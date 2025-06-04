import sys
include_files = ['c','cpp','h','hpp']
comments = [';', '--','//']
open_block = ['/*',"'''",'"""']
close_block = ['*/',"'''",'"""']
block = False
num_lines = 0
if __name__ == "__main__":
    f_path = sys.argv[1]
    type_f = sys.argv[2]
    with open(f_path, 'r') as file:
        line = file.readline()
        while line: 
            line = line.strip().strip('\n')
            if line == '' or (line[0] == '#' type_f not in include_files) or (line[0] in comments or line[0:2] in comments):
                line = file.readline()
                continue
            if line[0:2] in open_block:
                line = line.replace(line[0:2],'~',1)
                block = True
            elif line[0:3] in open_block:
                line = line.replace(line[0:3],'~',1)
                block = True
            if block:
                while line: 
                    line = line.strip().strip('\n')
                    if line[0:2] in close_block or line[0:3] in close_block or line[-2:] in close_block or line[-3:] in close_block:
                        break
                    line = file.readline()
                block = False
            else:
                num_lines += 1
            line = file.readline()
    print(num_lines)

