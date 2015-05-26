package Utils::User; {

=encoding utf8

=head1 NAME

    Different utilites 

=cut

use 5.012000;
use strict;
use warnings;
use utf8;

sub is_project_editor{
    my $c = shift ;
    return if !$c ;
    if( $c && $c->session ){
        return( $c->session->{'project editor'} );
    }
    return;
};

sub set_project_editor{
    my $c = shift ;
    return if !$c ;
    $c->session->{'project editor'} = 1;
};

sub is_survey_editor{
    my $c = shift ;
    if( $c && $c->session ){
        return($c->session->{'survey editor'} );
    }
    return;
};

sub set_survey_editor{
    my $c = shift ;
    return if !$c ;
    $c->session->{'survey editor'} = 1;
};

sub is_editor_for{
    my ($c,$type) = @_;
    return if !$c || !$type ;
    return(is_project_editor($c)) if( lc($type) eq 'project' );
    return(is_survey_editor($c))  if( lc($type) eq 'survey' );
};

sub logout{
    my $c = shift;
    return if !$c;
    $c->session(expires => 1);
    return(1);
};

# END OF PACKAGE
};

1;

__END__

=head1 AUTHOR

    M.Nurullaev <maksud.nurullaev@gmail.com>

=cut

