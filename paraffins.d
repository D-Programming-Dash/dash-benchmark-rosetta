import std.stdio, std.bigint;

enum branches = 4;
enum nMax = 250;

__gshared BigInt[nMax + 1] rooted, unrooted;

void tree(int br, int n, int l, int sum, BigInt cnt) {
    __gshared static BigInt[branches] c;

    foreach (b; br + 1 .. branches + 1) {
        sum += n;
        if (sum > nMax || (l * 2 >= sum && b >= branches))
            return;
        if (b == br + 1) {
            c[br] = rooted[n] * cnt;
        } else {
            c[br] *= rooted[n] + b - br - 1;
            c[br] /= b - br;
        }
        if (l * 2 < sum)
            unrooted[sum] += c[br];
        if (b < branches)
            rooted[sum] += c[br];
        for (auto m = n - 1; m > 0; m--)
            tree(b, m, l, sum, c[br]);
    }
}

void bicenter(int s) {
    if (s & 1)
        return;
    unrooted[s] += rooted[s / 2] * (rooted[s / 2] + 1) / 2;
}

void main() {
    foreach (i; 0 .. 2) {
        rooted[i] = 1;
        unrooted[i] = 1;
    }

    foreach (n; 1 .. nMax + 1) {
        tree(0, n, n, 1, BigInt(1));
        bicenter(n);
        writefln("%d: %d", n, unrooted[n]);
    }
}