package Map::Tube::Plugin::Formatter;

$Map::Tube::Plugin::Formatter::VERSION   = '0.17';
$Map::Tube::Plugin::Formatter::AUTHORITY = 'cpan:MANWAR';

=head1 NAME

Map::Tube::Plugin::Formatter - Formatter plugin for Map::Tube.

=head1 VERSION

Version 0.17

=cut

use 5.006;
use YAML;
use JSON qw();
use Map::Tube::Plugin::Formatter::Utils qw(xml get_data);

use Moo::Role;
use namespace::autoclean;

=head1 DESCRIPTION

A very simple add-on for L<Map::Tube> to format the supported objects.

=head1 SYNOPSIS

    use strict; use warnings;
    use Map::Tube::London;

    my $map = Map::Tube::London->new;

    my $node = $map->get_node_by_name('Baker Street');
    print $node->to_xml,    "\n\n";
    print $node->to_json,   "\n\n";
    print $node->to_yaml,   "\n\n";
    print $node->to_string, "\n\n";

    my $line = $map->get_line_by_name('Metropolitan');
    print $line->to_xml,    "\n\n";
    print $line->to_json,   "\n\n";
    print $line->to_yaml,   "\n\n";
    print $line->to_string, "\n\n";

    my $route = $map->get_shortest_route('Baker Street', 'Wembley Park');
    print $route->to_xml,   "\n\n";
    print $route->to_json,  "\n\n";
    print $route->to_yaml,  "\n\n";
    print $route->to_string,"\n\n";

=head1 SUPPORTED FORMATS

It currently supports the following formats.

=over 4

=item * XML

=item * JSON

=item * YAML

=item * STRING

=back

=head1 SUPPORTED OBJECTS

It currently supports the following objects.

=over 4

=item * L<Map::Tube::Node>

=item * L<Map::Tube::Line>

=item * L<Map::Tube::Route>

=back

=head1 METHODS

=head2 to_xml()

Returns XML representation of the object.

=cut

sub to_xml {
    my ($self) = @_;

    my $data = {};
    if (ref($self) eq 'Map::Tube::Node') {
        $data = {
            node => {
                attributes => {
                    id     => $self->id,
                    name   => $self->name,
                },
                children   => {
                    link   => [ map {{ id => $_->id, name => $_->name }} (@{$self->links}) ],
                    line   => [ map {{ id => $_->id, name => $_->name }} (@{$self->line})  ],
                },
            },
        };
    }
    elsif (ref($self) eq 'Map::Tube::Line') {
        $data = {
            line => {
                attributes  => {
                    id      => $self->id,
                    name    => $self->name,
                    color   => $self->color || 'undef',
                },
                children    => {
                    station => [ map {{ id => $_->id, name => $_->name }} (@{$self->get_stations}) ],
                },
            },
        };
    }
    elsif (ref($self) eq 'Map::Tube::Route') {
        my $children = {};
        my $nodes    = $self->nodes;
        my $size     = $#$nodes;
        foreach my $i (1..($size-1)) {
            push @{$children->{node}}, { name => $nodes->[$i]->as_string, order => $i };
        }

        $data = {
            route => {
                attributes => {
                    from   => $self->from->as_string,
                    to     => $self->to->as_string,
                },
                children   => $children,
            },
        };
    }

    return xml($data);

}

=head2 to_json()

Returns JSON representation of the object.

=cut

sub to_json {
    my ($self) = @_;

    return JSON->new->utf8(1)->pretty->encode(get_data($self));
}

=head2 to_yaml()

Returns YAML representation of the object.

=cut

sub to_yaml {
    my ($self) = @_;

    return Dump(get_data($self));
}

=head2 to_string()

Returns STRING representation of the object.

=cut

sub to_string {
    my ($self) = @_;

    return $self->as_string;
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/manwar/Map-Tube-Plugin-Formatter>

=head1 SEE ALSO

=over 4

=item * L<Map::Tube>

=back

=head1 BUGS

Please report any bugs or feature requests to C<bug-map-tube-plugin-formatter at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Map-Tube-Plugin-Formatter>.
I will  be notified and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Map::Tube::Plugin::Formatter

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Map-Tube-Plugin-Formatter>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Map-Tube-Plugin-Formatter>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Map-Tube-Plugin-Formatter>

=item * Search CPAN

L<http://search.cpan.org/dist/Map-Tube-Plugin-Formatter/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015 - 2016 Mohammad S Anwar.

This program  is  free software; you can redistribute it and / or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a  copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Map::Tube::Plugin::Formatter
