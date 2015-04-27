package AWSomeLink::Initial; {
use Mojo::Base 'Mojolicious::Controller';
use S3Manager ;

# This action will render a template
sub welcome {
    my $self = shift;
    warn $self->req->method;
    my $prefix = $self->stash->{prefix};
    if( $prefix ){
        my $keys = S3Manager::get_keys($prefix);
        $self->stash( keys => $keys );
    } else {
        $prefix = $self->param('prefix');
        warn "Post form $prefix";
        if( $prefix ){
            $self->redirect_to("/$prefix");
        }
    }
}

1;

};
