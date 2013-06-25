package Teng::Plugin::SearchJoined::Iterator;
use strict;
use warnings;
use Carp ();
use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/teng sql table_names fields/],
    rw  => [qw/sth suppress_object_creation/],
);

sub _row_class {
    my ($self, $table) = @_;
    $self->{_row_class}{$table} //= $self->{teng}{schema}->get_row_class($table);
}

sub next {
    my $self = shift;

    my $row;
    if ($self->{sth}) {
        $row = $self->{sth}->fetchrow_arrayref;
        unless ( $row ) {
            $self->{sth}->finish;
            $self->{sth} = undef;
            return;
        }
    } else {
        return;
    }

    my $data = $self->_seperate_rows($row);

    if ($self->{suppress_object_creation}) {
        return @$data{ @{$self->{table_names}} };
    } else {
        return map {$self->_row_class($_)->new({
            sql            => $self->{sql},
            row_data       => $data->{$_},
            teng           => $self->{teng},
            table_name     => $_,
        }) } @{$self->{table_names}};
    }
}

sub _seperate_rows {
    my ($self, $row) = @_;
    my %data;
    my $name_sep = quotemeta $self->{teng}{sql_builder}{name_sep};
    my $i = 0;
    for my $field (@{ $self->{fields} }) {
        my $value = $row->[$i++];
        my ($table, $column) = split /$name_sep/, $field;
        $data{$table}{$column} = $value;
    }
    \%data;
}

1;
