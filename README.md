# bramble-bot

Experimental Discord bot written with `discordrb`.

# Requirements

+ Ruby 2.1 or later
+ discordrb gem
  + Use `bundle install` inside the root of the repository, if possible
+ `ffmpeg`, `libsodium` and `libopus` for voice. Instructions [here][libnacl-doc] and [here][libopus-doc].

# TODO

Note: the order of the goals does not reflect their priority, or any other relevant attribute.

- [ ] Run code in Python, Ruby, Perl or Bash.
- [ ] Periodic update of gems and GitHub pushing.
- [ ] Bot execution modes, e.g. log, cmd, sleep etc.
- [ ] Command execution through the terminal emulator.
- [ ] Command execution without prefixing for certain commands.
- [ ] Quote messages through the channel history (checks) or by their ID.
- [ ] Dynamic information and static configurations parsed from JSON files.
- [ ] Disconnect, reconnect, restart, shutdown, pause, refresh and die commands.

[libnacl-doc]: https://github.com/meew0/discordrb/wiki/Installing-libsodium "From the discordrb wiki"
[libopus-doc]: https://github.com/meew0/discordrb/wiki/Installing-libopus "From the discordrb wiki"