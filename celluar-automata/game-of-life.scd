(

Server.default = Server.local;

~m = MonomeGrid.new(0);

s.waitForBoot({

    var state, brightness, tempo, task, init, check_rules, reinit;

    brightness = 4;
    tempo = 0.1;

    ~m.connect(0);
    ~nCols = ~m.cols - 1;
    ~nRows = ~m.rows - 1;

    ~m.key({ |x, y, z|
        // key press callback handler (add 1 to a cell that may be empty)
        ~m.led(x, y, z * 15);
        o[x, y] = 1;
    });

    init = {
        // 2D array with 16 columns, 8 rows (current state) filled with zeros
        o = Array2D.fromArray(~m.cols, ~m.rows, 0!(~m.cols * ~m.rows));
        n = Array2D.fromArray(~m.cols, ~m.rows, 0!(~m.cols * ~m.rows)); // copy for later
        t = Array2D.fromArray(~m.cols, ~m.rows, 0!(~m.cols * ~m.rows)); // copy for later

        // initial population
        for(0, ~nCols, { |x|
            for(0, ~nRows, { |y|
                var fill = rand(1.0);
                if (fill < 0.3, {
                    o[x, y] = 1;
                    n[x, y] = 1;
                });
            });
        });
    };

    check_rules = {
        // determine next state for each cell on the board
        for(0, ~nCols, { |x|
            for(0, ~nRows, { |y|
                var neighbors = 0;
                var applied = 0;

                // top
                if (o[(x + ~nCols - 1) % ~nCols, (y + ~nRows - 1) % ~nRows] == 1, { neighbors = neighbors + 1});
                if (o[x, (y + ~nRows - 1) % ~nRows] == 1, { neighbors = neighbors + 1});
                if (o[(x + 1) % ~nCols, (y + ~nRows - 1) % ~nRows] == 1, { neighbors = neighbors + 1});
                //middle
                if (o[(x + ~nCols - 1) % ~nCols, y] == 1, { neighbors = neighbors + 1});
                if (o[(x + 1) % ~nCols, y] == 1, { neighbors = neighbors + 1});
                //bottom
                if (o[(x + ~nCols - 1) % ~nCols, (y+1) % ~nRows] == 1, { neighbors = neighbors + 1});
                if (o[x, (y+1) % ~nRows] == 1, { neighbors = neighbors + 1});
                if (o[(x + 1) % ~nCols, (y + 1) % ~nRows] == 1, { neighbors = neighbors + 1});

                // apply rules
                if ((o[x, y] == 1) && (neighbors < 2),
                    {
                        n[x, y] = 0;
                        applied = 1;
                    },
                    { // else
                        if ((o[x, y] == 1) && (neighbors > 3),
                            {
                                n[x, y] = 0;
                                applied = 2;
                            },
                            {  // else
                               if ((o[x, y] == 0) && (neighbors == 3),
                                    {
                                        n[x, y] = 1;
                                        applied = 3;
                                    }
                                );
                            };
                        );
                    };
                );

                // if nothing was applied above, apply rule for everything "else"
                if (applied == 0, {
                    n[x, y] = o[x, y];
                });
            });
        });
        t = o;
        o = n;
        n = t;
    };

    reinit = {
        // draw new board with updated state for each cell after applying rules
        for(0, ~nCols, { |x|
            for(0, ~nRows, { |y|
                if (n[x, y] == 1,
                    {
                        // do stuff here
                        ~m.led(x, y, brightness);
                    },
                    { ~m.led(x, y, 0)}
                );
            });
        });
    };

    init.();

    // start looping to check rules and apply to board
    task = Routine({      // init the board before we start looping
        loop {
            check_rules.();
            reinit.();
            /*
            if (o.sum == 0, // board was empty, so reinitialize
                {init.()}
            );
            */
            tempo.yield;
        }
    });
    task.play();

});

)

