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

SynthDef(\grain, {
	var sig, env;
	sig = SinOsc.ar(\freq.kr(440), \phase.ir(0), \amp.kr(0.2));
    env = EnvGen.kr(Env.perc(0.01, \sustain.ir(1)), doneAction: 2);
    sig = sig * env;
	Out.ar(0, sig ! 2);
}).add;

s.waitForBoot({
    var check_rules, draw, task;
    var brightness = 5; // grid led brightness for cells (0-15 range)
    var tempo = (60/120) * (1/4);

    ~m.connect(0);
    ~cells = Array.fill(~m.cols * ~m.rows, {[1, 0].choose});
    ~nCols = ~m.cols - 1;
    ~nRows = ~m.rows - 1;
    ~rules = [  // add and/or subtract rules for experimenting with results
        [1, 0, 1, 0],
        [0, 0, 1, 1],
        [1, 1, 0, 0],
        [1, 1, 1, 0],
        [1, 0, 0, 1],
//      [0, 1, 0, 1],
//      [0, 0, 0, 1],
//      [0, 1, 1, 1],
    ];

    /*
    ~m.key({ |x, y, z|
        // key press callback handler (add 1 to a cell that may be empty)
        var pos = x + (y * 16);
        [x, y, z].postln;
        ~m.led(x, y, z * 15);
        ~cells[pos] = z;
    });
    */

    check_rules = {|left, middle, right|
        // decide if cell is dead or alive based on "rules"
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
                    { // turn on (do stuff here for hooking up as controller)
                        ~m.led(x, y, brightness);
                        Synth(\grain, [
                            freq: (40 + (pos / 2)).midicps,
                            amp: rrand(0.1, 0.5),
                            phase: rrand(0, 1),
                            sustain: rrand(0.5, 1.0)
						]);
                    },
                    { ~m.led(x, y, 0) }             // turn off
                );
                ~cells[y * 16 + x] = state;
            });
        });

        // if somehow the "board" is entirely cleared/empty,
        // add another rule flavor and refill ~cells array
        if (~cells.sum == 0,
            {
                "regenerating...".postln;
                ~cells = Array.fill(~m.cols * ~m.rows, {[1, 1].choose}); // regenerate. change to [1, 0] for a differen animation type
                // add a new rule that changes the animation
                ~rules = ~rules.addAll([ [0, 1, 0, 1] ]);
            }
        );
    };

   // loop the functionality
    task = Routine({
        loop {
            draw.();
            tempo.yield;
        }
    });
    task.play();
});

)

