#!/usr/bin/perl
use strict;
use warnings;
use HTTP::Proxy;
use HTTP::Proxy::BodyFilter::simple;
use Imager;
use LWP::Simple qw($ua get);
$ua->agent('Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:18.0) Gecko/20100101 Firefox/18.0');

my($type, $port) = @ARGV;
$type ||= "samdoge";
$port ||= 0987;

my %PLACE_HOLDERS = (
  cats   => 'http://placekitten.com/WIDTH/HEIGHT',
  dogs   => 'http://placedog.com/WIDTH/HEIGHT',
  apes   => 'http://placeape.com/WIDTH/HEIGHT',
  random => 'https://unsplash.it/WIDTH/HEIGHT/?random',
  puppy  => 'http://loremflickr.com/g/WIDTH/HEIGHT/puppy',
  memes  => 'http://loremflickr.com/g/WIDTH/HEIGHT/meme',
);
$PLACE_HOLDERS{$type} || die "I don't know how to replace that: $type";

# Create proxy
my $proxy  = HTTP::Proxy->new(in => { port => $port });
my $filter = HTTP::Proxy::BodyFilter::simple->new(\&tamper_image);
$proxy->push_filter(mime => 'image/*', response => $filter);
$proxy->max_clients(500);
$proxy->max_keep_alive_requests(40);
$proxy->start;
 
# Modify images
sub tamper_image {
  my ( $self, $dataref, $message, $protocol, $buffer ) = @_; 

  eval {
    # Get original image data
    my $img = Imager->new(data => $$dataref);
    my ($w, $h) = ($img->getwidth(), $img->getheight());

    # Construct url
    my $url = $PLACE_HOLDERS{$type};
    $url =~ s#WIDTH#$w#;
    $url =~ s#HEIGHT#$h#;

    # Get image
    $$dataref = get($url);
  };
  if ($@) {
    $$dataref = '';
  }
}

__END__
 
=head1 NAME
 
Kitten-Proxy
 
=head1 SYNOPSIS
 
  $ ./kittenProxy.pl [ cats | dogs | apes | random | puppy | sheen ]
 
=head1 DESCRIPTION

A very simple http proxy that replaces images by animals.

This is just a funny example of what you can do with 
L<HTTP::Proxy> and L<HTTP::Proxy::BodyFilter::simple>.

=head1 AUTHOR
 
David Escribano Garcia, L<www.davideg.es>
                                                                                                                                                                                              
=cut
