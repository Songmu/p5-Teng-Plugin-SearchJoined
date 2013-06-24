package Teng::Plugin::SearchJoined::Iterator;
use strict;
use warnings;
use Carp ();
use Class::Accessor::Lite (
    new => 1,
    ro  => [qw/teng sql tables table_names/],
    rw  => [qw/sth suppress_object_creation/],
);

sub _row_class {
    my ($self, $table) = @_;
    $self->{_row_class}{$table} //= $self->{teng}{schema}->get_row_class($table);
}

sub _table_reg {
    my $self = shift;
    $self->{_table_reg} //= do {
        my $reg = '(?:' . join('|', map {quotemeta $_} @{$self->{table_names}}) . ')';
        qr/$reg/;
    };
}

sub next {
    my $self = shift;

    my $row;
    if ($self->{sth}) {
        $row = $self->{sth}->fetchrow_hashref;
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
    my $table_reg = $self->_table_reg;
    for my $key (keys %$row) {
        my ($table, $column) = $key =~ /^(${table_reg})__(.*)$/;

        if ($table && $column) {
            $data{$table}{$column} = $row->{$key};
        }
        else {
            $data{''}{$key} = $row->{$key};
        }
    }

    \%data;
}

1;
