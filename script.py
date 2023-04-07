import pandas as pd
import argparse
import os

def findtxt(path, ret):
    """
    Finding the *.txt file in specify path
    """
    filelist = os.listdir(path)
    for filename in filelist:
        de_path = os.path.join(path, filename)
        if os.path.isfile(de_path):
            if de_path.endswith(".txt"):
                ret.append(de_path)
        else:
            findtxt(de_path, ret)


class Arg():
    
    def __init__(self) -> None:
        self.parser = argparse.ArgumentParser()
        self.parser.add_argument("--ip", type=str, default="./", help="Input Path")
        self.parser.add_argument("--op", type=str, default="./", help="Output Path")
        self.args = self.parser.parse_args()

if __name__ == '__main__':

    args = Arg().args
    input_root = args.ip

    ret = []
    findtxt(input_root, ret)
    index = 0
    for path in ret:
        index += 1
        print("index: {}, path: {} ".format(index, path))
    
    for i in range(len(ret)):
        df = pd.read_table(ret[i],delimiter="\t")
        df.rename(columns = {"TotalEnvInteracts":"Step", "AverageEpRet":"Value"}, inplace=True)
        a = os.path.basename(ret[i])
        filename = a.split('.')[0]
        print(filename)
        df.to_csv(args.op + filename + '.csv', encoding='utf-8', index=False)
 

 

 
