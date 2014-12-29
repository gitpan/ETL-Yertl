package ETL::Yertl::Command::ymask;
$ETL::Yertl::Command::ymask::VERSION = '0.015';
use ETL::Yertl;
use ETL::Yertl::Format::yaml;
use Data::Partial::Google;

sub main {
    my $class = shift;

    my %opt;
    if ( ref $_[-1] eq 'HASH' ) {
        %opt = %{ pop @_ };
    }

    my ( $mask, @files ) = @_;

    die "Must give a mask\n" unless $mask;

    my $filter = Data::Partial::Google->new( $mask );
    my $out_fmt = ETL::Yertl::Format::yaml->new;

    push @files, "-" unless @files;
    for my $file ( @files ) {
        # We're doing a similar behavior to <>, but manually for easier testing.
        my $fh;
        if ( $file eq '-' ) {
            # Use the existing STDIN so tests can fake it
            $fh = \*STDIN;
        }
        else {
            unless ( open $fh, '<', $file ) {
                warn "Could not open file '$file' for reading: $!\n";
                next;
            }
        }

        my $in_fmt = ETL::Yertl::Format::yaml->new( input => $fh );
        for my $doc ( $in_fmt->read ) {
            print $out_fmt->write( $filter->mask( $doc ) );
        }
    }
}

1;

__END__

=pod

=head1 NAME

ETL::Yertl::Command::ymask

=head1 VERSION

version 0.015

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
