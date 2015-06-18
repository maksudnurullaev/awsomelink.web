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
        my $db = Db->new($c,$prefix);
        if( $db->initialize && Utils::P::post_add($c,$db) ){
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
    my $user_type = $c->session('user type');
    if( !$user_type || lc($user_type) ne 'project' ){
        my $prefix = Utils::trim $c->stash->{prefix} ;
        $c->redirect_to("/$prefix/p/authorization") ;
        return(0);
    }
    return(1);
};

sub edit {
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;
    Utils::P::post_update($c,$db) if lc($c->req->method) eq 'post' ;

    my $project_db_id = Utils::P::get_project_db_id($db,$prefix) ;
    Utils::deploy_db_object($c,$db,$project_db_id) if $project_db_id ;
};

sub authorization {
    my $c = shift;
    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;
    my $project_db_id = Utils::P::get_project_db_id($db,$prefix) ;
    if( $project_db_id ) {
        my $password = Utils::trim $c->param('password');
        if( !$password ){
            $c->stash( "error_auth" => 1 );
        } else {
            # 2. check for password
            if( lc($c->req->method) eq 'post' &&  
                    Utils::User::authorized($c,$db,$password) ){
                my $user_type = $c->session->{'user type'};
                if( $user_type eq 'project' ){
                    $c->redirect_to("/$prefix/p/edit");
                } elsif( $user_type eq 'recipient' ){
                    $c->redirect_to("/$prefix/r");
                } else {
                    warn "Uknown user type: $user_type";
                }
                return;
            } else {
                $c->stash( "error_auth" => 1 );
            }
        }
        Utils::deploy_db_object($c,$db,$project_db_id) ;
    } else {
        if( $prefix ){
            $c->redirect_to("/$prefix") ;
        } else { 
            $c->redirect_to("/") ;
        }
    }
};

sub password{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;

    Utils::P::change_password($c,$db,$prefix)
        if lc($c->req->method) eq 'post';

    my $project_db_id = Utils::P::get_project_db_id($db,$prefix) ;
    Utils::deploy_db_object($c,$db,$project_db_id) if $project_db_id ;
};

sub files{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;

    Utils::P::post_files($c,$prefix) if lc($c->req->method) eq 'post' ;

    my $project_db_id = Utils::P::get_project_db_id($db,$prefix) ;
    Utils::deploy_db_object($c,$db,$project_db_id) if $project_db_id ;
};

sub recipients{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;

    Utils::P::post_recipients($c,$db) if lc($c->req->method) eq 'post' ;

    my $project_db_id = Utils::P::get_project_db_id($db,$prefix) ;
    Utils::deploy_db_object($c,$db,$project_db_id) if $project_db_id ;
    Utils::deploy_db_objects($c,$db,'recipient','recipients') ;

    my $payload = Utils::trim $c->stash->{payload};
    if( $payload ) {
        Utils::deploy_db_object_all($c,$db,$payload);
    } else {
        $c->stash( password => substr(Utils::get_uuid(),0,4) );
    }
};

sub properties{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;

    Utils::P::post_properties($c,$db) if lc($c->req->method) eq 'post' ;

    my $project_db_id = Utils::P::get_project_db_id($db,$prefix) ;
    Utils::deploy_db_object($c,$db,$project_db_id) if $project_db_id ;
    Utils::deploy_db_objects($c,$db,'property','properties') ;
    my $payload = Utils::trim $c->stash->{payload};
    Utils::deploy_db_object_all($c,$db,$payload) if $payload;
};

sub recipients_delete{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $payload = Utils::trim $c->stash->{payload} ;
    my $db = Db->new($c,$prefix) ;
    $db->del($payload);

    $c->redirect_to("/$prefix/p/recipients");
};

sub properties_delete{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $payload = Utils::trim $c->stash->{payload} ;
    my $db = Db->new($c,$prefix) ;
    $db->del($payload);

    $c->redirect_to("/$prefix/p/properties");
};

sub recipients_update{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $id = $c->param('id') ;
    my $db = Db->new($c,$prefix) ;
    Utils::P::post_recipients_update($c,$db,$id) if lc($c->req->method) eq 'post' ;

    $c->redirect_to("/$prefix/p/recipients/$id");
};

sub properties_update{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $id = $c->param('id') ;
    my $db = Db->new($c,$prefix) ;
    Utils::P::post_properties_update($c,$db,$id) if lc($c->req->method) eq 'post' ;

    $c->redirect_to("/$prefix/p/properties/$id");
};

sub close{
    my $c = shift;
    Utils::User::logout($c);
    $c->redirect_to('/my/p');
};

1;

};
