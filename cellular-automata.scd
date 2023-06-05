(

Server.default = Server.local;

~m = MonomeGrid.new(0);

s.waitForBoot({
    var check_rules, draw, check_tail, task;
    var brightness = 10;

	~m.connect(0);
    ~cells = Array.fill(~m.cols * ~m.rows, {[1,0].choose});
    ~nCols = ~m.cols - 1;
	~nRows = ~m.rows - 1;
    ~rules = [   // add and/or subtract rules for experimenting with results
        [1, 0, 1, 0],
        [0, 0, 1, 1],
        [1, 1, 0, 0],
        [1, 1, 1, 0],
        [1, 0, 0, 1],
    ];

    ~m.key({
        // key press callback handler
        arg x,y,z;
        [x,y,z].postln;
    });

    check_rules = {|left, middle, right|
        // determine next cell "state"
        var new_state = 0;
        (0..~rules.size-1).do({|r|
            if (left == ~rules[r][0] && middle == ~rules[r][1] && right == ~rules[r][2],
                {new_state = ~rules[r][3]}
            )
        });
        new_state;
    };

    check_tail = {
        // check if ~cells list is starting to get empty
        var start = ~cells.size-30;
        var end = ~cells.size - 1;
        if (~cells.slice((start..end)).sum == 0,
            {
                (~cells.size-1..~cells.size-30).do({|i, x|
                    // ~cells[i] = {[0,1].choose};   // TODO populate more elegantly
                    ~cells[x] = {[1,0].choose};      // top 2 rows will eventually glitch out and spawn whole row triggers
                });
            }
        )
    };

    draw = {
        var pos, state;
        for(0, ~nCols, { arg x;
			for(0, ~nRows, { arg y;
                pos = y * 16 + x;
                state = check_rules.(left: ~cells[pos-1], middle: ~cells[pos], right: ~cells[pos+1]);
                if (state == 1,
                    {
                        ~m.led(x, y, brightness); // turn on
                        /*
                        // fade out experimentation
                        Routine { (brightness..0).do({ |i|
                            ~m.led(x, y, i);
                            0.1.yield;
                        })}.play();
                        */
                    },
                    { ~m.led(x, y, 0) }  // turn off
                );
                ~cells[y * 16 + x] = state;
			});
		});
        check_tail.();
    };

    task = Routine({
        loop {
            draw.();
            0.2.yield;
        }
    });
    task.play();
});

)
