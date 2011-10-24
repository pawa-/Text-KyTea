package Text::KyTea;
use 5.008_001;
use strict;
use warnings;
use Carp;

our $VERSION = '0.21';


require XSLoader;
XSLoader::load(__PACKAGE__, $VERSION);

sub _options
{
    return {
        # analysis options
        model   => '/usr/local/share/kytea/model.bin',
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
        if (!exists $options->{$key}) { croak "Unknown option '$key'";  }
        else                          { $options->{$key} = $args{$key}; }
    }

    croak 'model file is not found' if ! -e $options->{model};

    return _init_text_kytea($class, $options);
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

This module works under KyTea Ver.0.3.2 or later.
Under old versions of KyTea, this might not works.

For information about KyTea, please see the SEE ALSO.

=head1 METHODS

=over 4

=item new(%config)

Creates a new Text::KyTea instance.

  my $kytea = Text::KyTea->new(
      model   => 'model.bin', # default is '/usr/local/share/kytea/model.bin'
      notag   => [1,2],       # default is []
      nounk   => 0,           # default is 0 (estimates the pronunciation of unkown words)
      unkbeam => 50,          # default is 50
      tagmax  => 3,           # default is 3
      deftag  => 'UNK',       # default is 'UNK'
      unktag  => '',          # default is ''
  );


=item read_model($path)

Reads the given model file.
The model file should be read by new(model => $path) method.


=item parse($text)

Parses the given text via KyTea, and returns results of analysis.
The results are returned as an array reference.


=item write_model($path)


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
