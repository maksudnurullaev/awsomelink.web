package AWSomeLink;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin;

our $my_self ;

# This method will run once at server start
sub startup {
  my $self = shift ;
  $my_self = $self ;

  # setup plugins
  $self->plugin('RenderFile');
      $self->app->secrets(['XhRa8Gxn3cixIrBg!%)#oanPB@eN$^%&X0pwdfcWra','91ZwJq@&VkXv7F9%&Za7If5eO39mc@%fRc']);
      # production or development
      $self->app->mode('development');
      #$self->app->mode('production');
      # ... just for hypnotoad
  $self->app->config(hypnotoad => {listen => ['http://127.0.0.1:3001']});
  #
  my $r = $self->routes;
  # General route
  $r->route('/:prefix/:controller/:action/*payload')->via('GET','POST')
    ->to(controller => 'initial', action => 'welcome', payload => undef, prefix => undef );
};

1;
