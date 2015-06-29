package Mojolicious::Plugin::HTMLTags; {

=encoding utf8


=head1 NAME

    Add additional useful html tags for in web page templates

=head1 USAGE

    I.e. we could add such code to define user with admin roles:
        % if( is_admin ){
         %= tag h1 => "WOW - you administrator!" 
        % }

=cut

use 5.012000;
use strict;
use warnings;
use utf8;
use base 'Mojolicious::Plugin';
use Utils::User;

our $VERSION        = 'v0.0.1b';

sub register {
    my ($self,$app) = @_;
    $app->helper( rfiles_count => sub { Utils::R::get_files_count (@_); } );
    $app->helper( rfiles       => sub { Utils::R::get_files_info (@_); } );
    $app->helper( confirmations_total => sub { Utils::R::get_confirmations_total (@_); } );
    $app->helper( shrink_if    => sub { Utils::shrink_if (@_) ; } );
};

};

1;

__END__

=head1 AUTHOR

    M.Nurullaev <maksud.nurullaev@gmail.com>

=cut


