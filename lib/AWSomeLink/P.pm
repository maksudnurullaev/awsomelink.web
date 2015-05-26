package AWSomeLink::P; {
use Mojo::Base 'Mojolicious::Controller';
use Utils;
use Utils::User;
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
            $c->redirect_to("/$prefix/p/edit");
        } else {
            $c->stash( project_id => $prefix );
        }
    } else { 
        $c->stash( project_id => Utils::get_uuid() );
    }
};

sub _check_access{
    my $c = shift;
    my $prefix = Utils::trim $c->stash->{prefix} ;
    if( !$c->is_project_editor ){
        my $path = "/$prefix/p/authorization";
        $c->redirect_to($path) ;
        return(0);
    }
    return(1);
};

sub edit {
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c) ;
    Utils::P::post_update($c,$db) if lc($c->req->method) eq 'post' ;

    my $object_id = Utils::P::project_exist($c,$db,$prefix) ;
    Utils::P::project_deploy($c,$db,$object_id) if $object_id ;
};

sub authorization{
    my $c = shift;
    my $db = Db->new($c) ;
    my $prefix = Utils::trim $c->stash->{prefix} ;
    # 1. check for empty password
    my $password = Utils::trim $c->param('password');
    if( !$password ){
        $c->stash( "invalid_password" => 1 );
    } else {
        # 2. check for password
        if( lc($c->req->method) eq 'post' &&  
                Utils::P::authorization($c,$db,$prefix,$password) ){
            Utils::User::set_project_editor($c);
            $c->redirect_to("/$prefix/p/edit");
            return;
        } else {
            $c->stash( "invalid_password" => 1 );
        }
    }
    my $object_id = Utils::P::project_exist($c,$db,$prefix) ;
    Utils::P::project_deploy($c,$db,$object_id) if $object_id ;
};

sub password{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c) ;

    Utils::P::change_password($c,$db,$prefix)
        if lc($c->req->method) eq 'post';

    my $object_id = Utils::P::project_exist($c,$db,$prefix) ;
    Utils::P::project_deploy($c,$db,$object_id) if $object_id ;
};

sub close{
    my $c = shift;
    Utils::User::logout($c);
    $c->redirect_to('/my/p');
};

1;

};
