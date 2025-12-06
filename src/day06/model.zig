pub const Operation = enum {
    add,
    multiply,
};

pub const Homework = struct {
    numbers: [][]usize,
    operations: []Operation,
};
