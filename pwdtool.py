
import crypt, random, sys

KEYSTR = "poet"

def interlaced(p0, p1, random_interlace):
    putc = ""
    p0len = len(p0)
    for i in range(1,p0len):
        if random_interlace:
            if random.randint(0,1) == 1:
                putc += p1[i] + p0[i]
            else:
                putc += p0[i] + p1[i]
        else:
            putc += p0[i] + p1[i]
    return putc

def reinterlaced(key):
    putc = ""
    keylen = len(key)
    for i in range(0, keylen, 2):
        putc += key[i]
    for i in range(1, keylen, 2):
        putc += key[i]
    return putc

def private_encrypt10(str, key):
    return crypt.crypt(str,key)

def private_encrypt11(str, key):
    fkey = key[0]
    pwd = crypt.crypt(str, fkey)
    pwd = crypt.crypt(key, pwd[1:])
    for i in range(random.randint(0,3)):
        pwd = crypt.crypt(str, pwd[1:])
    return pwd

def private_encrypt12(str, key):
    fkey = key[0]
    pwd = crypt.crypt(str, fkey)
    pwd = crypt.crypt(key, pwd[1:])
    return pwd

def private_encrypt20(str, key):
    pwd = crypt.crypt(str, key)
    pwd = crypt.crypt(key, pwd[2:])
    return pwd

def private_encrypt21(str, key):
    pwd = crypt.crypt(str, key)
    pwd = crypt.crypt(str, pwd[2:])
    return pwd

def private_encrypt30(str, key):
    pwd = crypt.crypt(str, key)
    pwd = crypt.crypt(key, pwd[3:])
    pwd = crypt.crypt(str, pwd[3:])
    return pwd

def public_encrypt(str, key):
    random.seed()
    output = []
    funcs = (private_encrypt11, private_encrypt12, private_encrypt10, 
            private_encrypt20, private_encrypt21, private_encrypt30)
    for pe in funcs:
        if pe == private_encrypt11:
            pwd = interlaced(pe(str, key), pe(key, str), True)
        else:
            pwd = interlaced(pe(str, key), pe(key, str), False)
        slice0 = pwd[0:8], pwd[8:16], pwd[16:24]
        pwd = reinterlaced(pwd)
        slice1 = pwd[0:8], pwd[8:16], pwd[16:24]
        output.append((slice0, slice1))
    return output

def main():
    argc = len(sys.argv)
    if argc <= 1:
        if len(sys.argv[0]) == 0:
            op = public_encrypt(KEYSTR, "python")
        else:
            op = public_encrypt(KEYSTR, sys.argv[0])
    elif argc == 2:
        sp = sys.argv[1].partition("@")
        if len(sp[1]) == 0:
            op = public_encrypt(KEYSTR, sp[0])
        else:
            op = public_encrypt(sp[2], sp[0])
    elif argc >= 3:
        op = public_encrypt(sys.argv[2], sys.argv[1])
    for item in op:
        print "%s\t%s\t%s\t%s\t%s\t%s" % \
            (item[0][0], item[0][1], item[0][2], item[1][0], item[1][1], item[1][2])

if __name__ == "__main__":
    main()

