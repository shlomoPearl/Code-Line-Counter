import sys

comments = [';', '--','//']
open_block = ['/*',"'''",'"""']
close_block = ['*/',"'''",'"""']
num_lines = 0
if __name__ == "__main__":
    f_path = sys.argv[1]
    type_f = sys.argv[2]
    with open(f_path, 'r') as file:
        line = file.readline()
        while line: 
            line = line.strip().strip('\n')
            #print(line)
            #print(len(line))
            if line == '':
                pass 
            elif line[0] == '#' and type_f != 'c' and type_f != 'cpp':
                pass 
            elif line[0] in comments or line[0:2] in comments:
                pass 
            elif line[0:2] in open_block or line[0:3] in open_block:
                while line: 
                    line = line.strip().strip('\n')
                    if line[0:2] in close_block or line[0:3] in close_block or line[-2:] in close_block or line[-3:] in close_block:
                        break
                    line = file.readline()
            else:
                #print(line)
                num_lines += 1
            line = file.readline()
    print(num_lines)

