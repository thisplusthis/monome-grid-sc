/*
From the Nature of Code by Daniel Shiffman...

A cellular automaton is a model of a system of “cell” objects with the following characteristics.

1. The cells live on a grid.

2. Each cell has a state. The number of state possibilities is typically finite. The simplest example has the two possibilities of 1 and 0 (otherwise referred to as “on” and “off” or “alive” and “dead”).

3. Each cell has a neighborhood. This can be defined in any number of ways, but it is typically a list of adjacent cells.
*/

(

Server.default = Server.local;

~m = MonomeGrid.new(0);

s.waitForBoot({
    var check_rules, draw, check_tail, task;
    var brightness = 5;

    ~m.connect(0);
    ~cells = Array.fill(~m.cols * ~m.rows, {[1, 0].choose});
    ~nCols = ~m.cols - 1;
    ~nRows = ~m.rows - 1;
    ~rules = [
        // add and/or subtract rules for experimenting with results
        [1, 0, 1, 0],
        [0, 0, 1, 1],
        [1, 1, 0, 0],
        [1, 1, 1, 0],
        [1, 0, 0, 1],
//        [0, 1, 1, 1],
        [0, 1, 0, 1],
//        [0, 0, 0, 1],
    ];

    ~m.key({ |x, y, z|
        // key press callback handler (add 1 to a cell that may be empty)
        [x, y, z].postln;
        ~m.led(x, y, z * 15);
        if((z == 1) && (y <= ~nRows), {
            var pos = x + (y * 16);
            ~cells[pos] = 1;
        })
    });

    check_rules = {|left, middle, right|
        // decide if cell is active vs inactive based on "rules"
        var new_state = 0;
        (0..~rules.size-1).do({|r|
            if (left == ~rules[r][0] && middle == ~rules[r][1] && right == ~rules[r][2],
                { new_state = ~rules[r][3] }
            )
        });
        new_state;
    };

    draw = {
        // main method to pick next cell state
        var pos, state;
        for(0, ~nCols, { |x|
            for(0, ~nRows, { |y|
                pos = y * 16 + x;
                state = check_rules.(left: ~cells[pos - 1], middle: ~cells[pos], right: ~cells[pos + 1]);
                if (state == 1,
                    {
                        ~m.led(x, y, brightness); // turn on
                    },
                    { ~m.led(x, y, 0) }  // turn off
                );
                ~cells[y * 16 + x] = state;

            });
        });
    };

    task = Routine({
        loop {
            draw.();
            0.1.yield;
        }
    });
    task.play();
});

)

