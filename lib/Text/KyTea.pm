package Text::KyTea;

use 5.008_001;
use strict;
use warnings;

use Carp ();
use Data::Recursive::Encode;
use Lingua::JA::Regular::Unicode qw/alnum_h2z space_h2z katakana_h2z/;

our $VERSION = '0.31';

require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);


sub _options
{
    return {
        # analysis options
        model   => '/usr/local/share/kytea/model.bin',
        h2z     => 1,
        nows    => 0,
        notags  => 0,
        notag   => [],
        nounk   => 0,
        unkbeam => 50,

        # I/O options
        tagmax  => 3,
        deftag  => 'UNK',
        unktag  => '',

        # advanced I/O options
        wordbound => ' ',
        tagbound  => '/',
        elembound => '&',
        unkbound  => ' ',
        skipbound => '?',
        nobound   => '-',
        hasbound  => '|',
    };
}

sub new
{
    my $class = shift;
    my %args  = (ref $_[0] eq 'HASH' ? %{$_[0]} : @_);

    my $options = $class->_options;

    for my $key (keys %args)
    {
        if (!exists $options->{$key}) { Carp::croak "Unknown option '$key'";  }
        else                          { $options->{$key} = $args{$key}; }
    }

    Carp::croak 'model file is not found' if ! -e $options->{model};

    return _init_text_kytea($class, $options);
}

sub _h2z { katakana_h2z( space_h2z( alnum_h2z($_[0]) ) ); }

sub parse
{
    my ($self, $text) = @_;

    my $is_h2z_enable = $self->_is_h2z_enable;

    if ($is_h2z_enable)
    {
        my @original_chars = split(//, $text);
        my $text = _h2z($text);

        my $results = Data::Recursive::Encode->decode_utf8( $self->_parse($text) );

        my $i = 0;

        # changed char -> original char
        for my $result (@{$results})
        {
            $result->{surface} = join( '', @original_chars[$i .. $i + (length $result->{surface}) - 1] );
            $i += length $result->{surface};
        }

        return $results;
    }

    return Data::Recursive::Encode->decode_utf8( $self->_parse($text) );
}

1;
__END__

=encoding utf8

=head1 NAME

Text::KyTea - Perl wrapper for KyTea

=for test_synopsis
my ($text, %config, $path);

=head1 SYNOPSIS

  use Text::KyTea;
  use utf8;

  my $kytea   = Text::KyTea->new(%config);
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

KyTea is a general toolkit developed for analyzing text,
with a focus on Japanese, Chinese and other languages
requiring word or morpheme segmentation.

This module works under KyTea Ver.0.3.2 and later.
Under the old versions of KyTea, this might not work.

If you've changed the default install directory of KyTea,
please install Text::KyTea with a interactive mode
(e.g., cpanm --interactive or cpanm -v).

For more information about KyTea, please see the "SEE ALSO" section of this page.


=head1 METHODS

=over 4

=item new(%config)

Creates a new Text::KyTea instance.

  my $kytea = Text::KyTea->new(
      model   => 'model.bin', # default is '/usr/local/share/kytea/model.bin'
      h2z     => 0,           # default is 1 (enable)
      notag   => [1,2],       # default is []
      nounk   => 0,           # default is 0 (estimates the pronunciation of unkown words)
      unkbeam => 50,          # default is 50
      tagmax  => 3,           # default is 3
      deftag  => 'UNK',       # default is 'UNK'
      unktag  => '',          # default is ''
  );


=item new(h2z => 1)

Converts $text from hankaku to zenkaku before parsing $text.
This option improves the parsing accuracy in most of model files.


=item read_model($path)

Reads the given model file.
The model file should be read by new(model => $path) method.

Model files are available at http://www.phontron.com/kytea/model.html


=item parse($text)

Parses the given text via KyTea, and returns the results of the analysis.
The results are returned as an array reference.


=back

=head1 AUTHOR

pawa E<lt>pawapawa@cpan.orgE<gt>

=head1 SEE ALSO

http://www.phontron.com/kytea/

=head1 LICENSE

Copyright (C) 2012 pawa All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
