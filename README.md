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

    # SQL interface
    $itr = $db->search_joined_by_sql(q[
        SELECT * FROM user_item
        INNER JOIN user
            ON user_item.user_id = user.id
        WHERE user.id = ?
        ORDER BY user_item.item_id
    ], [2]);

    # SQL bind named interface
    $itr = $db->search_joined_named(q[
        SELECT * FROM user_item
        INNER JOIN user
            ON user_item.user_id = user.id
        WHERE user.id = :user_id
        ORDER BY user_item.item_id
    ], { user_id => 2 });

# DESCRIPTION

Teng::Plugin::SearchJoined is a Plugin of Teng for joined query.

# INTERFACE

## Method

### `$itr:Teng::Plugin::SearchJoined::Iterator = $db->search_joined($table, $join_conds, \%where, \%opts)`

Return [Teng::Plugin::SearchJoined::Iterator](http://search.cpan.org/perldoc?Teng::Plugin::SearchJoined::Iterator) object.

`$table`, `\%where` and `\%opts` are same as arguments of [Teng](http://search.cpan.org/perldoc?Teng)'s `search` method.

`$join_conds` is same as argument of [SQL::Maker::Plugin::JoinSelect](http://search.cpan.org/perldoc?SQL::Maker::Plugin::JoinSelect)'s `join_select` method.

### `$itr:Teng::Plugin::SearchJoined::Iterator = $db->search_joined_by_sql($sql, $bind)`

Return [Teng::Plugin::SearchJoined::Iterator](http://search.cpan.org/perldoc?Teng::Plugin::SearchJoined::Iterator) object.

`$sql` and `$bind` are same as arguments of [Teng](http://search.cpan.org/perldoc?Teng)'s `search_by_sql` method.

### `$itr:Teng::Plugin::SearchJoined::Iterator = $db->search_joined_named($sql, $args)`

Return [Teng::Plugin::SearchJoined::Iterator](http://search.cpan.org/perldoc?Teng::Plugin::SearchJoined::Iterator) object.

`$sql` and `$args` are same as arguments of [Teng](http://search.cpan.org/perldoc?Teng)'s `search_named` method.

# SEE ALSO

[Teng](http://search.cpan.org/perldoc?Teng)

[SQL::Maker::Plugin::JoinSelect](http://search.cpan.org/perldoc?SQL::Maker::Plugin::JoinSelect)

# LICENSE

Copyright (C) Masayuki Matsuki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Masayuki Matsuki <y.songmu@gmail.com>
