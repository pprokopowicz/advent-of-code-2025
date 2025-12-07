pub const Location = enum {
    empty,
    splitter,
};

pub const Coordinates = struct {
    x: usize,
    y: usize,
};

pub const Manifold = struct {
    diagram: [][]Location,
    start: Coordinates,
};
