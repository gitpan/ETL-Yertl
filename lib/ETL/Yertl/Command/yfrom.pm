package ETL::Yertl::Command::yfrom;
$ETL::Yertl::Command::yfrom::VERSION = '0.016';
use ETL::Yertl;
use ETL::Yertl::Format::yaml;
use Module::Runtime qw( use_module compose_module_name );

sub main {
    my $class = shift;

    my %opt;
    if ( ref $_[-1] eq 'HASH' ) {
        %opt = %{ pop @_ };
    }

    my ( $format, @files ) = @_;

    die "Must give a format\n" unless $format;
    my $formatter_class = compose_module_name( 'ETL::Yertl::Format', $format );
    eval {
        use_module( $formatter_class );
    };
    if ( $@ ) {
        if ( $@ =~ /^Can't locate \S+ in \@INC/ ) {
            die "Unknown format '$format'\n";
        }
        die "Could not load format '$format': $@";
    }

    my $out_formatter = ETL::Yertl::Format::yaml->new;
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

        my $in_formatter = $formatter_class->new( input => $fh, %opt );
        my @docs = $in_formatter->read;
        print $out_formatter->write( @docs );
    }
}

1;

__END__

=pod

=head1 NAME

ETL::Yertl::Command::yfrom

=head1 VERSION

version 0.016

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
