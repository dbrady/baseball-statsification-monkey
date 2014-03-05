# Notes - Dave Brady's Coding Exercise Notes

## Fixing the file format

The .csv files are pretty gorbled up; they have 0x0d record separators
but the file ends with 0x0a, which pretty much makes it equally
unreadable by all operating systems--at least from the command line;
LibreOffice Calc on Linux can read it and I assume Numbers and Excel
can open it on OSX and Windows, respectively. The point is that bash
and ruby both think this is a single-line file, and though we can
change the input record separator to split lines on the 0x0d, ruby's
CSV library will barf on that final 0x0a at EOF.

It's pretty standard behavior for a code kata to throw you a "gotcha"
like this; the question here becomes whether or not to solve this
problem or not. I choose not, pending further information from a
stakeholder. I'm adding "install dos2unix" to the install notes and
"run mac2unix on the .csv files" as a pre-run setup step.

This problem IS solveable; if a stakeholder did want this done
automatically, e.g. because we were receiving these files on a regular
basis and needed to process them automatically, we could read them
into a buffer by changing the input record separator (`$/`) to 0x0d
long enough to call readlines() on the file. We just have to remember
to change it back to \n before printing to $stdout (as gotchas go,
this is a pretty good one).

## Working Around the Wontfix

I'll design the data reading module to accept an IO handle that's open
for reading, and point it at the fixed csv file on disk. This lets me
safely ignore the .csv formatting problem for now; later if I discover
that reading the data unchanged is a requirement, and that shelling
out to call mac2unix is cheating, I can write an object that reads the
unmodified CSV, toggles `$/`, and acts like a readable StringIO
buffer. Then we can pass THAT into the data reading module so that
file format garbage doesn't propagate into the data reader.
