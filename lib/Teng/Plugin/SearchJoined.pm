package Teng::Plugin::SearchJoined;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.03";

use Teng;
use Teng::Plugin::SearchJoined::Iterator;
use SQL::Maker;
SQL::Maker->load_plugin('JoinSelect');

our @EXPORT = qw/search_joined search_joined_by_sql search_joined_named/;

sub search_joined {
    my ($self, $base_table, $join_conditions, $where, $opt) = @_;

    my @table_names = ($base_table);
    my $i = 0;
    while (my $table = $join_conditions->[$i]) {
        push @table_names, $table;
        $i += 2;
    }
    my @tables = map { $self->{schema}->get_table($_) } @table_names;

    my $name_sep = $self->{sql_builder}{name_sep};
    my @fields;
    for my $table (@tables) {
        my $table_name = $table->name;
        my @columns = map { "$table_name$name_sep$_" } @{ $table->columns };
        push @fields, @columns;
    }

    my ($sql, @binds) = $self->{sql_builder}->join_select($base_table, $join_conditions, \@fields, $where, $opt);
    my $sth = $self->execute($sql, \@binds);
    my $itr = Teng::Plugin::SearchJoined::Iterator->new(
        teng        => $self,
        sth         => $sth,
        sql         => $sql,
        table_names => \@table_names,
        suppress_object_creation => $self->{suppress_row_objects},
        fields      => \@fields,
    );

    $itr;
}

sub search_joined_by_sql {
    my ($self, $sql, $bind) = @_;

    my @table_names = __PACKAGE__->_guess_table_names($sql);
    my @tables = map { $self->{schema}->get_table($_) } @table_names;

    my $name_sep = $self->{sql_builder}{name_sep};
    my @fields;
    for my $table (@tables) {
        my $table_name = $table->name;
        my @columns = map { "$table_name$name_sep$_" } @{ $table->columns };
        push @fields, @columns;
    }

    my $sth = $self->execute($sql, $bind);
    my $itr = Teng::Plugin::SearchJoined::Iterator->new(
        teng        => $self,
        sth         => $sth,
        sql         => $sql,
        table_names => \@table_names,
        suppress_object_creation => $self->{suppress_row_objects},
        fields      => \@fields,
    );

    $itr;
}

sub search_joined_named {
    my ($self, $sql, $args) = @_;

    $self->search_joined_by_sql(Teng->_bind_named($sql, $args));
}

sub _guess_table_names {
    my ($class, $sql) = @_;

    my @table_names;
    if ($sql =~ /\sfrom\s+["`]?([\w]+)["`]?\s*/si) {
        push @table_names, $1;
    }
    push @table_names, ($sql =~ /\sjoin\s+["`]?([\w]+)["`]?\s*/sig);

    return @table_names;
}

1;
__END__

=encoding utf-8

=head1 NAME

Teng::Plugin::SearchJoined - Teng plugin for Joined query

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Teng::Plugin::SearchJoined is a Plugin of Teng for joined query.

=head1 INTERFACE

=head2 Method

=head3 C<< $itr:Teng::Plugin::SearchJoined::Iterator = $db->search_joined($table, $join_conds, \%where, \%opts) >>

Return L<Teng::Plugin::SearchJoined::Iterator> object.

C<$table>, C<\%where> and C<\%opts> are same as arguments of L<Teng>'s C<search> method.

C<$join_conds> is same as argument of L<SQL::Maker::Plugin::JoinSelect>'s C<join_select> method.

=head3 C<< $itr:Teng::Plugin::SearchJoined::Iterator = $db->search_joined_by_sql($sql, $bind) >>

Return L<Teng::Plugin::SearchJoined::Iterator> object.

C<$sql> and C<$bind> are same as arguments of L<Teng>'s C<search_by_sql> method.

=head3 C<< $itr:Teng::Plugin::SearchJoined::Iterator = $db->search_joined_named($sql, $args) >>

Return L<Teng::Plugin::SearchJoined::Iterator> object.

C<$sql> and C<$args> are same as arguments of L<Teng>'s C<search_named> method.

=head1 SEE ALSO

L<Teng>

L<SQL::Maker::Plugin::JoinSelect>

=head1 LICENSE

Copyright (C) Masayuki Matsuki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Masayuki Matsuki E<lt>y.songmu@gmail.comE<gt>

=cut

