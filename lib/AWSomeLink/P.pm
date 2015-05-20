package AWSomeLink::P; {
use Mojo::Base 'Mojolicious::Controller';
use Utils;
use Utils::P;

sub start {
    my $self = shift;
    my $prefix = Utils::trim $self->stash->{prefix};
    if( $prefix ne 'my' ){
        $self->redirect_to("/$prefix/p/edit");
    }
}

sub add {
    my $self = shift;

    if( lc($self->req->method) eq 'post' ){
        my $prefix = $self->param("project_id");
        if( Utils::P::post_add($self) ){
            $self->redirect_to("/$prefix/p");
        } else {
            $self->stash( project_id => $prefix );
        }
    } else { 
        $self->stash( project_id => Utils::get_uuid() );
    }
};

1;

};
