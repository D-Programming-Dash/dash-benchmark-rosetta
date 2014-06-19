import std.stdio, std.array, std.algorithm, std.range, std.ascii,
       std.conv, std.string, std.regex;

string unique(in string s) pure /*nothrow*/ {
    string result;
    foreach (immutable char c; s)
        if (!result.canFind(c))
            result ~= c;
    return result;
}

struct Playfair {
    string from, to;
    string[string] enc, dec;

    this(in string key, in string from_ = "J", in string to_ = null) {
        this.from = from_;
        if (to_.empty)
            this.to = (from_ == "J") ? "I" : "";

        auto m = _canonicalize(key ~ uppercase)
                 .unique
                 .chunks(5)
                 .map!text
                 .array;
        auto I5 = 5.iota;

        foreach (const R; m)
            foreach (immutable i, immutable j; cartesianProduct(I5, I5))
                if (i != j)
                    enc[[R[i], R[j]]] = [R[(i + 1) % 5], R[(j+1) % 5]];

        foreach (immutable r; I5) {
            const c = m.transversal(r).array;
            foreach (immutable i, immutable j; cartesianProduct(I5, I5))
                if (i != j)
                    enc[[c[i], c[j]]] = [c[(i + 1) % 5], c[(j+1) % 5]];
        }

        foreach (i1, j1, i2, j2; cartesianProduct(I5, I5, I5, I5))
            if (i1 != i2 && j1 != j2)
                enc[[m[i1][j1], m[i2][j2]]] = [m[i1][j2], m[i2][j1]];

        dec = enc.byValue.zip(enc.byKey).assocArray;
    }

    private string _canonicalize(in string s) const /*pure*/ {
        return s.toUpper.removechars("^A-Z").replace(from, to);
    }

    string encode(in string s) const {
        return _canonicalize(s)
               .matchAll(r"(.)(?:(?!\1)(.))?".regex)
               //.map!(m => enc[m[0].leftJustify(2, 'X')])
               .map!(m => cast()enc[m[0].leftJustify(2, 'X')])
               .join(" ");
    }

    string decode(in string s) const /*pure*/ {
        return _canonicalize(s)
               .chunks(2)
               //.map!dec
               .map!(p => cast()dec[p.text])
               .join(" ");
    }
}

void main() {
    const pf = Playfair("Playfair example");
    // Dash: Added loop.
    foreach (i; 0 .. 40_000) {
        immutable orig = "Hide the gold in...the TREESTUMP!!!" ~ to!string(i);
        writeln("Original: ", orig);
        immutable enc = pf.encode(orig);
        writeln(" Encoded: ", enc);
        writeln(" Decoded: ", pf.decode(enc));
    }
}
