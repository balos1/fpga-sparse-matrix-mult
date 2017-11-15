
import numpy

a = [1, 1.2]
b = [2, 2.2]
ia = [0, 2]
ib = [0, 2]

ja = 0
jb = 0
daN = (3*2)/3
dbN = (3*2)/3
product = 0
for ja, jb in zip(range(daN), range(dbN)):
    if ia[ja] < ib[jb]:
        ja = ja+1
    elif ia[ja] == ib[jb]:
        product = product + a[ja]*b[jb]
        ja = ja+1
        jb = jb+1
    else:
        jb = jb+1

print(product)
