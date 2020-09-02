# Introduction to Functional Programming, with Examples in Haskell

**Author:** Ose Pedro

This repository contains a basic implementation of the messaging system that I used as a running example in my ["Introduction to Functional Programming" presentation](https://docs.google.com/presentation/d/1bIBQewtYiaXQy0kvyWsJ3YTIPQMGXIq1hXNsOXZcURI).

## Setup

To set up the software you need to play around with the messaging system, do the following:

1. **Install Haskell:** follow [these instructions](https://www.haskell.org/platform/).
1. **Download this repository:**
    1. Option 1 (easiest): **Download the zip file:**
        1. Click the "Code" button above, then "Download Zip".
        1. Unzip the file somewhere.
    1. Option 2: **Clone the Git repository:**
        1. If you don't already have Git, use [these instructions](https://git-scm.com/downloads) to get it.
        1. Launch a terminal and run

                git clone git@github.com:OsePedro/HaskellIntro.git

1. **Text editor:** You'll need a text editor to edit the code.
If you want syntax highlighting, try one of the following:
    - [Visual Studio Code](https://code.visualstudio.com/) with the [Haskell](https://marketplace.visualstudio.com/items?itemName=haskell.haskell) extension;
    - [Atom](https://atom.io/) with the [language-haskell](https://atom.io/packages/language-haskell) package.

## Things to Try

1. Launch a terminal and navigate to the `HaskellIntro` directory that you downloaded/cloned.
1. Run `ghci`.
This is a REPL &mdash; an interactive environment in which you can execute arbitrary Haskell expressions.
It allows us to play around with the messaging system without having to write a user interface.
    - Note that it also gives you direct access to parts of the system that it would be unwise to allow users to directly manipulate.
    E.g. it allows you to put `MsgSys` into invalid states that cannot otherwise be reached through the functions exported by [MsgSys.hs](MsgSys.hs).
1. Type `:l Demo` to load the code.
    - The loaded `Demo` module defines:
        - Two instances of `MsgSys` called `msgSys0` and `msgSys1`;
        - Three `LoggedInUser`s: `alerter`, `ose` and `pedro`;
        - The functions and types described in the presentation.
    - There are two ways to view values like `msgSys1` and `ose`:
        1. Type its name into `ghci` and press enter.
        This will print a Haskell expression that represents the full state of the value.
        E.g. if you type `ose`, it will print

                LoggedIn (UserPassword {upUser = User (Name "Ose"), upPassword = Password "Ose's unguessable password"})

        1. Use the `display` function to print a more readable representation of the value.
        This is especially useful for `MsgSys`, as their Haskell expressions are long and poorly formatted.
        Try executing `display msgSys1` and compare it to what you get when you type `msgSys1` to see what I mean.
        You can use `display` to view instances of the following types:
            - `MsgSys`
            - `LoggedInUser`
1. Type `msgSys1` in `ghci` to view a `MsgSys` that contains a few messages and `User`s.
1. There are
Type `ose`, `pedro`, etc. to see the `Name`s of these `LoggedInUser`s.
1. The `password` function displays the `Password` of a `LoggedInUser`.
Type `password alerter`, `password ose`, etc. to see their `Password`s.
1. Open [Demo.hs](Demo.hs) in an editor.
1. Add code that registers two new `User`s to `msgSys1`.
    - The `initialise` function at the bottom of the file demonstrates how to do this.
1. Reload the file in `ghci` (i.e. run `:l Demo` again), to make sure it compiles.
    - Feel free to ask me for help if you have any issues.
1. Type `allUsers msgSys` in `ghci` to check that your new `User`s exist (make sure you use the most recent `MsgSys`!).
1. Search for one of these new `User`s by their `Name`:

        myUser = findUser msgSys name

1. `login` as the other `User`:

        myLoggedInUser = login name password msgSys`

1. Reload the file in `ghci`, then `send` a message from your new `LoggedInUser` to your new `User`:
    - If you execute `send message userPair msgSys` in `ghci`, it will show you the new state of the `MsgSys`.
1. Try out some of the functions that we wrote in the presentation, e.g.:

        alertOutOfSpace user msgSys
        usedSpace msgSys user
        alertMultiOutOfSpace listOfUsers msgSys

1. Have a go at the ["homework" 😁](https://docs.google.com/presentation/d/1bIBQewtYiaXQy0kvyWsJ3YTIPQMGXIq1hXNsOXZcURI/edit#slide=id.g9342e8f7da_2_30).
1. [MsgSys.hs](MsgSys.hs) defines the system's basic types and functions, e.g. `MsgSys`, `User`, `send`, etc.
Feel free to look at it &mdash; it's quite short, and you might understand more of it than you'd expect!

## I'm Hooked! Where Can I learn More About Haskell?

- [A Gentle Introduction to Haskell](https://www.haskell.org/tutorial/) &mdash; a short and sweet tutorial.
- [Learn You a Haskell for Great Good](http://learnyouahaskell.com/) &mdash; I've barely read any of this, but what I've seen so far seems good, and it's free to read online.

## Big Cash Prize!

I created [this image](images/chicks.svg) for the presentation, then changed my mind about using it.
But I like it so much that I thought it would be a shame not to share it with the world.
I'll send £10 to the first person who correctly guesses how I was going to relate it to the presentation.
