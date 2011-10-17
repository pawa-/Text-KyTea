package Text::KyTea;
use 5.008_001;
use strict;
use warnings;
use Carp;

our $VERSION = '0.11';

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

sub new
{
    my ($class, %args) = @_;

    if (!length $args{model_path})
    {
        $args{model_path} = '/usr/local/share/kytea/model.bin';
    }

    croak 'model file is not found' if ! -e $args{model_path};

    return _init_text_kytea($class, \%args);
}

1;
__END__

=encoding utf8

=head1 NAME

Text::KyTea - Perl wrapper for KyTea

=for test_synopsis
my $text;

=head1 SYNOPSIS

  use Text::KyTea;

  my $kytea   = Text::KyTea->new(model_path => '/usr/local/share/kytea/model.bin');
  my $results = $kytea->parse($text);

  for my $result (@{$results})
  {
      print $result->{surface};

      for my $tags (@{$result->{tags}})
      {
          print "\t";

          for my $tag (@{$tags})
          {
              print " ", $tag->{feature}, "/", $tag->{score};
          }
      }

      print "\n";
  }


=head1 DESCRIPTION

This module works under KyTea Ver.0.3.2 or later.
Under old version of KyTea, this might not works.

For information about KyTea, please see the SEE ALSO.

=head1 METHODS

=over 4

=item new(model_path => $path)

Creates a new Text::KyTea instance.
You can specify KyTea's model path.
If you don't specify it, '/usr/local/share/kytea/model.bin' is specified automatically.


=item read_model($path)

Reads the given model file.
The model file should be read by new(model_path => $path) method.


=item parse($text)

Parses the given text via KyTea, and returns results of analysis.
The results are returned as an array reference.

=back

=head1 AUTHOR

pawa E<lt>pawapawa@cpan.orgE<gt>

=head1 SEE ALSO

http://www.phontron.com/kytea/

=head1 LICENSE

Copyright (C) 2011 pawa All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
