package Teng::Plugin::SearchJoined;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use Teng::Plugin::SearchJoined::Iterator;

our @EXPORT = qw/search_joined/;

sub search_joined {
    my ($self, $base_table, $join_conditions, $where, $opt) = @_;

    my @tables = ($base_table);
    my $i = 0;
    while (my $table = $join_conditions->[$i]) {
        push @tables, $table;
        $i += 2;
    }

    my @fields;
    for my $table (@tables) {
        my @columns = @{ $self->_get_select_columns($table) };
        @columns = map { [$_, "${table}__$_"] } @columns;
        push @fields, @columns;
    }

    my ($sql, @binds) = $self->{sql_builder}->join_search($base_table, $join_conditions, \@fields, $where, $opt);
    my $sth = $self->execute($sql, \@binds);
    my $itr = Teng::Plugin::SearchJoined::Iterator->new(
        teng   => $self,
        sth    => $sth,
        sql    => $sql,
        tables => \@tables,
    );

    $itr;
}

1;
__END__

=encoding utf-8

=head1 NAME

Teng::Plugin::SearchJoined - It's new $module

=head1 SYNOPSIS

    use Teng::Plugin::SearchJoined;

=head1 DESCRIPTION

Teng::Plugin::SearchJoined is ...

=head1 LICENSE

Copyright (C) Masayuki Matsuki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Masayuki Matsuki E<lt>y.songmu@gmail.comE<gt>

=cut

