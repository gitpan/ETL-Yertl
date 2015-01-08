package ETL::Yertl::Command::yto;
$ETL::Yertl::Command::yto::VERSION = '0.015';
use ETL::Yertl;
use Module::Runtime qw( use_module compose_module_name is_module_spec );
use ETL::Yertl::Format::yaml;

sub main {
    my $class = shift;

    my %opt;
    if ( ref $_[-1] eq 'HASH' ) {
        %opt = %{ pop @_ };
    }

    my ( $format, @files ) = @_;

    die "Must give a format\n" unless $format;
    my $formatter_class = eval { compose_module_name( 'ETL::Yertl::Format', $format ) };
    if ( $@ ) {
        die "Unknown format '$format'\n";
    }

    eval {
        use_module( $formatter_class );
    };
    if ( $@ ) {
        if ( $@ =~ /^Can't locate \S+ in \@INC/ ) {
            die "Unknown format '$format'\n";
        }
        die "Could not load format '$format': $@";
    }

    my $out_fmt = $formatter_class->new( %opt );

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
        print $out_fmt->write( $in_fmt->read );
    }
}

1;

__END__

=pod

=head1 NAME

ETL::Yertl::Command::yto

=head1 VERSION

version 0.015

=head1 SYNOPSIS

    ### On a shell...
    $ yto [-v] <format> [<file>...]
    $ yto [-h|--help|--version]

    ### In Perl...
    use ETL::Yertl;
    yto( '<format>', '<filename>', { verbose => 1 } );

=head1 DESCRIPTION

=head1 ARGUMENTS

=head1 OPTIONS

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
