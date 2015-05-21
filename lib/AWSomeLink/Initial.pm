package AWSomeLink::Initial; {
use Mojo::Base 'Mojolicious::Controller';
# use S3Manager ;
use Utils;
use Db;
use Utils::P;

sub start {
    my $self = shift;
    my $prefix = Utils::trim($self->stash->{prefix} || $self->param('prefix'));
    if( !$prefix || length($prefix) < 8 ){
        $self->stash(error => "Invalid LinkID!") if $prefix;
    } else {
        my $db = Db->new($self);
        warn $prefix;
        $self->redirect_to("/$prefix/p/edit") if 
            Utils::P::project_exist($self,$db,$prefix) ;
    }
}

1;

};
