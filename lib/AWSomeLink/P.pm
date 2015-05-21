package AWSomeLink::P; {
use Mojo::Base 'Mojolicious::Controller';
use Utils;
use Utils::P;
use Db;

sub start {
    my $c = shift;
    my $prefix = Utils::trim $c->stash->{prefix};
    if( $prefix ne 'my' ){
        $c->redirect_to("/$prefix/p/edit");
    }
}

sub add {
    my $c = shift;

    if( lc($c->req->method) eq 'post' ){
        my $prefix = $c->param("project_id");
        my $db = Db->new($c);
        if( Utils::P::post_add($c,$db) ){
            $c->redirect_to("/$prefix/p");
        } else {
            $c->stash( project_id => $prefix );
        }
    } else { 
        $c->stash( project_id => Utils::get_uuid() );
    }
};

sub edit {
    my $c = shift ;
    my $prefix = Utils::trim $c->stash->{prefix} ;

    my $db = Db->new($c) ;
    my $object_id = Utils::P::project_exist($c,$db,$prefix) ;
    Utils::P::project_deploy($c,$db,$object_id) if $object_id ;
};

1;

};
