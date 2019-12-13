#include <cstdio>
#include <thread>
#include <signal.h>
using namespace std;

struct R {
    int q;
    int r;
};

R div11(int dividend, int divisor) {
    R r;
    if (divisor < 32768) {
        dividend *= 2;
        if (dividend >> 16 < divisor) {
           dividend /= 2;
           r.q = dividend/divisor;
           r.r = dividend%divisor;
           return r;
        } else {
            int r3 = dividend >> 16;
            int r2 = r3/divisor;
            int r4 = r2;
            r3 = r3%divisor;
            int d2 = ((r3 << 16) + (dividend & 0xffff))/2;
            r2 = d2/divisor;
            r.r = d2%divisor;
            r.q = (r4 << 15) + r2;
            return r;
        }
    } else {
        int r1 = divisor/2;
        int r4 = (dividend >> 16)*2 + 1;
        if (r4 < r1) {
            int r2 = dividend/r1 & 0x7fff;
            int r3 = dividend%r1;
            int cf = r2&1;
            r2 /= 2;
            if (cf) r3 += r1;
            r3 -= r2;
            if (r3 < 0) {
                r2--;
                r3 += divisor;
            }
            r.q = r2 & 0xffff;
            r.r = r3 & 0xffff;
            return r;
        } else {
            int r4 = dividend&1;
            int r2r3 = dividend/2;
            int r2 = (r2r3/r1)*2;
            int r3 = (r2r3%r1)*2 + r4;
            if (r3 >= r1) {
                r2++;
                r3 -= r1;
            }
            int cf = r2 & 1;
            r2 >>= 1;
            if (cf) r3 += r1;
            r3 -= r2;
            if (r3 < 0) {
                r2--;
                r3 += divisor;
            }
            r.q = r2 & 0xffff;
            r.r = r3;
            return r;
        }
    }
}

volatile int interrupt;

void signalHandler(int signal) {
    interrupt = 1;
}

int main() {
    int dividend = 0x3de9815a, divisor;
            for (int divisor = 1; divisor < 65535; divisor += 2)
                if (dividend/divisor != div11(dividend, divisor).q || dividend%divisor != div11(dividend, divisor).r) {
                    printf("%d/%d %d:%d %d:%d\n", dividend, divisor, dividend/divisor, dividend%divisor, div11(dividend, divisor).q, div11(dividend, divisor).r);
                    return 1;
                }
return 0;
    signal(SIGINT, signalHandler);
    int N1 = 0, N2 = 200'000'000;
    volatile int x1 = 0, x2 = 0, x3 = 0, x4 = 0;
    thread([&]{
        for (int dividend = N1; dividend < N2; ++dividend) {
            for (int divisor = 1; divisor < 16384; divisor += 2)
                if (dividend/divisor != div11(dividend, divisor).q || dividend%divisor != div11(dividend, divisor).r) {
                    printf("%d/%d %d:%d %d:%d\n", dividend, divisor, dividend/divisor, dividend%divisor, div11(dividend, divisor).q, div11(dividend, divisor).r);
                    return 1;
                }
            if (interrupt) {printf("1. dividend = %d\n", dividend); break;}
        }
        x1 = 1;
    }).detach();
    thread([&]{
        for (int dividend = N1; dividend < N2; ++dividend) {
            for (int divisor = 16385; divisor < 32768; divisor += 2)
                if (dividend/divisor != div11(dividend, divisor).q || dividend%divisor != div11(dividend, divisor).r) {
                    printf("%d/%d %d:%d %d:%d\n", dividend, divisor, dividend/divisor, dividend%divisor, div11(dividend, divisor).q, div11(dividend, divisor).r);
                    return 1;
                }
            if (interrupt) {printf("2. dividend = %d\n", dividend); break;}
        }
        x2 = 1;
    }).detach();
    thread([&]{
        for (int dividend = N1; dividend < N2; ++dividend) {
            for (int divisor = 32769; divisor < 49152; divisor += 2)
                if (dividend/divisor != div11(dividend, divisor).q || dividend%divisor != div11(dividend, divisor).r) {
                    printf("%d/%d %d:%d %d:%d\n", dividend, divisor, dividend/divisor, dividend%divisor, div11(dividend, divisor).q, div11(dividend, divisor).r);
                    return 1;
                }
            if (interrupt) {printf("3. dividend = %d\n", dividend); break;}
        }
        x3 = 1;
    }).detach();
    thread([&]{
        for (int dividend = N1; dividend < N2; ++dividend) {
            for (int divisor = 49153; divisor < 65536; divisor += 2)
                if (dividend/divisor != div11(dividend, divisor).q || dividend%divisor != div11(dividend, divisor).r) {
                    printf("%d/%d %d:%d %d:%d\n", dividend, divisor, dividend/divisor, dividend%divisor, div11(dividend, divisor).q, div11(dividend, divisor).r);
                    return 1;
                }
            if (interrupt) {printf("4. dividend = %d\n", dividend); break;}
        }
        x4 = 1;
    }).detach();
    while (x1 + x2 + x3 + x4 != 4);
    return 0;
}

