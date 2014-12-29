package ETL::Yertl::Format::yaml;
# ABSTRACT: YAML read/write support for Yertl
$ETL::Yertl::Format::yaml::VERSION = '0.015';
use ETL::Yertl 'Class';
use Module::Runtime qw( use_module );
use List::Util qw( pairs pairkeys pairfirst );


has input => (
    is => 'ro',
    isa => FileHandle,
);


# Pairs of module => supported version
our @FORMAT_MODULES = (
    'YAML::XS' => 0,
    'YAML::Syck' => 0,
    'YAML' => 0,
);

has format_module => (
    is => 'rw',
    isa => sub {
        my ( $format_module ) = @_;
        die "format_module must be one of: " . join " ", pairkeys @FORMAT_MODULES
            unless pairfirst { $a eq $format_module } @FORMAT_MODULES;
        eval {
            use_module( $format_module );
        };
        if ( $@ ) {
            die "Could not load format module '$format_module'";
        }
    },
    lazy => 1,
    default => sub {
        for my $format_module ( pairs @FORMAT_MODULES ) {
            eval {
                # Prototypes on use_module() make @$format_module not work correctly
                use_module( $format_module->[0], $format_module->[1] );
            };
            if ( !$@ ) {
                return $format_module->[0];
            }
        }
        die "Could not load a formatter for YAML. Please install one of the following modules:\n"
            . join "",
                map { sprintf "\t%s (%s)", $_->[0], $_->[1] ? "version $_->[1]" : "Any version" }
                pairs @FORMAT_MODULES;
    },
);


# Hash of MODULE => formatter sub
my %FORMAT_SUB = (

    'YAML::XS' => {
        write => sub {
            my $self = shift;
            return YAML::XS::Dump( @_ );
        },

        read => sub {
            my $self = shift;
            return YAML::XS::Load( do { local $/; readline $self->input } );
        },

    },

    'YAML::Syck' => {
        write => sub {
            my $self = shift;
            return YAML::Syck::Dump( @_ );
        },

        read => sub {
            my $self = shift;
            return YAML::Syck::Load( do { local $/; readline $self->input } );
        },

    },

    'YAML' => {
        write => sub {
            my $self = shift;
            return YAML::Dump( @_ );
        },

        read => sub {
            my $self = shift;
            return YAML::Load( do { local $/; readline $self->input } );
        },

    },
);


sub write {
    my $self = shift;
    return $FORMAT_SUB{ $self->format_module }{write}->( $self, @_ );
}


sub read {
    my $self = shift;
    return $FORMAT_SUB{ $self->format_module }{read}->( $self );
}

1;

__END__

=pod

=head1 NAME

ETL::Yertl::Format::yaml - YAML read/write support for Yertl

=head1 VERSION

version 0.015

=head1 ATTRIBUTES

=head2 input

The filehandle to read from for input.

=head2 format_module

The module being used for this format. Possible modules, in order of importance:

=over 4

=item L<YAML::XS> (any version)

=item L<YAML::Syck> (any version)

=item L<YAML> (any version)

=back

=head1 METHODS

=head2 write( DOCUMENTS )

Convert the given C<DOCUMENTS> to YAML. Returns a YAML string.

=head2 read()

Read a YAML string from L<input> and return all the documents.

=head1 AUTHOR

Doug Bell <preaction@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Doug Bell.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut