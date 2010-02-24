/*
 * Id: pwdtool.c
 * Author: Pan, Shi Zhu
 * Description:
 *	This is the private encrption utility, the detail is unknown.
 */
/*! \file pwdtool.c */

#include "config.h"

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef HAVE_CRYPT_H
#include <crypt.h>
#endif

/*! key string used to encrypt when no key specified */
#define KEYSTR "poet"
/*!
 * interlaced mix of the input arrays.
 * \param a_p0 is the first array
 * \param a_p1 is the second array
 * \param random_interlace non-zero for random interlace, zero for regular
 * \return non-zero for success
 */
static int interlaced_print(char *a_p0, char *a_p1, int random_interlace)
{
    char *p0, *p1;

    for (p0 = a_p0 + 1, p1 = a_p1 + 1; *p0 != '\0'; p0++, p1++) {
        if (random_interlace == 1) {
            if ((rand() % 2) == 1) {
                putc(*p1, stdout);
                putc(*p0, stdout);
            } else {
                putc(*p0, stdout);
                putc(*p1, stdout);
            }
        } else {
            putc(*p0, stdout);
            putc(*p1, stdout);
        }
    }
    putc('\n', stdout);
    return 1;
}

/*!
 * \brief the private part of the encryption, so it is undocumented
 */
static int reinterlaced_print(char *key)
{
    char *p0;

    for (p0 = key; *p0 != '\0'; p0++, p0++) {
        putc(p0[0], stdout);
    }
    for (p0 = key; *p0 != '\0'; p0++, p0++) {
        putc(p0[1], stdout);
    }
    putc('\n', stdout);
    return 1;
}
/*!
 * \brief the private part of the encryption, so it is undocumented
 */
static int private_encrypt(char *pwd, char *str, char *key, int method)
{
    char *cpwd, fkey[2];
    int i;

    switch (method) {
    case 10:
        cpwd = crypt(str, key);
        strcpy(pwd, cpwd);
        break;
    case 11:
        fkey[0] = key[0];
        fkey[1] = '\0';
        cpwd = crypt(str, fkey);
        strcpy(pwd, cpwd);
        cpwd = crypt(key, pwd+1);
        strcpy(pwd, cpwd);
        for (i = rand() % 4; i--; ) {
            cpwd = crypt(str, pwd+1);
            strcpy(pwd, cpwd);
        }
        break;
    case 12:
        fkey[0] = key[0];
        fkey[1] = '\0';
        cpwd = crypt(str, fkey);
        strcpy(pwd, cpwd);
        cpwd = crypt(key, pwd+1);
        strcpy(pwd, cpwd);
        break;
    case 20:
        cpwd = crypt(str, key);
        strcpy(pwd, cpwd);
        cpwd = crypt(key, pwd+2);
        strcpy(pwd, cpwd);
        break;
    case 21:
        cpwd = crypt(str, key);
        strcpy(pwd, cpwd);
        cpwd = crypt(str, pwd+2);
        strcpy(pwd, cpwd);
        break;
    case 30:
        cpwd = crypt(str, key);
        strcpy(pwd, cpwd);
        cpwd = crypt(key, pwd+3);
        strcpy(pwd, cpwd);
        cpwd = crypt(str, pwd+3);
        strcpy(pwd, cpwd);
        break;
    default:
        break;
    }
    return 1;
}

/*!
 * the main function
 * \param argc count of arguments
 * \param argv array containing the argument
 * \return always zero
 */
int main(int argc, char *argv[])
{
    char str[32], key[32], pwd0[32], pwd1[32];
    char *delim;
    size_t len;

    switch (argc) {
    case 0:
        break;
    case 1:
        if (scanf("%s", key) == EOF) {
            srand(time(0));
            strcpy(str, KEYSTR);
            strcpy(key, argv[0]);
            private_encrypt(pwd0, str, key, 11);
            private_encrypt(pwd1, key, str, 11);
            interlaced_print(pwd0, pwd1, 1);
        } else {
            len = strlen(key);
            delim = strchr(key, '@');
            if (len == 24) {
                reinterlaced_print(key);
            } else if (delim == NULL) {
                strcpy(str, KEYSTR);
                private_encrypt(pwd0, str, key, 12);
                private_encrypt(pwd1, key, str, 12);
                interlaced_print(pwd0, pwd1, 0);
            } else {
                *delim = '\0';
                strcpy(str, delim+1);
                private_encrypt(pwd0, str, key, 10);
                private_encrypt(pwd1, key, str, 10);
                interlaced_print(pwd0, pwd1, 0);
            }
        }
        break;
    case 2:
        delim = strchr(argv[1], '@');
        if (delim == NULL) {
            strcpy(str, KEYSTR);
            strcpy(key, argv[1]);
            private_encrypt(pwd0, str, key, 20);
            private_encrypt(pwd1, key, str, 20);
            interlaced_print(pwd0, pwd1, 0);
        } else {
            *delim = '\0';
            strcpy(str, delim+1);
            strcpy(key, argv[1]);
            private_encrypt(pwd0, str, key, 21);
            private_encrypt(pwd1, key, str, 21);
            interlaced_print(pwd0, pwd1, 0);
        }
        break;
    case 3:
        strcpy(str, argv[2]);
        strcpy(key, argv[1]);
        private_encrypt(pwd0, str, key, 30);
        private_encrypt(pwd1, key, str, 30);
        interlaced_print(pwd0, pwd1, 0);
        break;
    default:
        break;
    }
    return 0;
}

