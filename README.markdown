# my fork

I don't really want all the mappings this plugin offers, so I'm attempting
to trim everything I don't use-mainly the encoding and decoding and file
opening.

# unimpaired.vim

unimpaired.vim follows a pattern of complementary pairs of mappings that
mostly fall into these categories:

* There are mappings which are simply short normal mode aliases for
commonly used ex commands. `]q` is :cnext. `[q` is :cprevious. `]a` is
:next.  `[b` is :bprevious.  All of them take a count.

* There are linewise mappings. `[<Space>` and `]<Space>` add newlines
before and after the cursor line. `[e` and `]e` exchange the current
line with the one above or below it.

* There are mappings for toggling options. `[os`, `]os`, and `yos` perform
`:set spell`, `:set nospell`, and `:set invspell`, respectively.  There's also
`l` (`list`), `n` (`number`), `w` (`wrap`), `x` (`cursorline cursorcolumn`),
and several others, plus mappings to help alleviate the `set paste` dance.
Consult the documentation.

The `.` command works with all operator mappings, and will work with the
linewise mappings as well if you install
[repeat.vim](https://github.com/tpope/vim-repeat).

## License

Copyright (c) Tim Pope.  Distributed under the same terms as Vim itself.
See `:help license`.
