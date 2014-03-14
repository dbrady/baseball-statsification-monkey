# README

## Baseball Statsification Monkey

[![Code Climate](https://codeclimate.com/github/dbrady/baseball-statsification-monkey.png)](https://codeclimate.com/github/dbrady/baseball-statsification-monkey)

If you're cloning this repo and you have a recent ruby (2.1.1 or
later), you should be able to just do

    bundle
    bundle exec bin/stats

and see the output. You can run the simple spec suite with

    bundle exec rspec

And the more detailed, documentation-oriented specs with

    bundle exec rspec -f d

There's a decent chance that just `bin/stats` may work without `bundle
exec`, as may `rspec` but when in doubt, `bundle exec`.


# OVERVIEW

## Most Important

If you have questions: Please ASK.

This project is based on a HUGE pile of assumptions that I would have
talked out with the business and/or architecture team, but in the
interest of working alone I have simply made those decisions myself. I
have documented a bunch of my decisions/assumptions. I'm sure many
more have slipped through my blind spots. If a piece of code makes no
sense, or is in a style that you think makes some suboptimal
tradeoffs, let's talk.

## Where The Code Is At Right Now

I've tried to make the code readable, reusable, growable and
malleable. I have _very deliberately_ given no thought to optimizing
the code. No performance standards were set in the requirements, and I
never optimize code that isn't too slow. It's too costly to maintain,
and too easy to optimize clean code after the fact. (Example: during
development the test suite slowed down to 13 seconds, which was too
slow for my taste. A four-line change to the slowest spec file sped
that back up to 2 seconds. Time to make this change: 9 minutes, 6 of
which were spent documenting the optimization and writing the commit
message. See

    git show 7b8af

For the commit and diff.)

## Data Framework

None. I looked through the csv and could visualize the 3NF object
model: `League has_many Teams; Team has_many Players; Player has_many
BattingStats` etc, but I decided to put off moving it into a "proper"
database until the last possible moment.

I have not yet reached that moment.

I've added finder methods to the Batter class, similar to ActiveRecord
or DataMapper.

The first time a Batter class is accessed, the csv files are lazy
loaded.

## BattingData

One of the gotchas in the data is clearly the uniform lack of
uniformity in the data. BattingData is a general class that implements
a data sample dimensional integration pattern--a fancy term for the
plus sign: if you lump BattingDatas together over any dimension, be in
years, teams, leagues, or the entire lifetime of a player, they are
designed to collapse handily, roughly giving the equivalent of a SQL
SUM() statement, except on all the columns instead of just one or two.


## What About Pitchers?

In a word? YAGNI.

The requirements state that a pitchers file may be added at some time
in the future. Seems like this would merit having a `Batter` class and
a `Pitcher` class. But to be honest, I'm not sure the existing data
actually supports a `Batter` class all by itself, since the data file
includes pitchers, relief players, and other team members who show up for games but
never get to the plate (usually because the designated hitter bats in
their place). These "batters" have undefined (0/0) batting averages
and are, by definition, _not batters_. So maybe `Player` would be a
better class here, and the more I think about expanding to include
pitching data the more I think a generic `Player` class could handle
it all without taking on too much responsibility.

Of course, I could be totally wrong--a right I reserve to myself
proudly, being the complete baseball ignoramus that I am. What I do
know for sure is that I definitely would not want to undertake adding
pitching stats without talking to a domain expert. Pitchers have a lot
of stats that are uniquely their own. But again whether this merits a
`Pitcher` class, or pulling the stats out of `Player` into separate
`BatterStats` and `PitcherStats` is up for debate.

One specific hesitation that I have comes from processing the existing
data files. I found that a single player often changed teams and even
leagues during a single season. I would not take a bet that pitchers
don't change positions as well, and I would definitely want to talk to
a baseball stats aficionado before adding pitching to the code.

## No Seriously, Let's Talk Optimization

The code is very deliberatly factored with no thought towards
optimization beyond the most painfully obvious speedbumps. The first
time we touch the data, I slurp in all the CSV data and cache it in
memory so we never have to go back to disk. This takes about a second
on my machine each time, so ignoring that wasn't an option.

Aside from that, however, all calculations are performed repeatedly,
often unnecessarily. My gut tells me that memoizing the
`Batter#stats_for_*` methods would probably speed things up
considerably. My head, however, insists that I have taken no
performance measurements, and I also know that I've left a few messes
in the code still, and until/unless I know the code is officially too
slow--and exactly how much less slow would be acceptable--I'd much
rather focus on cleaning up those messes instead.

## Known Messes

The CSVReader classes are identical. That combined with lazy loading
and the fact that touching Batter triggers loading of BattingData
_and_ Player data leads me to think maybe inheritance, a module, or at
least a shared data connection object could be used here to good
effect. The CSV files are pretty weird, and make the code resistant to
pushing data access all the way out to some implicit/transparent
dependency. I hammered them in just enough to get them working and
then moved on to other code. They should probably be abstracted out,
but I never got around to it because every time I seriously looked at
the CSV code I got a strong impulse to write a rake task to import it
into a sqlite database and just access everything with
ActiveRecord. Then I'd have to go have a lie down for a bit.

The bin/stats program takes no arguments and only generates the exact
report requested by the assignment. For this reason it has a very thin
testing shim. The reason it has a testing shim _at all_ is that I
started my first tests there, as I had clear acceptance requirements
from the assignment document. Rather than clean this code up and get
rid of bin/stats, however, I'd probably like to make it much messier
first: if I were to continue to play with this code as per a real
production tool, I'd want to turn bin/stats into a fully interactive
tool for querying stats and generating reports. For example, as I
worked with the code and explored the data I often wanted to look at
team rosters, batting averages, look up players, etc. Being able to do
that with e.g. `bin/stats --report=slugging --team=OAK --year=2009`
makes for some interesting possibilities.

# INSTALL

These are the official setup and run notes called for by the original
coding problem. Please be aware that I have access to a modern linux
machine and an ancient OSX (Snow Leopard) machine, so these notes are
my "best guess" on OSX. These notes assume you have the original CSV
files and want to make them work with my program, or perhaps that you
have _different_ CSV files to test my program with, because you are
exactly the kind of clever-yet-evil monkey that I would be if _I_ were
administering this coding exercise.

## Step 1: Un-gorble The .CSV files

NOTE: If you are using my repository, this step has already been
performed for you. I have put my data files in the `./data` directory;
the notes below assume you are in the same directory as the data
files.

The CSV files are in a slightly munged format that can be easily read
by `mac2unix` and rewritten as ruby-friendly data. (See `NOTES.md` for
my motivation here.) `mac2unix` is included in the `dos2unix` tool;
you can install it with `sudo apt-get install dos2unix` on linux and
`brew install dos2unix` on OSX.

Next, fix the data files by running

    mac2unix Batting-07-12.csv
    mac2unix Master-small.csv

And that's it. You can verify that ruby can read the files now by
running

`ruby -e 'require "csv"; puts CSV.read("./Batting-07-12.csv", headers:
true).first'`


    ruby -e 'require "csv"; puts CSV.read("./Batting-07-12.csv", headers: true)[1]'

You should see the output:

    aardsda01,2010,AL,SEA,53,0,0,0,0,0,0,0,0,0

## Step 2: Get The Right Ruby

I did this exercise using ruby 2.1.1 with rvm2 as my ruby manager and
Bundler as my gemset manager. Install rvm2 at http://rvm.io, or update
it by typing `rvm get head`, then install ruby with `rvm install
ruby-2.1.1`. If rvm does not automagically create the gemset for you,
you can do it manually with `rvm gemset create baseball_stats; rvm
gemset use baseball_stats`.

## Step 3: Bundle Up, It's Cold Out There

You can install all necessary gem dependencies with bundler, which
comes with ruby. Just type `bundle` and it will install the gem
dependencies (RSpec, etc).

## Step 4: Test To See If We're Alive

At this point you should be good to go. Run the specs with

    bundle exec rspec

And you should have green dots across the board.
