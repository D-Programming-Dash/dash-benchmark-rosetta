import std.stdio, std.math, std.algorithm, std.typecons, std.range;

alias real Fp;
struct Circle { Fp x, y, r; }

void removeInternalDisks(ref Circle[] circles) {
    static bool isFullyInternal(in Circle c1, in Circle c2)
    pure nothrow {
        if (c1.r > c2.r) // quick exit
            return false;
        return (c1.x - c2.x) ^^ 2 + (c1.y - c2.y) ^^ 2 <
               (c2.r - c1.r) ^^ 2;
    }

    // Heuristics for performance: large radii first.
    circles.sort!q{a.r > b.r}();

    // What circles will be kept.
    auto keep = new bool[circles.length];
    keep[] = true;

    foreach (i1, c1; circles)
        if (keep[i1])
            foreach (i2, c2; circles)
                if (keep[i2])
                    if (i1 != i2 && isFullyInternal(c2, c1))
                        keep[i2] = false;

    // Pack circles array, removing fully internal circles.
    size_t pos = 0;
    foreach (i, k; keep)
        if (k)
            circles[pos++] = circles[i];
    circles.length = pos;
    // Alternative implementation of the packing:
    // circles = zip(circles, keep)
    //           .filter!(ck => ck[1])()
    //           .map!(ck => ck[0])()
    //           .array();
}


void main() {
    Circle[] circles = [
       { 1.6417233788,  1.6121789534, 0.0848270516},
       {-1.4944608174,  1.2077959613, 1.1039549836},
       { 0.6110294452, -0.6907087527, 0.9089162485},
       { 0.3844862411,  0.2923344616, 0.2375743054},
       {-0.2495892950, -0.3832854473, 1.0845181219},
       { 1.7813504266,  1.6178237031, 0.8162655711},
       {-0.1985249206, -0.8343333301, 0.0538864941},
       {-1.7011985145, -0.1263820964, 0.4776976918},
       {-0.4319462812,  1.4104420482, 0.7886291537},
       { 0.2178372997, -0.9499557344, 0.0357871187},
       {-0.6294854565, -1.3078893852, 0.7653357688},
       { 1.7952608455,  0.6281269104, 0.2727652452},
       { 1.4168575317,  1.0683357171, 1.1016025378},
       { 1.4637371396,  0.9463877418, 1.1846214562},
       {-0.5263668798,  1.7315156631, 1.4428514068},
       {-1.2197352481,  0.9144146579, 1.0727263474},
       {-0.1389358881,  0.1092805780, 0.7350208828},
       { 1.5293954595,  0.0030278255, 1.2472867347},
       {-0.5258728625,  1.3782633069, 1.3495508831},
       {-0.1403562064,  0.2437382535, 1.3804956588},
       { 0.8055826339, -0.0482092025, 0.3327165165},
       {-0.6311979224,  0.7184578971, 0.2491045282},
       { 1.4685857879, -0.8347049536, 1.3670667538},
       {-0.6855727502,  1.6465021616, 1.0593087096},
       { 0.0152957411,  0.0638919221, 0.9771215985}];

    writeln("Input Circles: ", circles.length);
    removeInternalDisks(circles);
    writeln("Circles left: ", circles.length);

    immutable Fp xMin = reduce!((acc, c) => min(acc, c.x - c.r))
                               (Fp.max, circles[]);
    immutable Fp xMax = reduce!((acc, c) => max(acc, c.x + c.r))
                               (cast(Fp)0, circles[]);

    alias Tuple!(Fp,"y0", Fp,"y1") YRange;
    auto yRanges = new YRange[circles.length];

    Fp computeTotalArea(in Fp nSlicesX) {
        Fp total = 0;

        // Adapted from an idea by Cosmologicon.
        foreach (p; cast(int)(xMin * nSlicesX) ..
                    cast(int)(xMax * nSlicesX) + 1) {
            immutable Fp x = p / nSlicesX;
            size_t nPairs = 0;

            // Look for the circles intersecting the current
            // vertical secant:
            foreach (ref const Circle c; circles) {
                immutable Fp d = c.r ^^ 2 - (c.x - x) ^^ 2;
                immutable Fp sd = sqrt(d);
                if (d > 0)
                    // And keep only the intersection chords.
                    yRanges[nPairs++] = YRange(c.y - sd, c.y + sd);
            }

            // Merge the ranges, counting the overlaps only once.
            yRanges[0 .. nPairs].sort();
            Fp y = -Fp.max;
            foreach (r; yRanges[0 .. nPairs])
                if (y < r.y1) {
                    total += r.y1 - max(y, r.y0);
                    y = r.y1;
                }
        }

        return total / nSlicesX;
    }

    // Iterate to reach some precision.
    enum Fp epsilon = 1e-9;
    Fp nSlicesX = 1_000;
    Fp oldArea = -1;
    while (true) {
        immutable Fp newArea = computeTotalArea(nSlicesX);
        if (abs(oldArea - newArea) < epsilon) {
            writeln("N. vertical slices: ", nSlicesX);
            writefln("Approximate area: %.17f", newArea);
            return;
        }
        oldArea = newArea;
        nSlicesX *= 2;
    }
}