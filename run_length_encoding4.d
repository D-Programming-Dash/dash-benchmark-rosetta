import std.stdio, std.conv, std.array, std.regex, std.utf,
       std.algorithm;

string reEncode(string s) {
    validate(s); // Throw if it's not a well-formed UTF string
    static string rep(Captures!string m) {
        auto c = canFind("0123456789#", m[1]) ? "#" ~ m[1] : m[1];
        return text(m.hit.length / m[1].length) ~ c;
    }
    return std.regex.replace!rep(s, regex(`(.|[\n\r\f])\1*`, "g"));
}


string reDecode(string s) {
    validate(s); // Throw if it's not a well-formed UTF string
    static string rep(Captures!string m) {
        string c = m[2];
        if (c.length > 1 && c[0] == '#')
            c = c[1 .. $];
        return replicate(c, to!int(m[1]));
    }
    auto r=regex(`(\d+)(#[0123456789#]|[\n\r\f]|[^0123456789#\n\r\f]+)`
                 , "g");
    return std.regex.replace!rep(s, r);
}

int main() {
    auto s = "??????????????\nWWWWWWWWWWWWBWWWWWWWWWWW" ~
             "WBBBWWWWWWWWWWWWWWWWWWWWWWWWBWWWWWWWWWWWWWW\n" ~
             "11#222##333";
    // Dash: Added loop.
    foreach (i; 0 .. 40_000) {
        auto t = s ~ to!string(i);
        if (t != reDecode(reEncode(t))) return 1;
    }
    return 0;
}
