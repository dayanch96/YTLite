#ifndef PTRAUTH_HELPERS_H
#define PTRAUTH_HELPERS_H
// Helpers for PAC archs.
// https://gist.github.com/summertriangle-dev/6b0449ce561f756ac82a4bc3de7af30a

// If the compiler understands __arm64e__, assume it's paired with an SDK that has
// ptrauth.h. Otherwise, it'll probably error if we try to include it so don't.
#if __arm64e__
#include <ptrauth.h>
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

// Given a pointer to instructions, sign it so you can call it like a normal fptr.
static void *make_sym_callable(void *ptr) {
#if __arm64e__
    if (ptr == NULL)
        return NULL;
    ptr = ptrauth_sign_unauthenticated(ptrauth_strip(ptr, ptrauth_key_function_pointer), ptrauth_key_function_pointer, 0);
#endif
    return ptr;
}

// Given a function pointer, strip the PAC so you can read the instructions.
static void *make_sym_readable(void *ptr) {
#if __arm64e__
    if (ptr == NULL)
        return NULL;
    ptr = ptrauth_strip(ptr, ptrauth_key_function_pointer);
#endif
    return ptr;
}

#pragma clang diagnostic pop
#endif