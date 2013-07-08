# NAME

Teng::Plugin::SearchJoined - Teng plugin for Joined query

# SYNOPSIS

    package MyDB;
    use parent qw/Teng/;
    __PACKAGE__->load_plugin('SearchJoined');
    

    package main;
    my $db = MyDB->new(...);
    my $itr = $db->search_joined(user_item => [
        user => {'user_item.user_id' => 'user.id'},
        item => {'user_item.item_id' => 'item.id'},
    ], {
        'user.id' => 2,
    }, {
        order_by => 'user_item.item_id',
    });
    

    while (my ($user_item, $user, $item) = $itr->next) {
        ...
    }

# DESCRIPTION

Teng::Plugin::SearchJoined is a Plugin of Teng for joined query.

# INTERFACE

## Method

### ["$itr:Teng::Plugin::SearchJoined::Iterator = $db->search\_joined($table, $join\_conds, \\%where, \\%opts)"](#$itr:Teng::Plugin::SearchJoined::Iterator = $db->search\_joined($table, $join\_conds, \\%where, \\%opts))

[$table](http://search.cpan.org/perldoc?$table), [\\%where](http://search.cpan.org/perldoc?\\%where) and [\\%opts](http://search.cpan.org/perldoc?\\%opts) are same as arguments of [Teng\#search](http://search.cpan.org/perldoc?Teng\#search).

[$join\_conds](http://search.cpan.org/perldoc?$join\_conds) is same as argument of [SQL::Maker::Plugin::JoinSelect\#join\_select](http://search.cpan.org/perldoc?SQL::Maker::Plugin::JoinSelect\#join\_select).

# LICENSE

Copyright (C) Masayuki Matsuki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Masayuki Matsuki <y.songmu@gmail.com>
