# INSTALL

These are the official setup and run notes called for by the original
coding problem. Please be aware that I have access to a modern linux
machine and an ancient OSX (Snow Leopard) machine, so these notes are
my "best guess" on OSX.

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
