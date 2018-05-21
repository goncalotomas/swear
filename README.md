# swear - Profanity scanning library
[![Build Status](https://travis-ci.org/ClicaAi/swear.svg?branch=master)](https://travis-ci.org/ClicaAi/swear)
[![hex version](https://img.shields.io/hexpm/v/swear.svg)](https://hex.pm/packages/swear)  

An OTP library to scan for profanity in strings.  
Swear word lists adapted from [Shutterstock's][1] repo.

Pull requests for improvements on the curse word lists or other languages are welcomed!

## Build

    $ rebar3 compile

## Use
```
append this to the deps list in your rebar.config file

{deps, [
    ... other deps
    {swear, "~>1.0"}
]}.
```

```erl-sh
1> swear:scan("shit").
true
2> swear:scan("shit", ["pt", "es"]).
false
```

[1]: https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words
